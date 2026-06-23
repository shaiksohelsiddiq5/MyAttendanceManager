const express = require("express");
const cors = require("cors");
const mongoose = require("mongoose");

require("dotenv").config();
const {
  analyzeCalendar,
} = require(
  "./services/aiParser"
);

const app = express();

const timetableRoutes =
  require("./routes/timetableRoutes");

app.use(cors());
app.use(express.json());

app.post(
  "/api/test-ai",
  async (req, res) => {
    try {
      const result =
        await analyzeCalendar(
          req.body.text
        );

      res.json({
        success: true,
        result,
      });
    } catch (err) {
      res.status(500).json({
        success: false,
        error: err.message,
      });
    }
  }
);

app.use("/", require("./routes/homeRoutes"));
app.use("/", require("./routes/loginRoutes"));
app.use("/", require("./routes/registerRoutes"));
app.use("/", require("./routes/setupRoutes"));
app.use("/", require("./routes/profileRoutes"));
app.use("/", require("./routes/dashboardRoutes"));
app.use("/", require("./routes/holidaysRoutes"));
app.use("/", require("./routes/examsRoutes"));
app.use("/", require("./routes/leavePlannerRoutes"));
app.use("/", require("./routes/bunkRoutes"));
app.use("/", require("./routes/recoveryRoutes"));
app.use("/", require("./routes/weekendRoutes"));
app.use("/", require("./routes/alertRoutes"));
app.use("/", require("./routes/apiRoutes"));
app.use("/", require("./routes/attendanceRoutes"));
app.use("/", require("./routes/calendarRoutes"));

app.use(
  "/api",
  require("./routes/calendarRoutes")
);

app.use(
  "/api/timetable",
  timetableRoutes
);

mongoose
  .connect(process.env.MONGO_URI)
  .then(() => {

    console.log(
      "✅ MongoDB Connected"
    );

    app.listen(
      process.env.PORT,
      () => {

        console.log(
          `🚀 Server running on port ${process.env.PORT}`
        );

      }
    );

  })
  .catch((err) => {

    console.log(
      "❌ MongoDB Error:",
      err
    );

  });