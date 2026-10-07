# CLAUDE.md

How we write code at Tern, scoped to this app.

This is a small Rails app used as the starting point for a pair-programming
interview. Keep changes simple, idiomatic, and easy to read. Prefer plain Rails
over abstractions — reach for a new pattern only when the code genuinely calls
for it, not preemptively.

## Stack

- Ruby 4.0.5, Rails 8.1, PostgreSQL 18
- Hotwire (Turbo + Stimulus) with import maps; Propshaft for assets
- Tailwind CSS via `tailwindcss-rails`
- Minitest + fixtures for tests
- Authentication is session-based and hand-rolled (`has_secure_password`,
  `current_user`) — no Devise. Leave it that way unless asked.

## Code style

We follow [standardrb](https://github.com/standardrb/standard). Match its
defaults rather than inventing a house style:

- Double-quoted strings, 2-space indentation, no frozen-string pragma needed.
- Use Ruby idioms: `?` suffix for predicates, `!` for mutating/bang methods.
- `do`/`end` for multi-line blocks, `{ }` for one-liners.
- Multi-line hashes and arrays: one element per line.

Naming and structure:

- Names should reveal intent — descriptive but not verbose. Spell out variables
  (`task`, not `t`).
- Prefer keyword arguments over positional ones, and use the `foo:` shorthand
  when the local matches the parameter. Avoid `**options` splats — they hide the
  real API.
- Memoize with an `@_`-prefixed ivar: `@_user ||= User.find(...)`.
- Namespace classes with a flat declaration (`class Tasks::Export`), not nested
  `module` blocks.

Comments:

- Default to none — let the code read clearly on its own.
- When you do comment, explain the *why* (a non-obvious workaround, a business
  rule, a security reason), never the *what*.

Don't add code that isn't used yet — no methods, scopes, or helpers without a
caller in the same change.

## Rails conventions

- **Controllers** stay RESTful and thin. Use `before_action` for auth and
  shared setup. Permit params explicitly with
  `params.require(:task).permit(...)`. Handle both the success and failure
  branches of a save — don't leave the failure path empty.
- **Models** hold validations, associations, and scopes. Keep callbacks to a
  minimum; prefer explicit calls from the controller or a service.
- **Views** are ERB. Pull repeated markup into partials
  (`tasks/_form.html.erb`) and style with Tailwind utility classes inline. Put
  view logic in helpers, not in the template.
- When business logic outgrows a controller action or model, extract a plain
  service object (`SomeService.call(user:, params:)`) rather than fattening the
  controller. Keep it to what the task needs — don't build a framework.

## Testing

- Write Minitest tests under `test/` for behavior you add or change; cover both
  the happy path and the failure path.
- Use fixtures (`test/fixtures/*.yml`) for data; keep them minimal and valid by
  default.
- Test through the public interface — never reach into private methods, and
  don't test framework configuration.
- Prefer real objects over mocks in the happy path; reserve stubs for external
  services and hard-to-reach edge cases.
- Run the suite with `bin/rails test` before opening a PR.

## Git & PRs

- Never commit directly to `main`. Branch, then open a PR.
- For this exercise the base branch is `dave`, not `main`: cut every branch and
  worktree from `dave`, and open every PR against it
  (`gh pr create --base dave`).
- Keep PRs small and focused on one logical change.
- Write a description that says what changed and how to verify it (the manual
  steps a reviewer should take). Self-review the diff before requesting review.
