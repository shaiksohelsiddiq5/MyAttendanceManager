const fs = require("fs");

const getExamsPage = (req, res) => {

  const exams = JSON.parse(
    fs.readFileSync("./data/exams.json", "utf8")
  );

  let html = `
  <body style="
    background:#081b3a;
    color:white;
    text-align:center;
    font-family:Arial;
    padding:40px;
  ">

  <h1>📝 Upcoming Exams</h1>
  `;

  const today = new Date();

  exams.forEach(exam => {

    const examDate = new Date(exam.date);

    const diff =
      Math.ceil(
        (examDate - today)
        /
        (1000 * 60 * 60 * 24)
      );

    html += `
      <div style="
        border:1px solid white;
        padding:20px;
        margin:15px;
      ">
        <h2>${exam.subject}</h2>

        <h3>${exam.date}</h3>

        <h3>
          ${diff} Days Remaining
        </h3>

        ${
          diff <= 7
          ?
          "<h2 style='color:red;'>🚨 Exam Near</h2>"
          :
          "<h2 style='color:lightgreen;'>✅ Plenty Of Time</h2>"
        }

      </div>
    `;
  });

  html += `
  <a href="/dashboard">
    <button>Dashboard</button>
  </a>
  </body>
  `;

  res.send(html);

};

module.exports = {
  getExamsPage
};