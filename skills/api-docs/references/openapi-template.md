# OpenAPI 3.0 Template

Used by the api-docs skill when generating `docs/api/openapi.yaml`.

```yaml
openapi: 3.0.3
info:
  title: "{PROJECT_NAME} API"
  version: "1.0.0"
  description: "{PROJECT_DESCRIPTION}"
servers:
  - url: "{BASE_URL}"
    description: "Development"
paths:
  # Generated endpoints go here
components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
  schemas:
    Error:
      type: object
      properties:
        code:
          type: string
        message:
          type: string
      required: [code, message]
security:
  - bearerAuth: []
```

## Placeholders

| Placeholder | Source |
|-------------|--------|
| `{PROJECT_NAME}` | From CLAUDE.md or package.json |
| `{PROJECT_DESCRIPTION}` | From CLAUDE.md |
| `{BASE_URL}` | Auto-detected or defaults to `http://localhost:3000` |
