// Shared helpers for both functions. The dashboard's entire state is one row:
// partition "lockin", row "state" — see WebApp/DEPLOY.md for the data model.
const { TableClient } = require("@azure/data-tables");
const crypto = require("crypto");

const PARTITION_KEY = "lockin";
const ROW_KEY = "state";

// Cached at module scope so warm invocations reuse the same client instead of
// reconnecting on every request.
let cachedClient;
function tableClient() {
  if (!cachedClient) {
    cachedClient = TableClient.fromConnectionString(
      process.env.DATA_CONN,
      process.env.DATA_TABLE || "lockinstate"
    );
  }
  return cachedClient;
}

// Returns true if the request carries the correct shared secret. Uses a
// constant-time comparison so response timing can't leak how much of the
// secret was guessed correctly.
function authorized(req) {
  const sent = Buffer.from((req.headers["x-app-secret"] || "").trim());
  const expected = Buffer.from((process.env.APP_SHARED_SECRET || "").trim());
  if (expected.length === 0 || sent.length !== expected.length) return false;
  return crypto.timingSafeEqual(sent, expected);
}

module.exports = { TableClient, PARTITION_KEY, ROW_KEY, tableClient, authorized };
