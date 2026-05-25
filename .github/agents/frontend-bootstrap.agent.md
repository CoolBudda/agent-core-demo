# Project: AI Knowledge Portal

## Goal

Build a scalable React frontend for an AI knowledge management platform.

The app should feel modern, fast, modular, and enterprise-grade.

Prioritize maintainability and clean architecture over quick hacks.

---

# Tech Stack

Use:

- React 19
- Vite
- TypeScript
- React Router
- Zustand for client state
- TanStack Query for server state
- Axios
- Zod for validation
- React Hook Form
- Tailwind CSS for styling

Do NOT use:

- Redux
- MobX
- Context API for global state
- Material UI
- Bootstrap

---

# Architecture

Use feature-based architecture.

Structure:

src/
  app/
  features/
  shared/
  services/
  hooks/
  layouts/
  routes/
  types/
  utils/

Each feature should contain:

- components
- hooks
- api
- types
- store

Example:

features/chat/
  components/
  hooks/
  api/
  store/
  types/

---

# Routing

Use React Router.

Create:

- public routes
- protected routes
- layout routes

Support lazy loading for pages.

---

# Styling

Use Tailwind only.

Requirements:

- responsive
- clean whitespace
- minimal enterprise aesthetic
- dark mode support
- reusable UI primitives

Avoid excessive gradients or flashy UI.

---

# State Management

Use:

- Zustand for UI/client state
- TanStack Query for async/server state

Rules:

- avoid prop drilling
- avoid excessive global state
- prefer local component state when possible

---

# API Layer

Create centralized API client.

Requirements:

- Axios instance
- interceptors
- auth token handling
- retry handling
- typed responses
- environment-based config

Structure:

services/api/
services/auth/

---

# Component Standards

Requirements:

- small reusable components
- avoid giant files
- strongly typed props
- functional components only
- hooks over class components

Prefer composition over inheritance.

---

# Forms

Use:

- React Hook Form
- Zod validation

Requirements:

- reusable form components
- typed validation schemas

---

# Error Handling

Implement:

- error boundaries
- loading states
- empty states
- toast notifications

Never leave blank screens.

---

# Performance

Requirements:

- route lazy loading
- code splitting
- memoization where beneficial
- avoid unnecessary rerenders

---

# Testing

Use:

- Vitest
- React Testing Library

Focus on:

- critical business logic
- hooks
- core UI components

---

# Code Style

Requirements:

- clean naming
- no magic strings
- no deeply nested components
- avoid massive useEffect logic
- prefer custom hooks

Keep files under 300 lines when possible.

---

# Output Expectations

Generate:

- complete folder structure
- starter components
- routing setup
- API abstraction
- auth foundation
- example feature module
- reusable UI system

Code should be production-oriented.