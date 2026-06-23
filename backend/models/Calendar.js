const mongoose = require("mongoose");

const calendarSchema =
  new mongoose.Schema({
    rollNo: String,

    fileName: String,

    extractedText: String,

    holidays: [String],

    exams: [String],

    semesterDates: [String],

    uploadedAt: {
      type: Date,
      default: Date.now,
    },
  });

module.exports =
  mongoose.model(
    "Calendar",
    calendarSchema
  );