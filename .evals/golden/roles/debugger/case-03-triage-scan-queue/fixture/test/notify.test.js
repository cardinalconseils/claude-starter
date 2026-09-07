import test from "node:test";
import assert from "node:assert/strict";
import { formatDate } from "../src/notify.js";
test("formatDate handles an empty value", () => {
  assert.equal(formatDate(""), "");
});
