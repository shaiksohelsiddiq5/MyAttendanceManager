const AcademicCalendar =
  require("../models/AcademicCalendar");

exports.uploadCalendar =
  async (req, res) => {

    try {

      const calendar =
        new AcademicCalendar({

          rollNo:
            req.body.rollNo,

          fileName:
            req.file.filename,

          fileType:
            req.file.mimetype,

          filePath:
            req.file.path,
        });

      await calendar.save();

      res.status(200).json({
        success: true,
        message:
          "Calendar Uploaded",
      });

    } catch (e) {

      res.status(500).json({
        error:
          e.message,
      });

    }
};