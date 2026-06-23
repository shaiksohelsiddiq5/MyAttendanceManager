const getWeekendPage = (req, res) => {

  res.send(`
  <body style="
    background:#081b3a;
    color:white;
    font-family:Arial;
    text-align:center;
    padding:40px;
  ">

    <h1>📆 Long Weekend Finder</h1>

    <div style="
      border:1px solid white;
      padding:20px;
      margin:20px;
    ">

      <h2>🎉 Recommended Leave</h2>

      <h3>Take Leave On Thursday</h3>

      <p>Thursday → Leave</p>

      <p>Friday → Independence Day</p>

      <p>Saturday → Weekend</p>

      <p>Sunday → Weekend</p>

      <h2>
        Total Break = 4 Days
      </h2>

    </div>

    <a href="/dashboard">
      <button>
        Dashboard
      </button>
    </a>

  </body>
  `);

};

module.exports = {
  getWeekendPage
};