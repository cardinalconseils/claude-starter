export function toCsv(rows) {
  const header = "name,email,phone,job,applied_at";
  const esc = v => {
    const s = String(v ?? "");
    return /[",\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
  };
  return [header, ...rows.map(r => [r.name, r.email, r.phone, r.job, r.applied_at].map(esc).join(","))].join("\n");
}
