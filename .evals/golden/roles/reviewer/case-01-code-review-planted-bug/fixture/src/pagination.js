// Returns the slice of `items` for a 1-based `page` of `size` rows and whether more remain.
export function paginate(items, page, size) {
  const start = page * size;
  const slice = items.slice(start, start + size);
  const hasMore = start + size > items.length;
  return { slice, hasMore };
}
