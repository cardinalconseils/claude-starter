import test from "node:test";
import assert from "node:assert/strict";
import { total } from "../src/total.js";

test("total of an empty cart is 0", () => {
  assert.equal(total([]), 0);
});

test("total sums amounts", () => {
  assert.equal(total([{ amount: 5.5 }, { amount: 4.5 }]), 10);
});
