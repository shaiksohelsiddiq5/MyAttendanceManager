const express = require("express");
const bcrypt = require("bcryptjs");
const User = require("../models/User");

const router = express.Router();

router.post("/register", async (req, res) => {
  try {

    const {
      name,
      rollNo,
      password,
      branch,
      year,
      securityQuestion,
      securityAnswer
    } = req.body;

    const existingUser =
      await User.findOne({ rollNo });

    if (existingUser) {
      return res.status(400).json({
        message:
          "Roll Number already exists",
      });
    }

    const hashedPassword =
      await bcrypt.hash(password, 10);

    const newUser = new User({
      name,
      rollNo,
      password: hashedPassword,
      branch,
      year,
      securityQuestion: securityQuestion || "",
      securityAnswer: securityAnswer || "",
    });

    await newUser.save();

    res.status(201).json({
      message:
        "Registration Successful",
    });

  } catch (error) {

    res.status(500).json({
      message: error.message,
    });

  }
});

module.exports = router;