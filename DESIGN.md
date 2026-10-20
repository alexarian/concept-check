---
version: alpha
name: Concept Check
description: A guided study chat that quotes a learner's own words back and checks understanding with fresh cases.
colors:
  primary: "#2F4FD8"
  neutral: "#16202A"
  paper: "#F4F6F8"
  card: "#FFFFFF"
  ink: "#16202A"
  ink-soft: "#55626E"
  line: "#D6DDE3"
  focus: "#2F4FD8"
  quote: "#FFF1CC"
  quote-ink: "#6B4B00"
  found: "#1E7A4C"
  missing: "#6B7480"
  error: "#B23A2C"
typography:
  h1:
    fontFamily: Archivo
    fontSize: 28px
    fontWeight: 800
    lineHeight: 1.2
  wordmark:
    fontFamily: Archivo
    fontSize: 20px
    fontWeight: 800
    lineHeight: 1.2
  display-case:
    fontFamily: Atkinson Hyperlegible
    fontSize: 20px
    fontWeight: 400
    lineHeight: 1.5
  quote:
    fontFamily: Atkinson Hyperlegible
    fontSize: 19px
    fontWeight: 400
    lineHeight: 1.5
  body-md:
    fontFamily: Atkinson Hyperlegible
    fontSize: 17px
    fontWeight: 400
    lineHeight: 1.6
  body-sm:
    fontFamily: Atkinson Hyperlegible
    fontSize: 14px
    fontWeight: 400
    lineHeight: 1.5
  label:
    fontFamily: IBM Plex Mono
    fontSize: 12px
    fontWeight: 500
    lineHeight: 1.4
    letterSpacing: 0.08em
rounded:
  sm: 8px
  md: 10px
  lg: 16px
  bubble: 18px
  full: 9999px
spacing:
  xs: 8px
  sm: 16px
  md: 22px
  lg: 28px
  sidebar: 272px
  thread: 760px
components:
  sidebar:
    backgroundColor: "{colors.card}"
    borderColor: "{colors.line}"
    width: "{spacing.sidebar}"
  button-new-check:
    backgroundColor: "{colors.card}"
    borderColor: "{colors.line}"
    textColor: "{colors.ink}"
    rounded: "{rounded.sm}"
  chat-list-item-active:
    backgroundColor: "{colors.paper}"
    accentColor: "{colors.focus}"
    rounded: "{rounded.sm}"
  question-bubble:
    backgroundColor: "{colors.card}"
    borderColor: "{colors.line}"
    textColor: "{colors.ink}"
    rounded: "{rounded.bubble} {rounded.bubble} 4px {rounded.bubble}"
    align: right
  answer-text:
    textColor: "{colors.ink}"
    align: left
  quote-block:
    backgroundColor: "{colors.quote}"
    textColor: "{colors.quote-ink}"
    borderLeftColor: "{colors.quote-ink}"
  composer:
    backgroundColor: "{colors.card}"
    borderColor: "{colors.line}"
    focusColor: "{colors.focus}"
    rounded: "{rounded.lg}"
  button-send:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.card}"
    rounded: "{rounded.md}"
  topic-chip:
    backgroundColor: "{colors.card}"
    borderColor: "{colors.line}"
    rounded: "{rounded.full}"
  text-link:
    textColor: "{colors.ink-soft}"
  badge-found:
    textColor: "{colors.found}"
    borderColor: "{colors.found}"
    rounded: "{rounded.full}"
  badge-not-yet:
    textColor: "{colors.missing}"
    borderColor: "{colors.missing}"
    rounded: "{rounded.full}"
  error-text:
    textColor: "{colors.error}"
---

# DESIGN.md: Concept Check

Companion to PRD-Concept-Check.md. Tokens above are the normative values; the sections below explain how to apply them. A clickable reference build is in Concept Check - UI Draft.html (AI simulated). Supersedes Concept Check - design.md, which described the earlier card layout.

## Overview

**Brand personality:** a calm, honest study partner. Not a quiz, not a game, not a teacher lecturing. It asks; it never tells.

**Audience:** no-code-track learners in the 100xEngineers C8 cohort, early in their careers, on a phone or laptop, alone, a bit unsure, and wary of looking like a beginner. The design has to feel private and low-pressure.

**Tone:** quiet, spacious, plain-spoken. Professional rather than playful. The learner's own words are the hero; the most important element anywhere in the product is their recited sentence quoted back in the follow-up message.

**Design language:** Minimal / Swiss, chosen for adult learners who need focus and readability, not decoration.

**Reference style:** the Claude chat app (claude.ai), for layout and feel, not its colours or branding. What carries over: a left sidebar with a new-chat button and the list of previous chats; one centred thread of messages; a rounded message box pinned to the bottom; generous space and quiet surrounding UI. One deliberate change from Claude: here the **app's questions sit on the right in bubbles** and the **learner's answers sit on the left as plain text** (founder decision, 2026-10-20).

**It is a guided chat, not an open one.** The app asks and the learner answers. Nothing in the UI invites the learner to ask the AI questions.

**Logo:** pending. Until a mark exists, use the wordmark "Concept Check" set in Archivo 800, in `ink`, at the top of the sidebar. No icon or symbol is defined.

**Mood board:** none supplied.

## Colors

Palette confirmed by the founder (2026-10-20). Light values are the tokens; dark values below are the same roles for dark mode.

| Token | Light | Dark | Role |
|---|---|---|---|
| `primary` / `focus` | #2F4FD8 | #8EA2FF | Send button, focus ring, active chat marker in the sidebar. The only saturated colour in normal use |
| `ink` / `neutral` | #16202A | #E6ECF2 | Main text, answers, wordmark |
| `ink-soft` | #55626E | #A6B2BE | Labels, text links, dates, the "Reading your answer…" line |
| `paper` | #F4F6F8 | #10161C | Chat background; hover and active rows in the sidebar |
| `card` | #FFFFFF | #18212A | Sidebar, question bubbles, message box, topic chips |
| `line` | #D6DDE3 | #2A3642 | Borders of bubbles, sidebar, message box, chips |
| `quote` | #FFF1CC | #3A2E10 | Background of the recited-sentence quote and quoted evidence; the draft banner |
| `quote-ink` | #6B4B00 | #F2C86A | Quote text and its left border |
| `found` | #1E7A4C | #5ACB92 | ✓ ticks, "Gap closed" badge, "GAP CLOSED" in the sidebar |
| `missing` | #6B7480 | #8C97A3 | ✗ ticks and "Not yet". Deliberately neutral grey, not red |
| `error` | #B23A2C | #F08A7A | Error text only (failed request, consent not ticked). Never used for a learner's answer |

## Typography

Typefaces confirmed in the earlier design.md.

- **Archivo (800):** the wordmark and the new-check heading.
- **Atkinson Hyperlegible (400, 700):** every message, case text, follow-up questions, and everything the learner types. Built for readability, which matters because learners read cases closely and write long answers.
- **IBM Plex Mono (500):** small uppercase labels ("A NEW CASE", "A DIFFERENT CASE · TRY 2 OF 3", "PREVIOUS CHECKS", sidebar dates and statuses, badges), letter-spaced.

Sizes: case and follow-up text 20px, quote 19px, body 17px, small text 14px, labels 12px. Case text sits at the bottom of the 20 to 22px range from the earlier design.md so it fits inside a bubble. The heading sizes, the line heights and the 0.08em label tracking are proposed starting values, not confirmed. Adjust them freely.

## Layout

- **Two columns on desktop:** sidebar 272px on the left, chat on the right.
- **Sidebar:** wordmark, "+ New check" button, "PREVIOUS CHECKS" label, scrolling list of checks (topic, then date · status), and a footer line "Saved on this device, without your name."
- **Chat:** a scrolling thread, centred, max width 760px, 28px top padding, 22px between messages. The message box is pinned to the bottom of the screen, same 760px width.
- **Question bubbles** (the app): right-aligned, up to about 600px wide (88% on phones). Text inside is left-aligned.
- **Answers** (the learner): left-aligned plain text, up to about 640px wide (92% on phones).
- **New check screen:** centred heading, one intro line, and the 7 topics as wrapping pill chips. The consent checkbox sits under the message box until this device has consented.
- **Under 820px:** one column. The sidebar becomes a drawer opened from a ☰ button in a top bar, with a dimmed backdrop.
- At least 16px side padding on phones; no horizontal scroll from 360px wide up.

## Elevation & Depth

Flat. Hierarchy comes from tone and borders, not shadows: the `paper` background, white `card` surfaces (sidebar, bubbles, message box) with a 1px `line` border. The message box gets a `focus` border and ring while typing. The quote block stands out through colour (`quote` background, `quote-ink` left border), not lift. The only shadow is the dimmed backdrop behind the mobile drawer.

## Shapes

- Question bubbles: 18px corners, with the bottom-right corner at 4px so the bubble points to the right edge.
- Message box: 16px corners. Send button: 10px.
- Sidebar buttons and rows, links, quote block: 8px.
- Topic chips and badges: fully rounded.

## Components

- **Sidebar:** white, 1px right border. Rows are borderless buttons; hover and active rows use `paper`, and the active row gets a 3px `focus` bar on its left edge.
- **+ New check:** outlined button at the top of the sidebar; starts a fresh check screen.
- **Chat list item:** topic title (one line, truncated), then a mono line with date and status ("GAP CLOSED" in `found`, "NOT YET", "NO GAP", "IN PROGRESS" in `ink-soft`).
- **Question bubble (right):** used for every app message. Can contain a mono label, case text, the quote block, the flag links, or the result checklist.
- **Answer text (left):** the learner's words exactly as typed, line breaks kept, no bubble.
- **Quote block:** "You said:" followed by the recited sentence, shown exactly as typed. Also used for quoted evidence in the result.
- **Flag links:** "This question is unclear" · "I wasn't taught this", quiet underlined `ink-soft` links under case A only. Disabled once the learner answers.
- **Thinking line:** right-aligned italic `ink-soft` text ("Reading your answer…", "Finding your sentence…") while the server works. No spinner.
- **Result:** badge (GAP CLOSED or NOT YET), one plain line, "Retries used: N of 3", then ✓/✗ rows, each with the key point and the learner's quote.
- **Message box:** auto-growing text area with a round send button. Placeholder "Type your answer…", or "Your thinking (or type "skip")" after a follow-up. Send is disabled while empty or while the app is working.
- **Finished line:** when a check ends, the message box is replaced by "This check is finished. Start a new check from the sidebar."
- **Topic chips:** pill buttons with the topic number and title.
- **Consent checkbox:** "I agree my answers are saved, without my name." under the message box on the new check screen.
- **Inline error text:** small `error` text under the message box, e.g. "Tick the box below first, so your answers can be saved." or "That didn't go through. Your answer is safe. Try again." with a Try again button.

## Do's and Don'ts

- Do put every app message on the right in a bubble, and every learner answer on the left as plain text.
- Do make the learner's own words the visual centre, especially the recited sentence in the follow-up.
- Do show quotes exactly as typed. The app never edits the learner's words.
- Do say "Not yet" and show what was missing; use neutral grey, not red.
- Do keep the whole conversation scrollable, and let previous checks reopen read-only from the sidebar.
- Do send on Enter and add a new line on Shift+Enter.
- Don't let the chat become an open AI chat: no "ask anything" placeholder, no suggestions to ask for help, no hint or "explain this" buttons.
- Don't use radio buttons, multiple choice, or quick-reply chips for answers. Chips are only for picking a topic.
- Don't show right or wrong mid-check; nothing is scored until the result message.
- Don't use avatars, typing dots, progress bars with scores, confetti, streaks or other game elements.
- Don't borrow Claude's colours, logo or branding; the reference is for layout and feel only.
- Don't say "wrong" or "incorrect", and never explain the concept in the app.
