const getAlertPage = (req, res) => {

  res.send(`
  <body style="
    background:#081b3a;
    color:white;
    text-align:center;
    font-family:Arial;
    padding:40px;
  ">

    <h1>🔔 Exam Alerts</h1>

    <div style="
      border:1px solid white;
      padding:20px;
      margin:20px;
    ">
      <h2>⚠️ Java Exam</h2>
      <h3>3 Days Remaining</h3>
    </div>

    <div style="
      border:1px solid white;
      padding:20px;
      margin:20px;
    ">
      <h2>⚠️ DBMS Exam</h2>
      <h3>7 Days Remaining</h3>
    </div>

    <a href="/dashboard">
      <button>Dashboard</button>
    </a>

  </body>
  `);

};

module.exports = {
  getAlertPage
};