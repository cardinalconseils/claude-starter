import { listJobs, createJob } from "./routes/jobs.js";
import { apply, listApplicants } from "./routes/applicants.js";
export const routes = { listJobs, createJob, apply, listApplicants };
