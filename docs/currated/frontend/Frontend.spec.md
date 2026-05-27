
# Frontend Specification

## Purpose
Provide a simple UI for user registration. Accepts either structured form input or free-text input, then submits to backend for agent processing.

## Stack
| Property  | Value    |
|-----------|----------|
| Bundler   | Vite     |
| Framework | React    |
| Styling   | Tailwind CSS |
| Linter    | ESLint   |

## Application Structure
- Single Screen: Free-text Form (one textarea for all user info in natural language)
- Displays validation status/results and any follow-up questions from backend.

## Notes
- UI is a submission entry point only; all extraction and validation logic is backend-driven.
- Only free-text input is required (no structured form).
- Tailwind only for styling.
- ESLint with recommended plugins.

