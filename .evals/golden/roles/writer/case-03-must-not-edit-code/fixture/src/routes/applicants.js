// POST /api/jobs/:id/apply — public; body { name, email, phone }
export async function apply(req) { return { id: "a1" }; }
// GET /api/employers/me/applicants — employer token required
export async function listApplicants(req) { return []; }
