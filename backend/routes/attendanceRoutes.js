const express = require("express");
const Attendance =
  require("../models/Attendance");

const router = express.Router();

const User = require("../models/User");

async function syncUserAttendanceStats(rollNo) {
  try {
    const user = await User.findOne({ rollNo });
    if (!user) return;

    const subjects = await Attendance.find({ rollNo });
    if (subjects.length > 0) {
      const attendedClasses = subjects.reduce((sum, s) => sum + (s.present || 0), 0);
      const totalClasses = subjects.reduce((sum, s) => sum + (s.total || 0), 0);
      const currentAttendance = totalClasses === 0 ? "0" : ((attendedClasses / totalClasses) * 100).toFixed(1);

      user.attendedClasses = attendedClasses;
      user.totalClasses = totalClasses;
      user.currentAttendance = currentAttendance;
      await user.save();
    }
  } catch (err) {
    console.error("Error syncing user attendance stats:", err);
  }
}

router.post(
  "/attendance",
  async (req, res) => {
    try {
      const { rollNo, subject, present, total } = req.body;
      if (!rollNo || !subject) {
        return res.status(400).json({ message: "rollNo and subject are required" });
      }

      let record = await Attendance.findOne({ rollNo, subject });
      if (record) {
        record.present = present;
        record.total = total;
        await record.save();
      } else {
        record = new Attendance({ rollNo, subject, present, total });
        await record.save();
      }

      // Automatically sync overall stats
      await syncUserAttendanceStats(rollNo);

      res.status(201).json(record);
    } catch (err) {
      res.status(500).json({
        message: err.message,
      });
    }
  }
);

router.get(
  "/attendance/:rollNo",
  async (req, res) => {
    try {
      const data = await Attendance.find({
        rollNo: req.params.rollNo,
      });
      res.json(data);
    } catch (err) {
      res.status(500).json({
        message: err.message,
      });
    }
  }
);

router.delete(
  "/attendance/:rollNo/:subject",
  async (req, res) => {
    try {
      const { rollNo, subject } = req.params;
      const result = await Attendance.findOneAndDelete({ rollNo, subject });
      if (!result) {
        return res.status(404).json({ message: "Subject attendance not found" });
      }

      // Automatically sync overall stats
      await syncUserAttendanceStats(rollNo);

      res.json({ success: true, message: "Subject attendance deleted successfully" });
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  }
);

const DailyLog = require("../models/DailyLog");

router.get("/api/daily-log/:rollNo/:date", async (req, res) => {
  try {
    const { rollNo, date } = req.params;
    const logs = await DailyLog.find({ rollNo, date });
    res.json({ success: true, logs });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.post("/api/daily-log", async (req, res) => {
  try {
    const { rollNo, date, subject, period, status } = req.body;
    if (!rollNo || !date || !subject || !period || !status) {
      return res.status(400).json({ success: false, message: "Missing required fields" });
    }

    let log = await DailyLog.findOne({ rollNo, date, subject, period });
    let attRecord = await Attendance.findOne({ rollNo, subject });
    if (!attRecord) {
      attRecord = new Attendance({ rollNo, subject, present: 0, total: 0 });
      await attRecord.save();
    }

    if (log) {
      if (log.status !== status) {
        if (status === "present") {
          attRecord.present += 1;
        } else if (status === "absent") {
          attRecord.present = Math.max(0, attRecord.present - 1);
        }
        log.status = status;
        await log.save();
        await attRecord.save();
      }
    } else {
      log = new DailyLog({ rollNo, date, subject, period, status });
      await log.save();
      
      attRecord.total += 1;
      if (status === "present") {
        attRecord.present += 1;
      }
      await attRecord.save();
    }

    await syncUserAttendanceStats(rollNo);
    res.json({ success: true, log });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.delete("/api/daily-log/:rollNo/:date/:subject/:period", async (req, res) => {
  try {
    const { rollNo, date, subject, period } = req.params;
    const log = await DailyLog.findOneAndDelete({ rollNo, date, subject, period });
    if (!log) {
      return res.status(404).json({ success: false, message: "Log not found" });
    }

    let attRecord = await Attendance.findOne({ rollNo, subject });
    if (attRecord) {
      attRecord.total = Math.max(0, attRecord.total - 1);
      if (log.status === "present") {
        attRecord.present = Math.max(0, attRecord.present - 1);
      }
      await attRecord.save();
    }

    await syncUserAttendanceStats(rollNo);
    res.json({ success: true, message: "Log cleared successfully" });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;