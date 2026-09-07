import { query, insert } from "../lib/db.js";
// POST /api/jobs/:id/apply — public
export async function apply(req) { return insert("applicants", { jobId: req.params.id, ...req.body, appliedAt: new Date().toISOString() }); }
// GET /api/employers/me/applicants — employer token; returns every applicant on the employer's jobs
export async function listApplicants(req) { return query("applicants", a => a.employerId === req.employerId); }
