const express = require("express");
const multer = require("multer");
const fs = require("fs");
const { fromPath } = require("pdf2pic");
const Tesseract = require("tesseract.js");

const Timetable =
  require("../models/Timetable");

const router = express.Router();

const storage =
  multer.diskStorage({
    destination: (
      req,
      file,
      cb
    ) => {
      cb(null, "uploads/");
    },

    filename: (
      req,
      file,
      cb
    ) => {
      cb(
        null,
        Date.now() +
          "-" +
          file.originalname
      );
    },
  });

const upload =
  multer({ storage });

router.post(
  "/upload-timetable",
  upload.single("file"),
  async (req, res) => {
    try {

      console.log(
        "Starting Timetable OCR..."
      );

      const convert =
        fromPath(
          req.file.path,
          {
            density: 200,
            saveFilename:
              "timetable",
            savePath:
              "./uploads",
            format: "png",
            width: 1200,
            height: 1600,
          }
        );

      const image =
        await convert(1);

      const result =
        await Tesseract.recognize(
          image.path,
          "eng"
        );

      const text =
        result.data.text;

      console.log(
        "OCR TEXT:"
      );

      console.log(text);

      const timetable =
        new Timetable({
          day: "OCR",
          period: "1",
          subject:
            text.substring(
              0,
              200
            ),
        });

      await timetable.save();

      fs.unlinkSync(
        image.path
      );

      fs.unlinkSync(
        req.file.path
      );

      res.json({
        success: true,
        text,
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

module.exports = router;