const mongoose = require("mongoose");

const timetableSchema = new mongoose.Schema({
  rollNo: String,
  fileName: String,
  day: String,
  period: String,
  subject: String,
  startTime: String,
  endTime: String,
  room: String,

  uploadedAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model(
  "Timetable",
  timetableSchema
);
