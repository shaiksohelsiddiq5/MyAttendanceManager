const express = require("express");
const router = express.Router();

const {
  getDashboardPage
} = require("../controllers/dashboardController");

router.get("/dashboard", getDashboardPage);

module.exports = router;