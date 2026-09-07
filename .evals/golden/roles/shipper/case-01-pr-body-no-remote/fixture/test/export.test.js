import test from "node:test";
import assert from "node:assert/strict";
import { exportApplicants } from "../src/export.js";
test("exportApplicants joins rows", () => {
  assert.equal(exportApplicants([{ name: "A", email: "a@x.example" }]), "A,a@x.example");
});
