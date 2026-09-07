export function total(lines) {
  return lines.reduce((sum, line) => sum + line.amount);
}
