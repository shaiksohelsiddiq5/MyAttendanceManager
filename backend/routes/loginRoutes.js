const express = require("express");
const bcrypt = require("bcryptjs");
const User = require("../models/User");

const router = express.Router();

router.post("/login", async (req, res) => {

  try {

    const {
      rollNo,
      password
    } = req.body;

    const user =
      await User.findOne({ rollNo });

    if (!user) {
      return res.status(400).json({
        message:
          "User not found",
      });
    }

    const isMatch =
      await bcrypt.compare(
        password,
        user.password
      );

    if (!isMatch) {
      return res.status(400).json({
        message:
          "Invalid Password",
      });
    }

    // Automatically seed QIS college calendar/timetable if empty
    try {
      const { seedQISCollegeData } = require("../services/seeder");
      await seedQISCollegeData(rollNo);
    } catch (seedErr) {
      console.error("Auto seeding failed during login:", seedErr);
    }

    const updatedUser = await User.findOne({ rollNo });

    res.status(200).json({
      message:
        "Login Successful",
      user: updatedUser,
    });

  } catch (error) {

    res.status(500).json({
      message: error.message,
    });

  }

});

router.get("/forgot-password/question/:rollNo", async (req, res) => {
  try {
    const { rollNo } = req.params;
    const user = await User.findOne({ rollNo });
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    res.json({
      success: true,
      securityQuestion: user.securityQuestion || "What is your default security question?",
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.post("/forgot-password", async (req, res) => {
  try {
    const { rollNo, securityAnswer, newPassword } = req.body;
    if (!rollNo || !securityAnswer || !newPassword) {
      return res.status(400).json({ message: "All fields are required" });
    }

    const user = await User.findOne({ rollNo });
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    const savedAnswer = (user.securityAnswer || "").trim().toLowerCase();
    const inputAnswer = securityAnswer.trim().toLowerCase();

    if (savedAnswer !== inputAnswer) {
      return res.status(400).json({ message: "Incorrect security answer" });
    }

    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(newPassword, salt);
    await user.save();

    res.json({ success: true, message: "Password reset successful" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});
 
module.exports = router;