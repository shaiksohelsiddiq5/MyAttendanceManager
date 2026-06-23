const express = require("express");
const router = express.Router();

router.get("/api/attendance", (req, res) => {
  res.json([
    {
      subject: "Java",
      percentage: 75,
    },
    {
      subject: "DBMS",
      percentage: 82,
    },
    {
      subject: "React",
      percentage: 70,
    },
    {
      subject: "Node.js",
      percentage: 88,
    },
  ]);
});

router.get("/api/holidays", (req, res) => {
  res.json([
    {
      date: "2026-08-15",
      name: "Independence Day",
    },
    {
      date: "2026-10-02",
      name: "Gandhi Jayanti",
    },
  ]);
});

module.exports = router;