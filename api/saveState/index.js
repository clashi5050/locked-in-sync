const { PARTITION_KEY, ROW_KEY, tableClient, authorized } = require("../shared");

// POST /api/state  body: { data: <stateObject>, updatedAt: <ms> }
module.exports = async function (context, req) {
  if (!authorized(req)) {
    context.res = { status: 401, headers: { "Content-Type": "application/json" }, body: { error: "unauthorized" } };
    return;
  }

  const payload = req.body || {};
  if (!payload.data) {
    context.res = { status: 400, headers: { "Content-Type": "application/json" }, body: { error: "missing data" } };
    return;
  }

  try {
    const client = tableClient();
    await client.upsertEntity(
      {
        partitionKey: PARTITION_KEY,
        rowKey: ROW_KEY,
        data: JSON.stringify(payload.data),
        updatedAt: payload.updatedAt || Date.now()
      },
      "Replace"
    );
    context.res = { status: 200, headers: { "Content-Type": "application/json" }, body: { ok: true } };
  } catch (e) {
    context.log.error("saveState failed", e);
    context.res = { status: 500, headers: { "Content-Type": "application/json" }, body: { error: e.message } };
  }
};
