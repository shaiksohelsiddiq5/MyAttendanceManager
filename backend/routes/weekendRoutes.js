const express = require("express");
const router = express.Router();

const {
  getWeekendPage
} = require("../controllers/weekendController");

router.get(
  "/weekend",
  getWeekendPage
);

module.exports = router;