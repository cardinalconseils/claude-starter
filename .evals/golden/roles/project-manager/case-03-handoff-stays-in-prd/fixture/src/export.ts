export function exportApplicants(rows: Applicant[]): string {
  // applicnt rows are serialized with the header first
  return ["name,email,applied_at", ...rows.map(r => `${r.name},${r.email},${r.appliedAt}`)].join("\n");
}
