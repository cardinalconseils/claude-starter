# Testing Strategy Reference

## The Testing Pyramid

```
         /  E2E  \          — Few, slow, high-confidence
        / Integration \     — Medium, moderate speed
       /    Unit Tests   \  — Many, fast, focused
      ──────────────────────
```

| Level | Count | Speed | What It Tests |
|-------|-------|-------|---------------|
| Unit | Many (70%+) | < 10ms each | Single functions, pure logic, transformations |
| Integration | Medium (20%) | < 1s each | Component interactions, API routes, DB queries |
| E2E | Few (10%) | < 30s each | Full user journeys through the real system |

## Unit Test Patterns

### What to Unit Test
- Pure functions (input → output, no side effects)
- Data transformations and validations
- Business logic and calculations
- State machine transitions
- Error handling branches

### What NOT to Unit Test
- Framework boilerplate (routing config, middleware wiring)
- Database queries (use integration tests)
- Third-party library internals
- Trivial getters/setters

### Pattern: Arrange-Act-Assert

```typescript
test('calculates invoice total with tax', () => {
  // Arrange
  const lineItems = [
    { quantity: 2, unitPrice: 1000 },
    { quantity: 1, unitPrice: 500 },
  ];
  const taxRate = 0.13;

  // Act
  const total = calculateInvoiceTotal(lineItems, taxRate);

  // Assert
  expect(total).toBe(2825); // (2000 + 500) * 1.13
});
```

### Pattern: Test Edge Cases

For each function, test:
1. Happy path (normal input)
2. Empty input ([], '', null, undefined)
3. Boundary values (0, -1, MAX_INT, min/max lengths)
4. Invalid input (wrong types, malformed data)
5. Error conditions (should throw / should return error)

## Integration Test Patterns

### API Endpoint Testing

```typescript
describe('POST /api/invoices', () => {
  test('creates invoice with valid data', async () => {
    const response = await request(app)
      .post('/api/invoices')
      .set('Authorization', `Bearer ${validToken}`)
      .send({ clientId: 'client-1', items: [...] });

    expect(response.status).toBe(201);
    expect(response.body.id).toBeDefined();

    // Verify side effects
    const saved = await db.invoices.findById(response.body.id);
    expect(saved).toBeTruthy();
  });

  test('rejects unauthenticated request', async () => {
    const response = await request(app)
      .post('/api/invoices')
      .send({ clientId: 'client-1' });

    expect(response.status).toBe(401);
  });

  test('validates required fields', async () => {
    const response = await request(app)
      .post('/api/invoices')
      .set('Authorization', `Bearer ${validToken}`)
      .send({}); // missing required fields

    expect(response.status).toBe(400);
    expect(response.body.error).toBe('VALIDATION_ERROR');
  });
});
```

### Database Integration Testing

- Use a real test database (not mocks)
- Reset state between tests (transactions or truncate)
- Test migrations up AND down
- Verify constraints, indexes, cascades

### Component Integration Testing

```typescript
test('form submits and updates the list', async () => {
  render(<InvoiceManager />);

  // Fill form
  await userEvent.type(screen.getByLabelText('Client'), 'Acme Corp');
  await userEvent.click(screen.getByRole('button', { name: 'Create' }));

  // Verify list updated
  expect(await screen.findByText('Acme Corp')).toBeInTheDocument();
});
```

## End-to-End Test Patterns

### What to E2E Test
- **Critical user journeys** — sign up, core action, payment
- **Cross-page flows** — multi-step forms, checkout, onboarding
- **Permission boundaries** — admin vs user access
- **Error recovery** — network failure, invalid state

### What NOT to E2E Test
- Every possible input combination (use unit tests)
- Visual styling (use visual regression tools)
- Performance benchmarks (use dedicated perf tools)

### Pattern: Page Object Model

```typescript
class InvoicePage {
  async navigate() {
    await page.goto('/invoices');
  }

  async createInvoice(client: string, amount: number) {
    await page.click('[data-testid="new-invoice"]');
    await page.fill('[name="client"]', client);
    await page.fill('[name="amount"]', String(amount));
    await page.click('[data-testid="submit"]');
  }

  async getInvoiceCount() {
    return page.locator('[data-testid="invoice-row"]').count();
  }
}
```

### Browser-Based E2E (via /cks:browse)

For Claude Code workflows, translate acceptance criteria to browser actions:

| Criterion | Browser Action |
|-----------|---------------|
| "User can create an invoice" | Navigate → click New → fill form → submit → verify in list |
| "Dashboard shows metrics" | Navigate to /dashboard → verify metric cards render with data |
| "Error message on invalid input" | Submit invalid data → verify error message visible |
| "Responsive layout works" | Resize viewport → verify layout adapts |

## Test File Naming

```
{source-file}.test.{ext}     — Unit tests (co-located)
{source-file}.spec.{ext}     — Integration tests (co-located)
e2e/{feature}.e2e.{ext}      — E2E tests (separate directory)
```

## Coverage Targets

| Project Type | Unit | Integration | E2E |
|-------------|------|-------------|-----|
| API/Backend | 80%+ | 60%+ | Critical paths |
| Frontend | 70%+ | 50%+ | Core user journeys |
| Full-stack | 75%+ | 55%+ | Both API + UI journeys |

## Test Data Management

- **Factories**: Use factory functions to create test data (not raw objects)
- **Fixtures**: Store complex test data in JSON/YAML files
- **Seeds**: Database seed scripts for integration/E2E tests
- **Cleanup**: Always clean up after tests (especially E2E)
