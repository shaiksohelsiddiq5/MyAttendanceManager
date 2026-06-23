const express = require("express");
const router = express.Router();

const {
  getExamsPage
} = require("../controllers/examsController");

router.get("/exams", getExamsPage);

module.exports = router;