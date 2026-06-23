const express = require("express");
const router = express.Router();

const {
  getLeavePlannerPage
} = require("../controllers/leavePlannerController");

router.get(
  "/leave-planner",
  getLeavePlannerPage
);

module.exports = router;