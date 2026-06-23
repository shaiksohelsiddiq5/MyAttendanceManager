const fs = require("fs");

const getLeavePlannerPage = (req, res) => {

  const holidays = JSON.parse(
    fs.readFileSync("./data/holidays.json", "utf8")
  );

  let html = `
  <body style="
    background:#081b3a;
    color:white;
    font-family:Arial;
    text-align:center;
    padding:40px;
  ">

  <h1>🎉 Smart Leave Planner</h1>
  `;

  holidays.forEach(holiday => {

    html += `
      <div style="
        border:1px solid white;
        padding:20px;
        margin:15px;
      ">

      <h2>${holiday.name}</h2>

      <h3>${holiday.date}</h3>

      <p>
      💡 Take leave before this holiday
      for a longer break.
      </p>

      </div>
    `;
  });

  html += `
    <a href="/dashboard">
      <button style="
        padding:15px;
        width:200px;
      ">
        Dashboard
      </button>
    </a>

  </body>
  `;

  res.send(html);
};

module.exports = {
  getLeavePlannerPage
};