const express = require("express");
const router = express.Router();

router.get("/", (req, res) => {
  res.send(`
  <h1>📚 My Attendance Manager</h1>
  <a href="/login">Login</a>
  `);
});

module.exports = router;