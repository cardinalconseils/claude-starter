export function employerReport(rows) {
  const byJob = {};
  for (const r of rows) {
    if (!byJob[r.job]) byJob[r.job] = [];
    byJob[r.job].push(r);
  }
  const lines = [];
  for (const job of Object.keys(byJob).sort()) {
    lines.push(`${job}: ${byJob[job].length}`);
  }
  return lines.join("\n");
}

export function cityReport(rows) {
  const byCity = {};
  for (const r of rows) {
    if (!byCity[r.city]) byCity[r.city] = [];
    byCity[r.city].push(r);
  }
  const lines = [];
  for (const city of Object.keys(byCity).sort()) {
    lines.push(`${city}: ${byCity[city].length}`);
  }
  return lines.join("\n");
}
