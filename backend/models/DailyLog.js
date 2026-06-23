const mongoose = require("mongoose");

const dailyLogSchema = new mongoose.Schema({
  rollNo: {
    type: String,
    required: true,
  },
  date: {
    type: String, // YYYY-MM-DD
    required: true,
  },
  subject: {
    type: String,
    required: true,
  },
  period: {
    type: String,
    required: true,
  },
  status: {
    type: String, // "present" or "absent"
    required: true,
  },
});

module.exports = mongoose.model("DailyLog", dailyLogSchema);
