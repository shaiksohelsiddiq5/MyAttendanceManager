const express = require("express");

const router = express.Router();

const {
  getHolidays,
} = require("../controllers/holidaysController");

router.get(
  "/api/holidays",
  getHolidays
);

module.exports = router;