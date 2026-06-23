const Calendar = require("../models/Calendar");
const Timetable = require("../models/Timetable");
const Attendance = require("../models/Attendance");
const User = require("../models/User");

const QIS_HOLIDAYS = [
  // Semester 1
  { date: "2025-07-12", name: "Special Holiday" },
  { date: "2025-07-13", name: "Public Holiday" },
  { date: "2025-07-20", name: "Public Holiday" },
  { date: "2025-07-27", name: "Public Holiday" },
  { date: "2025-08-03", name: "Public Holiday" },
  { date: "2025-08-10", name: "Public Holiday" },
  { date: "2025-08-15", name: "Independence Day" },
  { date: "2025-08-16", name: "Sri Krishna Astami" },
  { date: "2025-08-17", name: "Public Holiday" },
  { date: "2025-08-24", name: "Public Holiday" },
  { date: "2025-08-27", name: "Sri Vinayaka Chavithi" },
  { date: "2025-08-31", name: "Public Holiday" },
  { date: "2025-09-05", name: "Milad-un-Nabi/Teachers Day" },
  { date: "2025-09-07", name: "Public Holiday" },
  { date: "2025-09-14", name: "Public Holiday" },
  { date: "2025-09-21", name: "Public Holiday" },
  { date: "2025-09-28", name: "Public Holiday" },
  { date: "2025-09-29", name: "Special Holiday" },
  { date: "2025-09-30", name: "Durgastami" },
  { date: "2025-10-01", name: "Maharnavami" },
  { date: "2025-10-02", name: "Mahatma Gandhi Jayanthi & Vijaya Dasami" },
  { date: "2025-10-05", name: "Public Holiday" },
  { date: "2025-10-12", name: "Public Holiday" },
  { date: "2025-10-19", name: "Public Holiday" },
  { date: "2025-10-20", name: "Deepavali" },
  { date: "2025-10-21", name: "Special Holiday" },
  { date: "2025-10-26", name: "Public Holiday" },
  { date: "2025-11-02", name: "Public Holiday" },
  { date: "2025-11-09", name: "Public Holiday" },
  { date: "2025-11-16", name: "Public Holiday" },
  
  // Semester 2
  { date: "2025-11-23", name: "Public Holiday" },
  { date: "2025-11-30", name: "Public Holiday" },
  { date: "2025-12-07", name: "Public Holiday" },
  { date: "2025-12-14", name: "Public Holiday" },
  { date: "2025-12-21", name: "Public Holiday" },
  { date: "2025-12-24", name: "Special Holiday" },
  { date: "2025-12-25", name: "Christmas" },
  { date: "2025-12-28", name: "Public Holiday" },
  { date: "2026-01-01", name: "Special Holiday" },
  { date: "2026-01-04", name: "Public Holiday" },
  { date: "2026-01-11", name: "Public Holiday" },
  { date: "2026-01-12", name: "Special Holiday" },
  { date: "2026-01-13", name: "Bhogi" },
  { date: "2026-01-14", name: "Makara Sankrati" },
  { date: "2026-01-15", name: "Kanuma" },
  { date: "2026-01-16", name: "Special Holiday" },
  { date: "2026-01-17", name: "Third Saturday Holiday" },
  { date: "2026-01-18", name: "Public Holiday" },
  { date: "2026-01-25", name: "Public Holiday" },
  { date: "2026-01-26", name: "Republic Day" },
  { date: "2026-02-01", name: "Public Holiday" },
  { date: "2026-02-09", name: "Special Holiday" },
  { date: "2026-02-15", name: "Maha Sivarathri" },
  { date: "2026-02-21", name: "Third Saturday" },
  { date: "2026-02-22", name: "Public Holiday" },
  { date: "2026-03-01", name: "Public Holiday" },
  { date: "2026-03-08", name: "Public Holiday" },
  { date: "2026-03-15", name: "Public Holiday" },
  { date: "2026-03-20", name: "Ugadi" },
  { date: "2026-03-21", name: "Third Saturday (Ramzan)" },
  { date: "2026-03-22", name: "Public Holiday" },
  { date: "2026-03-27", name: "Sri Rama Navami" },
  { date: "2026-03-29", name: "Public Holiday" },
  { date: "2026-04-03", name: "Good Friday" },
  { date: "2026-04-05", name: "Public Holiday" },
  { date: "2026-04-12", name: "Public Holiday" },
  { date: "2026-04-14", name: "Ambedkar Jayanthi" }
];

const QIS_EXAMS = [
  // Semester 1
  { date: "2025-08-29", subject: "I Mid Exam" },
  { date: "2025-08-30", subject: "I Mid Exam" },
  { date: "2025-09-01", subject: "I Mid Exam" },
  { date: "2025-11-03", subject: "II Mid Exam" },
  { date: "2025-11-04", subject: "II Mid Exam" },
  { date: "2025-11-05", subject: "II Mid Exam" },
  { date: "2025-11-06", subject: "End Sem Theory & Practical Exams" },
  { date: "2025-11-20", subject: "End Sem Theory & Practical Exams" },
  
  // Semester 2
  { date: "2026-01-19", subject: "I Mid Exam" },
  { date: "2026-01-20", subject: "I Mid Exam" },
  { date: "2026-01-21", subject: "I Mid Exam" },
  { date: "2026-03-30", subject: "II Mid Exam" },
  { date: "2026-03-31", subject: "II Mid Exam" },
  { date: "2026-04-01", subject: "II Mid Exam" },
  { date: "2026-04-02", subject: "End Sem Practical & Theory Exams" },
  { date: "2026-04-18", subject: "End Sem Practical & Theory Exams" }
];

const QIS_TIMETABLE = [
  // Monday
  { day: "Monday", period: "1", subject: "P&S", startTime: "09:00", endTime: "09:50", room: "E204" },
  { day: "Monday", period: "2", subject: "P&S", startTime: "09:50", endTime: "10:40", room: "E204" },
  { day: "Monday", period: "3", subject: "Library", startTime: "11:00", endTime: "11:50", room: "Library" },
  { day: "Monday", period: "4", subject: "P.E.T", startTime: "11:50", endTime: "12:40", room: "P.E.T" },
  { day: "Monday", period: "5", subject: "Technical Skilling", startTime: "13:30", endTime: "14:20", room: "A101" },
  { day: "Monday", period: "6", subject: "Technical Skilling", startTime: "14:20", endTime: "15:10", room: "A101" },
  { day: "Monday", period: "7", subject: "DAA Lab", startTime: "15:20", endTime: "16:10", room: "B104" },
  { day: "Monday", period: "8", subject: "DAA Lab", startTime: "16:10", endTime: "17:00", room: "B104" },

  // Tuesday
  { day: "Tuesday", period: "1", subject: "OOPS through JAVA", startTime: "09:00", endTime: "09:50", room: "J106" },
  { day: "Tuesday", period: "2", subject: "OOPS through JAVA", startTime: "09:50", endTime: "10:40", room: "J106" },
  { day: "Tuesday", period: "3", subject: "P&S", startTime: "11:00", endTime: "11:50", room: "CSE 6" },
  { day: "Tuesday", period: "4", subject: "DMGT", startTime: "11:50", endTime: "12:40", room: "CSE 6" },
  { day: "Tuesday", period: "5", subject: "Project", startTime: "13:30", endTime: "14:20", room: "J206" },
  { day: "Tuesday", period: "6", subject: "Project", startTime: "14:20", endTime: "15:10", room: "J206" },
  { day: "Tuesday", period: "7", subject: "Applied Skilling", startTime: "15:20", endTime: "16:10", room: "E201" },
  { day: "Tuesday", period: "8", subject: "Applied Skilling", startTime: "16:10", endTime: "17:00", room: "E201" },

  // Wednesday
  { day: "Wednesday", period: "1", subject: "Project", startTime: "09:00", endTime: "09:50", room: "J206" },
  { day: "Wednesday", period: "2", subject: "Project", startTime: "09:50", endTime: "10:40", room: "J206" },
  { day: "Wednesday", period: "3", subject: "Non Tech", startTime: "11:00", endTime: "11:50", room: "CSE 6" },
  { day: "Wednesday", period: "4", subject: "Foreign Lang", startTime: "11:50", endTime: "12:40", room: "CSE 6" },
  { day: "Wednesday", period: "5", subject: "OOPS through JAVA", startTime: "13:30", endTime: "14:20", room: "J106" },
  { day: "Wednesday", period: "6", subject: "OOPS through JAVA", startTime: "14:20", endTime: "15:10", room: "J106" },
  { day: "Wednesday", period: "7", subject: "DMGT", startTime: "15:20", endTime: "16:10", room: "CSE 6" },
  { day: "Wednesday", period: "8", subject: "DAA", startTime: "16:10", endTime: "17:00", room: "CSE 6" },

  // Thursday
  { day: "Thursday", period: "1", subject: "P&S", startTime: "09:00", endTime: "09:50", room: "CSE 6" },
  { day: "Thursday", period: "2", subject: "DAA", startTime: "09:50", endTime: "10:40", room: "CSE 6" },
  { day: "Thursday", period: "3", subject: "Applied Skilling", startTime: "11:00", endTime: "11:50", room: "E201" },
  { day: "Thursday", period: "4", subject: "Applied Skilling", startTime: "11:50", endTime: "12:40", room: "E201" },
  { day: "Thursday", period: "5", subject: "P&S", startTime: "13:30", endTime: "14:20", room: "CSE 6" },
  { day: "Thursday", period: "6", subject: "Foreign Lang", startTime: "14:20", endTime: "15:10", room: "CSE 6" },
  { day: "Thursday", period: "7", subject: "DMGT", startTime: "15:20", endTime: "16:10", room: "E204" },
  { day: "Thursday", period: "8", subject: "DAA", startTime: "16:10", endTime: "17:00", room: "CSE 6" },

  // Friday
  { day: "Friday", period: "1", subject: "DMGT", startTime: "09:00", endTime: "09:50", room: "CSE 6" },
  { day: "Friday", period: "2", subject: "UHV", startTime: "09:50", endTime: "10:40", room: "CSE 6" },
  { day: "Friday", period: "3", subject: "P&S", startTime: "11:00", endTime: "11:50", room: "CSE 6" },
  { day: "Friday", period: "4", subject: "DAA", startTime: "11:50", endTime: "12:40", room: "CSE 6" },
  { day: "Friday", period: "5", subject: "Non Tech", startTime: "13:30", endTime: "14:20", room: "CSE 6" },
  { day: "Friday", period: "6", subject: "Non Tech", startTime: "14:20", endTime: "15:10", room: "CSE 6" },

  // Saturday
  { day: "Saturday", period: "1", subject: "Technical Skilling", startTime: "09:00", endTime: "09:50", room: "A101" },
  { day: "Saturday", period: "2", subject: "Technical Skilling", startTime: "09:50", endTime: "10:40", room: "A101" },
  { day: "Saturday", period: "3", subject: "OOPS through JAVA", startTime: "11:00", endTime: "11:50", room: "J106" },
  { day: "Saturday", period: "4", subject: "OOPS through JAVA", startTime: "11:50", endTime: "12:40", room: "J106" },
  { day: "Saturday", period: "5", subject: "UHV", startTime: "13:30", endTime: "14:20", room: "C103" },
  { day: "Saturday", period: "6", subject: "DAA", startTime: "14:20", endTime: "15:10", room: "C103" },
  { day: "Saturday", period: "7", subject: "DMGT", startTime: "15:20", endTime: "16:10", room: "C103" },
  { day: "Saturday", period: "8", subject: "UHV", startTime: "16:10", endTime: "17:00", room: "C103" }
];

const SUBJECTS = [
  "P&S",
  "Library",
  "P.E.T",
  "Technical Skilling",
  "DAA Lab",
  "OOPS through JAVA",
  "DMGT",
  "Project",
  "Applied Skilling",
  "Non Tech",
  "Foreign Lang",
  "DAA",
  "UHV"
];

async function seedQISCollegeData(rollNo) {
  try {
    // 1. Overwrite calendar if it is not QIS
    const existingCal = await Calendar.findOne({ rollNo });
    if (!existingCal || existingCal.fileName !== "QIS_Academic_Calendar_2025-2026.pdf") {
      await Calendar.deleteMany({ rollNo });
      const calendar = new Calendar({
        rollNo,
        fileName: "QIS_Academic_Calendar_2025-2026.pdf",
        extractedText: "QIS Academic Calendar Seeding",
        holidays: QIS_HOLIDAYS.map(h => `${h.date} - ${h.name}`),
        exams: QIS_EXAMS.map(e => `${e.date} - ${e.subject}`),
        semesterDates: ["Commencement of I Semester: 05-07-2025", "Commencement of II Semester: 21-11-2025"]
      });
      await calendar.save();
      console.log(`Seeded QIS Calendar for ${rollNo}`);
    }

    // 2. Overwrite timetable if it is not QIS
    const existingSessions = await Timetable.find({ rollNo });
    const needsTimetableSeed = existingSessions.length === 0 || 
                               existingSessions[0].fileName !== "QIS_CSE_6_Timetable.pdf";
    if (needsTimetableSeed) {
      await Timetable.deleteMany({ rollNo });
      const sessions = QIS_TIMETABLE.map(s => ({
        ...s,
        rollNo,
        fileName: "QIS_CSE_6_Timetable.pdf"
      }));
      await Timetable.insertMany(sessions);
      console.log(`Seeded QIS Timetable for ${rollNo}`);
    }

    // 3. Overwrite attendance if CSE subjects are missing
    const existingAttendance = await Attendance.find({ rollNo });
    const hasCseSubjects = SUBJECTS.every(sub => 
      existingAttendance.some(att => att.subject.toLowerCase() === sub.toLowerCase())
    );
    if (existingAttendance.length === 0 || !hasCseSubjects) {
      await Attendance.deleteMany({ rollNo });
      for (const subject of SUBJECTS) {
        const att = new Attendance({
          rollNo,
          subject,
          present: 15,
          total: 20
        });
        await att.save();
      }
      console.log(`Seeded initial Attendance for ${rollNo}`);
    }

    // 4. Update user setup details
    await User.findOneAndUpdate(
      { rollNo },
      {
        branch: "CSE",
        year: "2-1",
        calendarFileName: "QIS_Academic_Calendar_2025-2026.pdf",
        timetableFileName: "QIS_CSE_6_Timetable.pdf",
        currentAttendance: "75.0",
        targetAttendance: "75",
        attendedClasses: 15 * SUBJECTS.length,
        totalClasses: 20 * SUBJECTS.length,
        setupComplete: true
      }
    );
    console.log(`Updated User profile setup for ${rollNo}`);

  } catch (err) {
    console.error("Seeder failed:", err);
  }
}

module.exports = { seedQISCollegeData };
