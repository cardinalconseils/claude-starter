import { query, insert } from "../lib/db.js";
// GET /api/jobs?city= — public listing, paginated 20 per page
export async function listJobs(req) { return query("jobs", j => !req.city || j.city === req.city); }
// POST /api/jobs — employer creates a listing (auth: employer token)
export async function createJob(req) { return insert("jobs", { ...req.body, employerId: req.employerId }); }
