const mongoose = require("mongoose");

const attendanceSchema = new mongoose.Schema({
  rollNo: {
    type: String,
    required: true,
  },

  subject: {
    type: String,
    required: true,
  },

  present: {
    type: Number,
    default: 0,
  },

  total: {
    type: Number,
    default: 0,
  },
});

module.exports =
  mongoose.model(
    "Attendance",
    attendanceSchema
  );