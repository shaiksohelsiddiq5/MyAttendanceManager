const calendarSchema = {
  type: "object",
  additionalProperties: false,
  properties: {
    semesterDates: { type: "array", items: { type: "string" } },
    exams: { type: "array", items: { type: "string" } },
    holidays: { type: "array", items: { type: "string" } },
    warnings: { type: "array", items: { type: "string" } }
  },
  required: [
    "semesterDates",
    "exams",
    "holidays",
    "warnings"
  ]
};

const timetableFields = [
  "day",
  "period",
  "subject",
  "startTime",
  "endTime",
  "room",
];

const timetableSchema = {
  type: "object",
  additionalProperties: false,
  properties: {
    sessions: {
      type: "array",
      items: {
        type: "object",
        additionalProperties: false,
        properties: {
          day: { type: "string" },
          period: { type: "string" },
          subject: { type: "string" },
          startTime: { type: "string" },
          endTime: { type: "string" },
          room: { type: "string" },
        },
        required: timetableFields,
      },
    },
    warnings: { type: "array", items: { type: "string" } },
  },
  required: ["sessions", "warnings"],
};

async function analyzeWithOllama(text, schema, instructions) {
  const cleanedText = String(text ?? "").trim();

  if (!cleanedText) {
    throw new Error("No text was extracted for local AI analysis");
  }

  const baseUrl = (process.env.OLLAMA_URL || "http://127.0.0.1:11434").replace(
    /\/$/,
    ""
  );
  const model = process.env.OLLAMA_MODEL || "gemma3:4b";

  let response;

  try {
    response = await fetch(`${baseUrl}/api/chat`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      signal: AbortSignal.timeout(120000),
      body: JSON.stringify({
        model,
        stream: false,
        format: "json",
        options: { temperature: 0, num_ctx: 16384, num_predict: 2048 },
        messages: [
          {
            role: "system",
            content: [
              instructions,
              "Extract only information explicitly supported by the OCR text.",
              "Put uncertain or unreadable details in warnings; never invent values.",
              "Return ONLY valid JSON. Do not add explanations, markdown, code fences, or text before or after the JSON.",
              "Do not return partial JSON.",
              "Every required field must be present.",
              "Every array must exist even if empty.",
              "Return a complete JSON object and nothing else.",
              "Do NOT return a JSON schema.",
              "Do NOT return type, properties, required, items, or additionalProperties fields.",
              "Return actual extracted values only.",
              `Return a JSON object matching this schema exactly: ${JSON.stringify(schema)}`,
            ].join(" "),
          },
          { role: "user", content: cleanedText.slice(0, 60000) },
        ],
      }),
    });
  } catch (error) {
    throw new Error(
      `Cannot reach local Ollama at ${baseUrl}. Start Ollama and pull ${model}.`
    );
  }

  if (!response.ok) {
    const details = await response.text();
    throw new Error(`Ollama error ${response.status}: ${details.slice(0, 200)}`);
  }

  const result = await response.json();
  const content = result.message?.content;

  if (!content) {
    throw new Error("Local AI analyzer returned an empty response");
  }

  let jsonText = String(content).trim();

  const start = jsonText.indexOf("{");
  const end = jsonText.lastIndexOf("}");

  if (start !== -1 && end !== -1 && end > start) {
    jsonText = jsonText.substring(start, end + 1);
  }

  if (jsonText.includes('"properties"') && jsonText.includes('"required"')) {
    throw new Error('Model returned JSON schema instead of extracted data');
  }

  console.log("AI RAW RESPONSE:");
  console.log(jsonText);

  try {
    return JSON.parse(jsonText);
  } catch (error) {
    throw new Error(`Invalid JSON from Ollama: ${error.message}`);
  }
}

async function analyzeCalendar(text) {
  const lines = String(text ?? "").split("\n");
  const keywords = [
    "holiday", "exam", "mid", "commencement", "instruction", "semester",
    "fest", "celebration", "sankranti", "bhogi", "sivarathri", "ugadi",
    "navami", "good friday", "jayanthi", "deepavali", "christmas", "pongal",
    "independence", "gandhi", "teachers day", "vinayaka", "milad", "dasami",
    "diwali", "public", "special", "prepar", "practical", "theory", "internal",
    "external"
  ];

  const keepIndexes = new Set();
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].toLowerCase();
    if (keywords.some(kw => line.includes(kw)) || /imidexam|iimidexam/i.test(line)) {
      keepIndexes.add(i);
      if (i > 0) keepIndexes.add(i - 1);
      if (i < lines.length - 1) keepIndexes.add(i + 1);
    }
  }

  const filteredText = lines.filter((_, idx) => keepIndexes.has(idx)).join("\n");

  const result = await analyzeWithOllama(
    filteredText + "\n\nReturn actual extracted data. Do NOT return a JSON schema, type definition, properties object, or required fields list. Return only real semester dates, exams, holidays, and warnings arrays.",
    calendarSchema,
    [
      "Analyze this academic calendar.",
      "Extract complete semester information.",
      "Extract commencement dates.",
      "Extract spell of instructions.",
      "Extract mid examinations.",
      "Extract end semester examinations.",
      "Extract all holidays with dates.",
      "Extract festival holidays.",
      "Return actual values only.",
      "Do not return OCR garbage.",
      "Do not return a JSON schema."
    ].join(" ")
  );

  const fields = ["semesterDates", "exams", "holidays", "warnings"];
  if (
    !result ||
    fields.some(
      (field) =>
        !Array.isArray(result[field]) ||
        result[field].some((item) => typeof item !== "string")
    )
  ) {
    throw new Error("Local AI returned an invalid calendar analysis");
  }

  result.holidays = (result.holidays || []).filter(
    (item) =>
      typeof item === "string" &&
      item.length > 5 &&
      !/^(Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday)/i.test(item)
  );

  return result;
}

async function analyzeTimetable(text) {
  const result = await analyzeWithOllama(
    text,
    timetableSchema,
    [
      "Analyze this weekly student timetable.",
      "Create one session for every detected class, lab, or period.",
      "Use full weekday names and preserve subject abbreviations.",
      "Use an empty string for unknown times or rooms.",
      "Do not create sessions for lunch or break periods.",
    ].join(" ")
  );

  if (
    !result ||
    !Array.isArray(result.sessions) ||
    !Array.isArray(result.warnings) ||
    result.warnings.some((item) => typeof item !== "string") ||
    result.sessions.some(
      (session) =>
        !session ||
        timetableFields.some((field) => typeof session[field] !== "string")
    )
  ) {
    throw new Error("Local AI returned an invalid timetable analysis");
  }

  return result;
}

module.exports = { analyzeCalendar, analyzeTimetable };
