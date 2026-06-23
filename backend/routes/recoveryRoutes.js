const express = require("express");
const router = express.Router();

const {
  getRecoveryPage
} = require("../controllers/recoveryController");

router.get(
  "/recovery",
  getRecoveryPage
);

module.exports = router;