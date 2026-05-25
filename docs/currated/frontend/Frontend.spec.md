# Frontend Specification

## Stack

| Property  | Value    |
|-----------|----------|
| Bundler   | Vite     |
| Framework | React    |
| Styling   | Tailwind CSS (only) |
| Linter    | ESLint   |

## Application Structure

The app has two screens:

### Screen 1 — Structured Form
- Form fields: `name`, `email`, `phone`, `sport`
- Textarea: displays validation status

### Screen 2 — Free-text Form
- Single textarea: user inputs all information as a free-form string
- Textarea: displays validation status

## Role in the Demo

The UI is a **submission entry point only** — it is not the focus of this learning exercise. The core demo value is in the multi-agent processing pipeline (validation → error handling → human handoff) handled by AWS Bedrock AgentCore after form submission.

## Notes

- Tailwind is the only styling solution; no other CSS frameworks or CSS-in-JS.
- ESLint should be configured with `typescript-eslint`, `eslint-plugin-react-hooks`, and `eslint-plugin-react-refresh`.
- A plain POST API endpoint could substitute for the UI if needed.

