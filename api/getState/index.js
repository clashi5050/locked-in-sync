const { PARTITION_KEY, ROW_KEY, tableClient, authorized } = require("../shared");

// GET /api/state  ->  { data: <stateObject|null> }
module.exports = async function (context, req) {
  if (!authorized(req)) {
    context.res = { status: 401, headers: { "Content-Type": "application/json" }, body: { error: "unauthorized" } };
    return;
  }

  try {
    const client = tableClient();
    let entity;
    try {
      entity = await client.getEntity(PARTITION_KEY, ROW_KEY);
    } catch (e) {
      // First ever read — nothing saved yet.
      if (e.statusCode === 404) {
        context.res = { status: 200, headers: { "Content-Type": "application/json" }, body: { data: null } };
        return;
      }
      throw e;
    }

    const data = entity.data ? JSON.parse(entity.data) : null;
    context.res = { status: 200, headers: { "Content-Type": "application/json" }, body: { data } };
  } catch (e) {
    context.log.error("getState failed", e);
    context.res = { status: 500, headers: { "Content-Type": "application/json" }, body: { error: e.message } };
  }
};
