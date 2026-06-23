const getDashboardPage = (req, res) => {

  res.send(`
  <body style="
    background:#081b3a;
    color:white;
    font-family:Arial;
    text-align:center;
    padding:40px;
  ">

    <h1>🎓 Student Dashboard</h1>

    <h2>Welcome Siddiq 👋</h2>

    <br>

    <a href="/attendance">
      <button style="padding:15px;width:280px;margin:10px;">
        📊 Attendance
      </button>
    </a>

    <br>

    <a href="/holidays">
      <button style="padding:15px;width:280px;margin:10px;">
        📅 Holidays
      </button>
    </a>

    <br>

    <a href="/exams">
      <button style="padding:15px;width:280px;margin:10px;">
        📝 Upcoming Exams
      </button>
    </a>

    <br>

    <a href="/leave-planner">
      <button style="padding:15px;width:280px;margin:10px;">
        🎉 Leave Planner
      </button>
    </a>

    <br>

    <a href="/bunk">
      <button style="padding:15px;width:280px;margin:10px;">
        🤔 Can I Bunk Today?
      </button>
    </a>

    <br>

    <a href="/recovery">
      <button style="padding:15px;width:280px;margin:10px;">
        🎯 Attendance Recovery
      </button>
    </a>

    <br>

    <a href="/weekend">
      <button style="padding:15px;width:280px;margin:10px;">
        📆 Long Weekend Finder
      </button>
    </a>

    <br>

    <a href="/profile">
      <button style="padding:15px;width:280px;margin:10px;">
        👨‍🎓 Profile
      </button>
    </a>

    <br>
    <a href="/alerts">
  <button style="
    padding:15px;
    width:280px;
    margin:10px;
  ">
    🔔 Exam Alerts
  </button>
</a>

<br>

    <a href="/">
      <button style="padding:15px;width:280px;margin:10px;">
        🏠 Home
      </button>
    </a>

  </body>
  `);

};

module.exports = {
  getDashboardPage
};