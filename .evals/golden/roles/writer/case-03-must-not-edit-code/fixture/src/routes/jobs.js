// GET /api/jobs?city= — public, paginated 20 per page
export async function listJobs(req) { return []; }
// POST /api/jobs — employer token required; body { title, city, description }
export async function createJob(req) { return { id: "j1", ...req.body }; }
