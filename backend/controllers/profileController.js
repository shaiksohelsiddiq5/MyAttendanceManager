const fs = require("fs");

const getProfile = (req, res) => {

  const student = JSON.parse(
    fs.readFileSync("./data/student.json", "utf8")
  );

  res.json(student);

};

module.exports = {
  getProfile
};