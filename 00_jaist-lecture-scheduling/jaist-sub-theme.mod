/*********************************************
 * OPL 12.10.0.0 Model
 * Author: User
 * Creation Date: 2024/05/18 at 11:00:00
 * Corrected Date: 2024/05/18 (Fourth Correction)
 *********************************************/

using CP;

// --- Data Declaration ---

// Set of Lecture IDs (Course Codes)
{string} Lectures = ...;

// Tuple definition for schedule entries
// lectureId, date, day, period
tuple ScheduleTuple {
  string lectureId;
  string date;
  string day;
  string period;
}
// Set of schedule entries (only those used for conflict checking)
{ScheduleTuple} ScheduleEntries = ...;

// --- Data Preprocessing ---

// Identify unique time blocks (date + period)
tuple TimeBlockTuple {
  string date;
  string period;
}
{TimeBlockTuple} TimeBlocks = { <s.date, s.period> | s in ScheduleEntries };

// Map of time blocks occupied by each lecture
{TimeBlockTuple} BlocksForLecture[l in Lectures] =
  { <s.date, s.period> | s in ScheduleEntries : s.lectureId == l };

// Identify sets of lectures belonging to each category
// If a lecture spans multiple days, it belongs to all relevant categories
{string} LecturesInCatSat = { s.lectureId | s in ScheduleEntries : s.day == "土" }; // "Sat"
{string} LecturesInCatSun = { s.lectureId | s in ScheduleEntries : s.day == "日" }; // "Sun"
{string} LecturesInCatWeekday = { s.lectureId | s in ScheduleEntries : s.day == "月" || s.day == "火" || s.day == "水" || s.day == "木" || s.day == "金" }; // "Mon", "Tue", "Wed", "Thu", "Fri"


// --- Decision Variables ---

// Whether to take each lecture (1: take, 0: do not take)
dvar boolean takeLecture[Lectures];

// --- Objective Function ---

// Maximize the total number of lectures (credits) taken
maximize
  sum(l in Lectures) takeLecture[l];


// --- Constraints ---
subject to {

  // 1. Time Conflict Constraint: Only one lecture can be taken in the same time block (date + period)
  forall(tb in TimeBlocks)
    // Label each instance of the forall constraint. The label comes BEFORE the expression, followed by a colon.
    ctConflict:
      sum(l in Lectures : tb in BlocksForLecture[l]) takeLecture[l] <= 1;

}


execute {
  // Calculate the total credits taken using scripting variables
  var totalCreditsTaken = 0;
  for(var l in Lectures) {
    if (takeLecture[l] == 1) {
      totalCreditsTaken = totalCreditsTaken + 1;
    }
  }

  writeln("--- Optimization Result ---");
  // Display the calculated total credits
  writeln("Total Credits Taken: ", totalCreditsTaken);

  writeln("Selected Lectures:");
  var count = 0;
  for(var l in Lectures) {
    if (takeLecture[l] == 1) {
      write(l, " ");
      count++;
      if (count % 10 == 0) writeln(); // New line every 10 items
    }
  }
  writeln();

  // Calculate category sums within the script using .contains() method
  var satCreditsTaken = 0;
  for(var l in Lectures) {
     // Use .contains() for set membership check in scripting
     if (LecturesInCatSat.contains(l) && takeLecture[l] == 1) {
        satCreditsTaken = satCreditsTaken + 1;
     }
  }
  var sunCreditsTaken = 0;
  for(var l in Lectures) {
     // Use .contains() for set membership check in scripting
     if (LecturesInCatSun.contains(l) && takeLecture[l] == 1) {
        sunCreditsTaken = sunCreditsTaken + 1;
     }
  }
  var weekdayCreditsTaken = 0;
  for(var l in Lectures) {
     // Use .contains() for set membership check in scripting
     if (LecturesInCatWeekday.contains(l) && takeLecture[l] == 1) {
        weekdayCreditsTaken = weekdayCreditsTaken + 1;
     }
  }
}