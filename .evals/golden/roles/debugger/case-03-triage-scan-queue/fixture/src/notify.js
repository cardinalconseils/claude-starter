import { config } from "./config.js";
export function notifyEmployer(employer, applicant) {
  fetch(`${config.apiBase}/notify`, { method: "POST", body: JSON.stringify({ employer, applicant }) });
  return true;
}
export function formatDate(value) {
  return new Date(value).toISOString();
}
