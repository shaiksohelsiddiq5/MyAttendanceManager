const express = require("express");
const multer = require("multer");
const fs = require("fs");
const { fromPath } = require("pdf2pic");
const Tesseract = require("tesseract.js");
const sharp = require("sharp");
const XLSX = require("xlsx");
const path = require("path");

const Calendar = require("../models/Calendar");
const User = require("../models/User");
const { analyzeCalendar } = require("../services/aiParser");

const router = express.Router();

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/");
  },

  filename: (req, file, cb) => {
    cb(
      null,
      Date.now() + "-" + file.originalname
    );
  },
});

const upload = multer({
  storage,
});

router.get("/test-calendar", (req, res) => {
  res.send("Calendar Route Working");
});

router.post(
  "/upload-calendar",
  upload.single("file"),
  async (req, res) => {
    try {

      if (!req.file) {
        return res.status(400).json({
          success: false,
          message: "No file uploaded",
        });
      }

      const ext = path.extname(req.file.originalname).toLowerCase();
      const isExcel = ext === ".xlsx" || ext === ".xls";
      const isPdf = req.file.mimetype === "application/pdf" || req.file.originalname.toLowerCase().endsWith(".pdf");
      let extractedText = "";

      if (isExcel) {
        console.log("Processing Excel calendar...");
        try {
          const workbook = XLSX.readFile(req.file.path);
          const sheetName = workbook.SheetNames[0];
          const worksheet = workbook.Sheets[sheetName];
          const rows = XLSX.utils.sheet_to_json(worksheet, { header: 1 });
          extractedText = rows
            .map((row) =>
              row
                .map((cell) =>
                  cell !== null && cell !== undefined ? String(cell).trim() : ""
                )
                .join("\t")
            )
            .join("\n");
        } catch (excelErr) {
          console.error("Excel calendar parsing failed:", excelErr);
          return res.status(400).json({
            success: false,
            message: "Failed to parse Excel calendar: " + excelErr.message,
          });
        }
      } else if (isPdf) {
        const options = {
          density: 600,
          saveFilename: "page",
          savePath: "./uploads",
          format: "png",
          width: 3500,
          height: 5000,
        };

        const convert = fromPath(req.file.path, options);

        for (let page = 1; page <= 10; page++) {
          try {
            console.log("Converting page:", page);
            const image = await convert(page);

            console.log("Image created:", image.path);
            console.log("Starting OCR page:", page);

            await sharp(image.path)
              .grayscale()
              .normalize()
              .sharpen()
              .threshold(150)
              .toFile("./uploads/processed.png");

            const result = await Tesseract.recognize(
              "./uploads/processed.png",
              "eng",
              {
                logger: (m) => {
                  if (m.status === "recognizing text") {
                    console.log(`OCR ${Math.round(m.progress * 100)}%`);
                  }
                },
                tessedit_pageseg_mode: 6,
                tessedit_ocr_engine_mode: 1,
              }
            );

            console.log("OCR Done page:", page);
            extractedText += "\n\n" + result.data.text;
            console.log(`Total extracted length after page ${page}: ${extractedText.length}`);
            fs.unlinkSync(image.path);
          } catch (e) {
            console.log("PAGE ERROR:", page);
            console.log(e);
            break;
          }
        }
      } else {
        // Direct Image OCR
        try {
          console.log("Processing image directly...");
          await sharp(req.file.path)
            .grayscale()
            .normalize()
            .sharpen()
            .threshold(150)
            .toFile("./uploads/processed.png");

          const result = await Tesseract.recognize(
            "./uploads/processed.png",
            "eng",
            {
              logger: (m) => {
                if (m.status === "recognizing text") {
                  console.log(`OCR ${Math.round(m.progress * 100)}%`);
                }
              },
              tessedit_pageseg_mode: 6,
              tessedit_ocr_engine_mode: 1,
            }
          );
          extractedText = result.data.text;
          console.log(`OCR completed successfully. Extracted length: ${extractedText.length}`);
        } catch (e) {
          console.log("IMAGE OCR ERROR:", e);
          throw e;
        }
      }

      fs.writeFileSync(
        "./uploads/full-calendar-text.txt",
        extractedText
      );

      console.log(
        "FULL OCR TEXT SAVED TO uploads/full-calendar-text.txt"
      );

      const holidays = [];
      const exams = [];
      const semesterDates = [];

      const lines =
        extractedText.split("\n");

      lines.forEach((line) => {

        const text =
          line.toLowerCase();

        if (
          text.includes(
            "holiday"
          ) ||
          text.includes(
            "independence"
          ) ||
          text.includes(
            "christmas"
          ) ||
          text.includes(
            "sankranti"
          ) ||
          text.includes(
            "ramzan"
          )
        ) {
          holidays.push(line);
        }

        if (
          text.includes(
            "exam"
          ) ||
          text.includes(
            "mid"
          ) ||
          text.includes(
            "external"
          )
        ) {
          exams.push(line);
        }

        if (
          text.includes(
            "commencement"
          ) ||
          text.includes(
            "instruction"
          ) ||
          text.includes(
            "semester"
          )
        ) {
          semesterDates.push(
            line
          );
        }
      });

      let analysisSource = "keyword-fallback";
      let warnings = [];

      try {
        const aiAnalysis = await analyzeCalendar(extractedText);

        holidays.splice(0, holidays.length, ...aiAnalysis.holidays);
        exams.splice(0, exams.length, ...aiAnalysis.exams);
        semesterDates.splice(
          0,
          semesterDates.length,
          ...aiAnalysis.semesterDates
        );
        warnings = aiAnalysis.warnings;
        analysisSource = "local-ai";
      } catch (aiError) {
        warnings.push(
          "Local AI was unavailable; keyword results were used."
        );
        console.warn("AI calendar analysis fallback:", aiError.message);
      }

      await Calendar.deleteMany({
        rollNo: req.body.rollNo || "Unknown",
      });

      const calendar =
        new Calendar({
          rollNo:
            req.body.rollNo ||
            "Unknown",

          fileName:
            req.file.originalname,

          extractedText,

          holidays,

          exams,

          semesterDates,
        });

      await calendar.save();

      await User.findOneAndUpdate(
        { rollNo: req.body.rollNo || "Unknown" },
        { calendarFileName: req.file.originalname }
      );

      fs.unlinkSync(
        req.file.path
      );

      res.json({
        success: true,
        fileName:
          req.file.originalname,

        holidays,
        exams,
        semesterDates,

        analysisSource,
        warnings,

        textLength:
          extractedText.length,
      });

    } catch (err) {

      console.log(err);

      res.status(500).json({
        success: false,
        error:
          err.message,
      });
    }
  }
);

function splitDigitsToDate(digits) {
  if (!digits || digits.length < 5 || digits.length > 8) return null;
  const len = digits.length;
  
  for (let dLen = 1; dLen <= 2; dLen++) {
    for (let mLen = 1; mLen <= 2; mLen++) {
      const yLen = len - dLen - mLen;
      if (yLen === 2 || yLen === 3 || yLen === 4) {
        const dayStr = digits.substring(0, dLen);
        const monthStr = digits.substring(dLen, dLen + mLen);
        const yearStr = digits.substring(dLen + mLen);
        
        const day = parseInt(dayStr, 10);
        const month = parseInt(monthStr, 10);
        let year = yearStr;
        
        if (day >= 1 && day <= 31 && month >= 1 && month <= 12) {
          if (year.length === 2) {
            year = "20" + year;
          } else if (year.length === 3) {
            if (year.startsWith("20")) {
              year = year.startsWith("205") ? "2025" : year.startsWith("206") ? "2026" : "20" + year.slice(2);
            } else {
              year = "20" + year.slice(1);
            }
          }
          
          const yNum = parseInt(year, 10);
          if (yNum === 2025 || yNum === 2026) {
            return `${year}-${String(month).padStart(2, "0")}-${String(day).padStart(2, "0")}`;
          }
        }
      }
    }
  }
  return null;
}

function findNearestDate(allLines, targetLine) {
  const dateRegex = /\b(\d{1,2})[-./](\d{1,2})[-./](\d{2,4})\b/;
  
  const parseDateStr = (text) => {
    if (!text) return null;
    
    let match = text.match(dateRegex);
    if (match) {
      let day = match[1].padStart(2, "0");
      let month = match[2].padStart(2, "0");
      let year = match[3];
      const dVal = parseInt(day, 10);
      const mVal = parseInt(month, 10);
      if (dVal >= 1 && dVal <= 31 && mVal >= 1 && mVal <= 12) {
        if (year.length === 2) year = "20" + year;
        else if (year.length === 3) {
          year = year.startsWith("205") ? "2025" : year.startsWith("206") ? "2026" : "20" + year.slice(2);
        }
        return `${year}-${month}-${day}`;
      }
    }

    const digitMatches = text.match(/\b\d{5,8}\b/g) || [];
    for (const dm of digitMatches) {
      const parsed = splitDigitsToDate(dm);
      if (parsed) return parsed;
    }
    
    const bracketMatch = text.match(/\[([a-zA-Z0-9]+)\]/);
    if (bracketMatch) {
      const cleanDigits = bracketMatch[1].replace(/[^0-9]/g, "");
      const parsed = splitDigitsToDate(cleanDigits);
      if (parsed) return parsed;
    }

    return null;
  };

  const selfDate = parseDateStr(targetLine);
  if (selfDate) return selfDate;

  const cleanTarget = targetLine.trim();
  const idx = allLines.findIndex(l => l.trim() === cleanTarget);
  if (idx === -1) return null;

  for (let i = 1; i <= 15; i++) {
    const prevIdx = idx - i;
    if (prevIdx >= 0) {
      const date = parseDateStr(allLines[prevIdx]);
      if (date) return date;
    }
  }

  for (let i = 1; i <= 5; i++) {
    const nextIdx = idx + i;
    if (nextIdx < allLines.length) {
      const date = parseDateStr(allLines[nextIdx]);
      if (date) return date;
    }
  }

  return null;
}

function adjustYearToFuture(dateStr) {
  if (!dateStr || dateStr === "Academic Calendar" || dateStr === "Scheduled") return dateStr;
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const parts = dateStr.split("-");
    if (parts.length !== 3) return dateStr;
    
    let eventDate = new Date(parseInt(parts[0], 10), parseInt(parts[1], 10) - 1, parseInt(parts[2], 10));
    if (isNaN(eventDate.getTime())) return dateStr;

    while (eventDate < today) {
      eventDate.setFullYear(eventDate.getFullYear() + 1);
    }

    const y = eventDate.getFullYear();
    const m = String(eventDate.getMonth() + 1).padStart(2, "0");
    const d = String(eventDate.getDate()).padStart(2, "0");
    return `${y}-${m}-${d}`;
  } catch (e) {
    return dateStr;
  }
}

router.get("/api/holidays/:rollNo", async (req, res) => {
  try {
    const calendar = await Calendar.findOne({ rollNo: req.params.rollNo }).sort({ uploadedAt: -1 });
    if (calendar && calendar.holidays && calendar.holidays.length > 0) {
      const allLines = (calendar.extractedText || "").split("\n");
      const formatted = calendar.holidays.map((h) => {
        let date = findNearestDate(allLines, h);
        date = adjustYearToFuture(date);
        
        let name = h;
        const dateRegex = /\b(\d{1,2})[-./\s]?(\d{2})[-./\s]?(\d{2,4})\b/g;
        const rawDigitsRegex = /\b(\d{7,8})\b/g;
        name = name.replace(dateRegex, "").replace(rawDigitsRegex, "");
        
        name = name
          .replace(/^[|:\-\s\t_#]+|[|:\-\s\t_#]+$/g, "")
          .replace(/\s*[|\-:]\s*/g, " ")
          .replace(/\s+/g, " ")
          .trim();

        if (!name) name = "Holiday";
        return { date: date || "Academic Calendar", name };
      });
      return res.json(formatted);
    }

    const holidays = JSON.parse(fs.readFileSync("./data/holidays.json", "utf8"));
    res.json(holidays);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get("/api/exams/:rollNo", async (req, res) => {
  try {
    const calendar = await Calendar.findOne({ rollNo: req.params.rollNo }).sort({ uploadedAt: -1 });
    if (calendar && calendar.exams && calendar.exams.length > 0) {
      const allLines = (calendar.extractedText || "").split("\n");
      const formatted = calendar.exams.map((e) => {
        let date = findNearestDate(allLines, e);
        date = adjustYearToFuture(date);
        
        let subject = e;
        const dateRegex = /\b(\d{1,2})[-./\s]?(\d{2})[-./\s]?(\d{2,4})\b/g;
        const rawDigitsRegex = /\b(\d{7,8})\b/g;
        subject = subject.replace(dateRegex, "").replace(rawDigitsRegex, "");
        
        subject = subject
          .replace(/^[|:\-\s\t_#]+|[|:\-\s\t_#]+$/g, "")
          .replace(/\s*[|\-:]\s*/g, " ")
          .replace(/\s+/g, " ")
          .trim();

        if (!subject) subject = "Examination";
        return { date: date || "Scheduled", subject };
      });
      return res.json(formatted);
    }
    const exams = JSON.parse(fs.readFileSync("./data/exams.json", "utf8"));
    res.json(exams);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get("/api/calendar/commencement/:rollNo", async (req, res) => {
  try {
    const calendar = await Calendar.findOne({ rollNo: req.params.rollNo }).sort({ uploadedAt: -1 });
    let startDate = new Date("2025-07-05"); // default I Semester commencement
    if (calendar && calendar.semesterDates) {
      const commencementLine = calendar.semesterDates.find(d => d.includes("Commencement of I Semester"));
      if (commencementLine) {
        const dateMatch = commencementLine.match(/\b(\d{1,2})[-./](\d{1,2})[-./](\d{4})\b/);
        if (dateMatch) {
          const d = dateMatch[1].padStart(2, '0');
          const m = dateMatch[2].padStart(2, '0');
          const y = dateMatch[3];
          startDate = new Date(`${y}-${m}-${d}`);
        }
      }
    }
    res.json({ success: true, startDate: startDate.toISOString().split("T")[0] });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

module.exports = router;

