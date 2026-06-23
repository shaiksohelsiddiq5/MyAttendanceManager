const getRecoveryPage = (req, res) => {

  const attended = 68;
  const total = 100;

  let required = 0;

  while (
    ((attended + required) /
    (total + required)) * 100 < 75
  ) {
    required++;
  }

  res.send(`
  <body style="
    background:#081b3a;
    color:white;
    text-align:center;
    font-family:Arial;
    padding:40px;
  ">

    <h1>🎯 Attendance Recovery</h1>

    <h2>Current Attendance</h2>
    <h1>
      ${((attended/total)*100).toFixed(2)}%
    </h1>

    <h2>
      Classes Needed To Reach 75%
    </h2>

    <h1>
      ${required}
    </h1>

    <h2 style="color:lightgreen;">
      📚 Attend Regularly
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
  getRecoveryPage
};