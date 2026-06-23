const express = require("express");
const router = express.Router();

const {
  getAlertPage
} = require("../controllers/alertController");

router.get(
  "/alerts",
  getAlertPage
);

module.exports = router;