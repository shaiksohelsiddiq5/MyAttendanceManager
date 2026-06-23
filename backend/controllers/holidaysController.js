const fs = require("fs");

const getHolidays = (req, res) => {

  const holidays = JSON.parse(
    fs.readFileSync(
      "./data/holidays.json",
      "utf8"
    )
  );

  res.json(holidays);
};

module.exports = {
  getHolidays,
};