const express = require("express");
const router = express.Router();

const {
  getBunkPage
} = require("../controllers/bunkController");

router.get(
  "/bunk",
  getBunkPage
);

module.exports = router;