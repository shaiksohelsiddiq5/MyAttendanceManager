const getHome = (req, res) => {

  res.send(`
  <body style="
    background:#081b3a;
    color:white;
    font-family:Arial;
    text-align:center;
    padding:50px;
  ">

    <h1>📚 My Attendance Manager</h1>

    <h3>Smart Student Academic Assistant</h3>

    <a href="/login">
      <button style="padding:15px;width:250px;margin:10px;">
        👨‍🎓 Student Login
      </button>
    </a>

    <br>

    <a href="/register">
      <button style="padding:15px;width:250px;margin:10px;">
        📝 Student Registration
      </button>
    </a>

    <br>

    <a href="/setup">
      <button style="padding:15px;width:250px;margin:10px;">
        ⚙️ First Time Setup
      </button>
    </a>

    <br>

    <a href="/dashboard">
      <button style="padding:15px;width:250px;margin:10px;">
        🎓 Dashboard
      </button>
    </a>

  </body>
  `);

};

module.exports = {
  getHome
};