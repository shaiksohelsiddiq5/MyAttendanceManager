const mongoose = require("mongoose");

const academicCalendarSchema =
  new mongoose.Schema({

    rollNo: String,

    fileName: String,

    fileType: String,

    filePath: String,

    uploadedAt: {
      type: Date,
      default: Date.now,
    },
  });

module.exports =
  mongoose.model(
    "AcademicCalendar",
    academicCalendarSchema
  );