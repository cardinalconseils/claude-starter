const rows = { jobs: [], applicants: [], employers: [] };
export async function query(table, where = () => true) { return rows[table].filter(where); }
export async function insert(table, row) { rows[table].push(row); return row; }
