const express = require("express");
const multer = require("multer");
const fs = require("fs");
const path = require("path");
const { fromPath } = require("pdf2pic");
const Tesseract = require("tesseract.js");
const sharp = require("sharp");
const XLSX = require("xlsx");

const Timetable = require("../models/Timetable");
const User = require("../models/User");
const { analyzeTimetable } = require("../services/aiParser");

const router = express.Router();

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/");
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + "-" + file.originalname);
  },
});

const upload = multer({ storage });

function formatTime(timeStr) {
  timeStr = timeStr.toLowerCase().trim().replace(".", ":");
  const isPm = timeStr.includes("pm");
  const isAm = timeStr.includes("am");
  let digits = timeStr.replace(/[a-z]/g, "").trim();
  
  if (!digits) return "";
  if (!digits.includes(":")) {
    digits = digits + ":00";
  }

  let [hours, minutes] = digits.split(":").map(Number);
  if (isNaN(hours) || isNaN(minutes)) return timeStr;

  if (isPm && hours < 12) hours += 12;
  if (isAm && hours === 12) hours = 0;
  
  if (!isAm && !isPm && hours < 8) {
    hours += 12;
  }

  return `${String(hours).padStart(2, "0")}:${String(minutes).padStart(2, "0")}`;
}

function parseExcelTimetable(filePath) {
  const workbook = XLSX.readFile(filePath);
  const sheetName = workbook.SheetNames[0];
  const worksheet = workbook.Sheets[sheetName];
  const data = XLSX.utils.sheet_to_json(worksheet, { header: 1 });

  const sessions = [];
  const warnings = [];

  if (!data || data.length === 0) {
    throw new Error("Excel sheet is empty");
  }

  const weekdays = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"];
  
  let isGrid = false;
  let dayColIndex = 0;
  let headerRowIndex = 0;

  for (let r = 0; r < Math.min(data.length, 5); r++) {
    const row = data[r] || [];
    for (let c = 0; c < Math.min(row.length, 5); c++) {
      const val = String(row[c] || "").toLowerCase().trim();
      if (weekdays.includes(val)) {
        isGrid = true;
        dayColIndex = c;
        headerRowIndex = Math.max(0, r - 1);
        break;
      }
    }
    if (isGrid) break;
  }

  if (isGrid) {
    const headerRow = data[headerRowIndex] || [];
    
    for (let r = headerRowIndex + 1; r < data.length; r++) {
      const row = data[r] || [];
      const dayVal = String(row[dayColIndex] || "").trim();
      
      const matchedDay = weekdays.find(w => dayVal.toLowerCase().startsWith(w));
      if (!matchedDay) continue;
      
      const capitalizedDay = matchedDay.charAt(0).toUpperCase() + matchedDay.slice(1);

      for (let c = dayColIndex + 1; c < row.length; c++) {
        const cellValue = String(row[c] || "").trim();
        if (!cellValue) continue;

        const headerVal = String(headerRow[c] || "").trim();
        
        let period = String(c - dayColIndex);
        let startTime = "";
        let endTime = "";

        const periodMatch = headerVal.match(/period\s*(\d+)/i);
        if (periodMatch) {
          period = periodMatch[1];
        }

        const timeMatch = headerVal.match(/(\d+(?:\.\d+)?\s*(?:am|pm)?)\s*-\s*(\d+(?:\.\d+)?\s*(?:am|pm)?)/i);
        if (timeMatch) {
          startTime = formatTime(timeMatch[1]);
          endTime = formatTime(timeMatch[2]);
        } else {
          const timings = {
            "1": ["09:00", "09:50"],
            "2": ["09:50", "10:40"],
            "3": ["11:00", "11:50"],
            "4": ["11:50", "12:40"],
            "5": ["13:30", "14:20"],
            "6": ["14:20", "15:10"],
            "7": ["15:20", "16:10"],
            "8": ["16:10", "17:00"]
          };
          if (timings[period]) {
            startTime = timings[period][0];
            endTime = timings[period][1];
          }
        }

        const lines = cellValue.split(/\r?\n/).map(l => l.trim()).filter(l => l.length > 0);
        let subject = cellValue;
        let room = "";

        if (lines.length >= 2) {
          const roomLine = lines.find(l => /^[a-zA-Z]\d{3}/i.test(l) || l.toLowerCase().includes("lh") || l.toLowerCase().includes("lab") || l.toLowerCase().includes("room") || l.toLowerCase().includes("library") || l.toLowerCase().includes("p.e.t"));
          if (roomLine) {
            room = roomLine;
            const nonSubjectLines = ["2-1", "batch", "cse", "it", "ece"];
            const subjectLine = lines.find(l => l !== roomLine && !nonSubjectLines.some(ns => l.toLowerCase().includes(ns)));
            if (subjectLine) {
              subject = subjectLine;
            }
          } else {
            subject = lines[Math.floor(lines.length / 2)];
          }
        }

        subject = subject.replace(/^(?:2-1|batch\s*\d+|cse\s*\d+)\s*/i, "").trim();

        sessions.push({
          day: capitalizedDay,
          period,
          subject,
          startTime,
          endTime,
          room
        });
      }
    }
  } else {
    const headerRow = data[0] || [];
    let dayIdx = -1, periodIdx = -1, subIdx = -1, startIdx = -1, endIdx = -1, roomIdx = -1;

    for (let c = 0; c < headerRow.length; c++) {
      const val = String(headerRow[c] || "").toLowerCase().trim();
      if (val.includes("day")) dayIdx = c;
      else if (val.includes("period")) periodIdx = c;
      else if (val.includes("subject") || val.includes("class")) subIdx = c;
      else if (val.includes("start")) startIdx = c;
      else if (val.includes("end")) endIdx = c;
      else if (val.includes("room") || val.includes("class")) roomIdx = c;
    }

    if (dayIdx === -1) dayIdx = 0;
    if (subIdx === -1) subIdx = 1;

    for (let r = 1; r < data.length; r++) {
      const row = data[r] || [];
      if (row.length === 0) continue;

      const dayVal = String(row[dayIdx] || "").trim();
      const matchedDay = weekdays.find(w => dayVal.toLowerCase().startsWith(w));
      if (!matchedDay) continue;

      const capitalizedDay = matchedDay.charAt(0).toUpperCase() + matchedDay.slice(1);
      const subject = String(row[subIdx] || "").trim();
      if (!subject) continue;

      const period = periodIdx !== -1 ? String(row[periodIdx] || "").trim() : "1";
      const startTime = startIdx !== -1 ? formatTime(String(row[startIdx] || "")) : "";
      const endTime = endIdx !== -1 ? formatTime(String(row[endIdx] || "")) : "";
      const room = roomIdx !== -1 ? String(row[roomIdx] || "").trim() : "";

      sessions.push({
        day: capitalizedDay,
        period,
        subject,
        startTime,
        endTime,
        room
      });
    }
  }

  return { sessions, warnings };
}

router.post(
  "/upload-timetable",
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
      
      let sessions = [];
      let warnings = [];
      let analysisSource = "";
      let text = "";

      if (isExcel) {
        console.log("Processing Excel timetable...");
        try {
          const excelResult = parseExcelTimetable(req.file.path);
          sessions = excelResult.sessions;
          warnings = excelResult.warnings;
          analysisSource = "excel-direct";
          text = sessions.map(s => `${s.day} P${s.period} ${s.subject} ${s.startTime}-${s.endTime} ${s.room}`).join("\n");
        } catch (excelErr) {
          console.error("Excel timetable parsing failed:", excelErr);
          return res.status(400).json({
            success: false,
            message: "Failed to parse Excel timetable: " + excelErr.message
          });
        }
      } else {
        console.log("Starting Timetable OCR...");
        const isPdf = req.file.mimetype === "application/pdf" || req.file.originalname.toLowerCase().endsWith(".pdf");

        if (isPdf) {
          const options = {
            density: 600,
            saveFilename: "tt",
            savePath: "./uploads",
            format: "png",
            width: 3500,
            height: 5000,
          };

          const convert = fromPath(req.file.path, options);
          const image = await convert(1);

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
              logger: (m) => console.log(m),
              tessedit_pageseg_mode: 6,
              tessedit_ocr_engine_mode: 1,
            }
          );

          text = result.data.text;
          fs.unlinkSync(image.path);
        } else {
          // Direct Image OCR
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
              logger: (m) => console.log(m),
              tessedit_pageseg_mode: 6,
              tessedit_ocr_engine_mode: 1,
            }
          );

          text = result.data.text;
        }

        console.log("OCR TEXT:");
        console.log(text);

        analysisSource = "ocr-only";

        try {
          const analysis = await analyzeTimetable(text);
          sessions = analysis.sessions;
          warnings = analysis.warnings;
          analysisSource = "local-ai";
        } catch (aiError) {
          warnings.push(
            "Local AI was unavailable. Review and confirm the OCR text manually."
          );
          console.warn("AI timetable analysis fallback:", aiError.message);
        }
      }

      if (sessions.length > 0) {
        const rollNo = req.body.rollNo || "Unknown";
        await Timetable.deleteMany({ rollNo });

        await Timetable.insertMany(
          sessions.map((session) => ({
            ...session,
            rollNo,
            fileName: req.file.originalname,
          }))
        );
      }

      await User.findOneAndUpdate(
        { rollNo: req.body.rollNo || "Unknown" },
        { timetableFileName: req.file.originalname }
      );

      fs.unlinkSync(req.file.path);

      res.json({
        success: true,
        text,
        sessions,
        warnings,
        analysisSource,
      });

    } catch (err) {
      console.log(err);
      res.status(500).json({
        success: false,
        error: err.message,
      });
    }
  }
);

router.get("/:rollNo", async (req, res) => {
  try {
    const timetable = await Timetable.find({ rollNo: req.params.rollNo });
    res.json({ success: true, sessions: timetable });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

module.exports = router;
