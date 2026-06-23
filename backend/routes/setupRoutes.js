const express = require("express");
const router = express.Router();

const { getSetupPage } = require("../controllers/setupController");
const User = require("../models/User");
const Calendar = require("../models/Calendar");
const Timetable = require("../models/Timetable");

router.get("/setup", getSetupPage);

router.post("/api/setup", async (req, res) => {
  try {
    const {
      rollNo,
      name,
      branch,
      year,
      attendance,
      target,
      attendedClasses,
      totalClasses,
    } = req.body;

    const updateData = {
      branch,
      year,
      currentAttendance: attendance,
      targetAttendance: target,
      attendedClasses,
      totalClasses,
      setupComplete: true,
    };

    if (name) {
      updateData.name = name;
    }

    const user = await User.findOneAndUpdate(
      { rollNo },
      updateData,
      { new: true }
    );

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    res.json({
      success: true,
      user,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      error: err.message,
    });
  }
});

router.get("/api/user-stats/:rollNo", async (req, res) => {
  try {
    const { rollNo } = req.params;

    // Automatically seed QIS college calendar/timetable if empty
    try {
      const { seedQISCollegeData } = require("../services/seeder");
      await seedQISCollegeData(rollNo);
    } catch (seedErr) {
      console.error("Auto seeding failed during user-stats:", seedErr);
    }

    const user = await User.findOne({ rollNo });
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    const Attendance = require("../models/Attendance");
    const subjects = await Attendance.find({ rollNo });

    let attendedClasses = user.attendedClasses || 0;
    let totalClasses = user.totalClasses || 0;
    let currentAttendance = user.currentAttendance || "0";

    if (subjects.length > 0) {
      attendedClasses = subjects.reduce((sum, s) => sum + (s.present || 0), 0);
      totalClasses = subjects.reduce((sum, s) => sum + (s.total || 0), 0);
      currentAttendance = totalClasses === 0 ? "0" : ((attendedClasses / totalClasses) * 100).toFixed(1);

      user.attendedClasses = attendedClasses;
      user.totalClasses = totalClasses;
      user.currentAttendance = currentAttendance;
      await user.save();
    }

    res.json({
      success: true,
      stats: {
        name: user.name,
        rollNo: user.rollNo,
        branch: user.branch || "",
        year: user.year || "",
        currentAttendance,
        targetAttendance: user.targetAttendance || "75",
        attendedClasses,
        totalClasses,
        calendarFileName: user.calendarFileName || "",
        timetableFileName: user.timetableFileName || "",
        setupComplete: user.setupComplete || false
      }
    });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

router.get("/api/calculate-classes/:rollNo/:toDate", async (req, res) => {
  try {
    const { rollNo, toDate } = req.params;
    const targetDate = new Date(toDate);
    if (isNaN(targetDate.getTime())) {
      return res.status(400).json({ success: false, message: "Invalid toDate parameter" });
    }

    // 1. Fetch user's calendar commencement date and holidays
    const calendar = await Calendar.findOne({ rollNo });
    let startDate = new Date("2025-07-05"); // default commencement of I Semester
    let holidaySet = new Set();

    if (calendar) {
      const commencementLine = calendar.semesterDates.find(d => d.includes("Commencement of I Semester"));
      if (commencementLine) {
        const parts = commencementLine.split(":");
        if (parts.length > 1) {
          const dateStr = parts[1].trim(); // "05-07-2025"
          const dateParts = dateStr.split("-");
          if (dateParts.length === 3) {
            startDate = new Date(`${dateParts[2]}-${dateParts[1]}-${dateParts[0]}`);
          }
        }
      }

      // Populate holidaySet
      for (const hol of calendar.holidays) {
        const parts = hol.split("-");
        if (parts.length >= 3) {
          const dateKey = `${parts[0].trim()}-${parts[1].trim()}-${parts[2].split(" ")[0].trim()}`;
          holidaySet.add(dateKey);
        }
      }
    }

    // 2. Fetch user's timetable sessions
    const sessions = await Timetable.find({ rollNo });
    const timetableMap = {};
    for (const s of sessions) {
      const day = s.day.toLowerCase();
      timetableMap[day] = (timetableMap[day] || 0) + 1;
    }

    // 3. Loop from startDate to targetDate and count classes
    let totalScheduled = 0;
    let curr = new Date(startDate);

    const endSim = new Date(targetDate.getFullYear(), targetDate.getMonth(), targetDate.getDate());
    
    while (curr <= endSim) {
      const year = curr.getFullYear();
      const dateStr = `${year}-${String(curr.getMonth() + 1).padStart(2, '0')}-${String(curr.getDate()).padStart(2, '0')}`;

      const isWeekend = curr.getDay() === 0 || curr.getDay() === 6;
      const isListedHoliday = holidaySet.has(dateStr);

      if (!isWeekend && !isListedHoliday) {
        const weekdaysNames = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"];
        const weekdayName = weekdaysNames[curr.getDay()];
        totalScheduled += (timetableMap[weekdayName] || 0);
      }

      curr.setDate(curr.getDate() + 1);
    }

    res.json({
      success: true,
      startDate: startDate.toISOString().split("T")[0],
      endDate: toDate,
      totalClasses: totalScheduled,
    });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

router.get("/api/calculate-subject-classes/:rollNo/:toDate", async (req, res) => {
  try {
    const { rollNo, toDate } = req.params;
    const targetDate = new Date(toDate);
    if (isNaN(targetDate.getTime())) {
      return res.status(400).json({ success: false, message: "Invalid toDate parameter" });
    }

    // 1. Fetch user's calendar commencement date and holidays
    const calendar = await Calendar.findOne({ rollNo });
    let startDate = new Date("2025-07-05"); // default commencement of I Semester
    let holidaySet = new Set();

    if (calendar) {
      const commencementLine = calendar.semesterDates.find(d => d.includes("Commencement of I Semester"));
      if (commencementLine) {
        const parts = commencementLine.split(":");
        if (parts.length > 1) {
          const dateStr = parts[1].trim(); // "05-07-2025"
          const dateParts = dateStr.split("-");
          if (dateParts.length === 3) {
            startDate = new Date(`${dateParts[2]}-${dateParts[1]}-${dateParts[0]}`);
          }
        }
      }

      // Populate holidaySet
      for (const hol of calendar.holidays) {
        const parts = hol.split("-");
        if (parts.length >= 3) {
          const dateKey = `${parts[0].trim()}-${parts[1].trim()}-${parts[2].split(" ")[0].trim()}`;
          holidaySet.add(dateKey);
        }
      }
    }

    // 2. Fetch user's timetable sessions
    const sessions = await Timetable.find({ rollNo });
    const timetableMap = {};
    for (const s of sessions) {
      const day = s.day.toLowerCase();
      if (!timetableMap[day]) {
        timetableMap[day] = [];
      }
      timetableMap[day].push(s.subject);
    }

    // 3. Loop from startDate to targetDate and count classes per subject
    const subjectCounts = {};
    let curr = new Date(startDate);

    const endSim = new Date(targetDate.getFullYear(), targetDate.getMonth(), targetDate.getDate());
    
    while (curr <= endSim) {
      const year = curr.getFullYear();
      const dateStr = `${year}-${String(curr.getMonth() + 1).padStart(2, '0')}-${String(curr.getDate()).padStart(2, '0')}`;

      const isWeekend = curr.getDay() === 0 || curr.getDay() === 6;
      const isListedHoliday = holidaySet.has(dateStr);

      if (!isWeekend && !isListedHoliday) {
        const weekdaysNames = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"];
        const weekdayName = weekdaysNames[curr.getDay()];
        const daySubjects = timetableMap[weekdayName] || [];
        for (const sub of daySubjects) {
          subjectCounts[sub] = (subjectCounts[sub] || 0) + 1;
        }
      }

      curr.setDate(curr.getDate() + 1);
    }

    res.json({
      success: true,
      startDate: startDate.toISOString().split("T")[0],
      endDate: toDate,
      subjects: subjectCounts,
    });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

module.exports = router;