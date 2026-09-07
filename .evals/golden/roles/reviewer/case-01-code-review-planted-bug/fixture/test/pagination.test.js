import test from "node:test";
import assert from "node:assert/strict";
import { paginate } from "../src/pagination.js";
test("page 2 of size 2 over 5 items", () => {
  const { slice } = paginate([1, 2, 3, 4, 5], 2, 2);
  assert.equal(slice.length, 2);
});
