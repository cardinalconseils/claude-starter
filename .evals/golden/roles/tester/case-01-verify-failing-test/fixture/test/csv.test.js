import test from "node:test";
import assert from "node:assert/strict";
import { toCsv } from "../src/csv.js";

test("AC-1 header only on empty input", () => {
  assert.equal(toCsv([]), "name,email,phone,job,applied_at");
});

test("AC-2 quotes values with commas and doubles inner quotes", () => {
  const out = toCsv([{ name: 'Marie "Mimi" Tremblay, CPA', email: "m@acme.example", phone: "", job: "Plombier", applied_at: "2026-09-01" }]);
  assert.equal(out.split("\n")[1], '"Marie ""Mimi"" Tremblay, CPA",m@acme.example,,Plombier,2026-09-01');
});

test("AC-1 lines end with CRLF", () => {
  const out = toCsv([{ name: "A", email: "a@x.example", phone: "", job: "J", applied_at: "2026-09-01" }]);
  assert.ok(out.includes("\r\n"));
});
