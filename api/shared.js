// Shared helpers for both functions.
const { TableClient } = require("@azure/data-tables");

const PARTITION_KEY = "lockin";
const ROW_KEY = "state";

function tableClient() {
  return TableClient.fromConnectionString(
    process.env.DATA_CONN,
    process.env.DATA_TABLE || "lockinstate"
  );
}

// Returns true if the request carries the correct shared secret.
function authorized(req) {
  const sent = (req.headers["x-app-secret"] || "").trim();
  const expected = (process.env.APP_SHARED_SECRET || "").trim();
  return expected.length > 0 && sent === expected;
}

module.exports = { TableClient, PARTITION_KEY, ROW_KEY, tableClient, authorized };
