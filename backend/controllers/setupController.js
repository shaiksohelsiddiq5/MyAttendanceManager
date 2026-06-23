const getSetupPage = (req, res) => {

  res.send(`
  <body style="
    background:#081b3a;
    color:white;
    font-family:Arial;
    text-align:center;
    padding:40px;
  ">

    <h1>⚙️ First Time Setup</h1>

    <h3>Select Current Date</h3>

    <input
      type="date"
      style="
        padding:10px;
        width:250px;
      "
    >

    <br><br>

    <h3>Current Attendance %</h3>

    <input
      type="number"
      placeholder="Example: 82"
      style="
        padding:10px;
        width:250px;
      "
    >

    <br><br>

    <h3>Upload Academic Calendar</h3>

    <input type="file">

    <br><br>

    <h3>Upload Timetable</h3>

    <input type="file">

    <br><br>

    <a href="/dashboard">
      <button
        style="
          padding:15px;
          width:250px;
        "
      >
        Complete Setup
      </button>
    </a>

    <br><br>

    <a href="/">
      <button
        style="
          padding:12px;
          width:150px;
        "
      >
        Home
      </button>
    </a>

  </body>
  `);

};

module.exports = {
  getSetupPage
};