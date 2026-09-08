export function exportApplicants(rows) {
  return rows.map(r => `${r.name},${r.email}`).join("\n");
}
