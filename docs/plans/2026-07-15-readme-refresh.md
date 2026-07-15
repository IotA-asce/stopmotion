# README Refresh Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the minimal repository README with accurate, professional onboarding and product documentation for Stop Motion.

**Architecture:** This is a documentation-only change. The README summarizes product capabilities from the release contract, derives setup commands from the pinned Flutter configuration and CI workflow, and links readers to the canonical product, progress, architecture, and release documents instead of duplicating them.

**Tech Stack:** Markdown, Git, Flutter 3.44.6, Dart 3.12.2.

---

### Task 1: Establish documentation facts

**Files:**
- Modify: `README.md`
- Reference: `pubspec.yaml`
- Reference: `.fvmrc`
- Reference: `docs/FINAL_STATE.md`
- Reference: `docs/DEVELOPMENT_PHASES.md`
- Reference: `.github/workflows/validate.yml`

**Step 1: Collect product and toolchain facts**

Read the release contract, development checklist, pinned Flutter version, and CI workflow.

**Step 2: Define README acceptance criteria**

The README must state the product purpose, implemented capabilities, platform requirements, local setup, verification commands, test-build handling, current release status, privacy posture, and links to canonical documentation.

**Step 3: Check claim scope**

Keep physical-device validation, production signing, store publication, and FFmpeg distribution review visible as outstanding release gates.

### Task 2: Rewrite the repository README

**Files:**
- Modify: `README.md`

**Step 1: Write the product overview and status**

Describe Stop Motion as an offline-first Flutter mobile app and identify the repository as a development preview rather than a public production release.

**Step 2: Add workflow-oriented documentation**

Document capabilities, architecture, prerequisites, setup, verification, Android tester builds, privacy, and contribution expectations with Markdown links to canonical documents.

**Step 3: Check Markdown structure**

Use a single H1, descriptive H2 sections, short paragraphs, and copyable commands. Avoid unverified badges, screenshots that do not represent real media, unsupported feature claims, and unstated licensing terms.

### Task 3: Validate and publish

**Files:**
- Modify: `README.md`
- Create: `docs/plans/2026-07-15-readme-refresh.md`

**Step 1: Inspect the rendered-source structure**

Run `rg '^#' README.md` and `git diff --check`.

Expected: Heading hierarchy is clear and no whitespace errors are reported.

**Step 2: Run relevant repository checks**

Run:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

Expected: All checks pass; the README change does not introduce source or formatting regressions.

**Step 3: Commit and integrate**

```bash
git add README.md docs/plans/2026-07-15-readme-refresh.md
git commit -m "docs: professionalize project README"
git switch main
git merge --no-ff codex/professional-readme
git push origin main
```
