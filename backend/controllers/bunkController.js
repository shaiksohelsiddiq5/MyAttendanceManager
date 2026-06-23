const getBunkPage = (req, res) => {

  const currentAttendance = 82;
  const todayClasses = 6;

  const newAttendance =
    currentAttendance -
    ((todayClasses * 100) / 700);

  const safe =
    newAttendance >= 75;

  res.send(`
  <body style="
    background:#081b3a;
    color:white;
    text-align:center;
    font-family:Arial;
    padding:40px;
  ">

    <h1>🤔 Can I Bunk Today?</h1>

    <h2>Current Attendance</h2>
    <h1>${currentAttendance}%</h1>

    <h2>Today's Classes</h2>
    <h1>${todayClasses}</h1>

    <h2>
      Attendance After Bunk
    </h2>

    <h1>
      ${newAttendance.toFixed(2)}%
    </h1>

    <h2>
      ${
        safe
        ? "✅ Safe To Bunk"
        : "❌ Don't Bunk"
      }
    </h2>

    <br>

    <a href="/dashboard">
      <button>
        Dashboard
      </button>
    </a>

  </body>
  `);

};

module.exports = {
  getBunkPage
};