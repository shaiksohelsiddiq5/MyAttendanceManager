const express = require("express");
const router = express.Router();
const fs = require("fs");

router.get("/profile", (req, res) => {

  const student = JSON.parse(
    fs.readFileSync("./data/student.json", "utf8")
  );

  res.send(`
    <h1>${student.name}</h1>
    <h3>${student.rollNo}</h3>
  `);

});

module.exports = router;