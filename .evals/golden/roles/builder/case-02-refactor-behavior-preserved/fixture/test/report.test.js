import test from "node:test";
import assert from "node:assert/strict";
import { employerReport, cityReport } from "../src/report.js";

const rows = [
  { job: "Plombier", city: "Laval" },
  { job: "Plombier", city: "Montréal" },
  { job: "Électricien", city: "Laval" },
];

test("employerReport groups by job", () => {
  assert.equal(employerReport(rows), "Plombier: 2\nÉlectricien: 1");
});

test("cityReport groups by city", () => {
  assert.equal(cityReport(rows), "Laval: 2\nMontréal: 1");
});
