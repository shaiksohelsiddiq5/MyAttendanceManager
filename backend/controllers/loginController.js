const getLoginPage = (req, res) => {

  res.send(`
  <body style="
    background:#081b3a;
    color:white;
    font-family:Arial;
    text-align:center;
    padding:50px;
  ">

    <h1>👨‍🎓 Student Login</h1>

    <form action="/setup">

      <input
        type="text"
        placeholder="Student Name"
        required
        style="
          padding:10px;
          width:250px;
        "
      >

      <br><br>

      <input
        type="text"
        placeholder="Roll Number"
        required
        style="
          padding:10px;
          width:250px;
        "
      >

      <br><br>

      <button
        type="submit"
        style="
          padding:15px;
          width:200px;
        "
      >
        Login
      </button>

    </form>

    <br><br>

    <a href="/">
      <button
        style="
          padding:10px;
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
  getLoginPage
};