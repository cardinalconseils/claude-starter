import test from "node:test";
import assert from "node:assert/strict";
import { listJobs } from "../src/routes/jobs.js";
test("listJobs returns an array", async () => { assert.ok(Array.isArray(await listJobs({}))); });
