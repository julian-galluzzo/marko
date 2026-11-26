# [Marko](https://askmarko.xyz/)

<!-- yarkr:badges:start -->
[![Indexed on Yarkr](https://api.yarkr.com/functions/v1/api/api/v1/badges/repos/julian-galluzzo/marko/version.svg)](https://yarkr.com/arks/julian-galluzzo/marko)
<!-- yarkr:badges:end -->

A grumpy senior code reviewer for [Claude Code](https://docs.claude.com/en/docs/claude-code) and [Codex](https://github.com/openai/codex). He reviews your changes, tells you what's wrong, and never suggests fixes.

More at **[askmarko.xyz](https://askmarko.xyz/)**.

```
**Verdict:** bad

Three concurrency bugs and a log line leaking PII.

1. `src/worker.ts:42` — retry loop has no backoff; an upstream outage will hammer the service.
2. `src/worker.ts:89` — `sessionId` is compared with `==` to a request string; type confusion on integer IDs.
3. `src/auth.ts:14` — full email logged at info; move to debug or redact.
4. `src/queue.ts:110` — inner `flush()` is not awaited; writes can be dropped on shutdown.
```

## What he does

- Reviews your current `git diff`, branch diff, or recent edits.
- Returns a one-word verdict: **`catastrophe` / `bad` / `mediocre` / `ok`**.
- Lists concrete, `file:line`-anchored gripes that a coding agent can act on directly.
- Never suggests fixes. Never softens. Never pads. "ok" is the ceiling and it is rare.

The point is signal-to-noise. A review that ends "LGTM, ship it" contains no information. Marko's does.

## Install

One command, installs for both tools:

```bash
curl -fsSL https://raw.githubusercontent.com/julianmemberstack/marko/main/install.sh | bash
```

Flags:

```bash
# Just one tool
curl -fsSL https://raw.githubusercontent.com/julianmemberstack/marko/main/install.sh | bash -s -- --claude-only
curl -fsSL https://raw.githubusercontent.com/julianmemberstack/marko/main/install.sh | bash -s -- --codex-only
```

Or manually:

- **Claude Code:** copy `SKILL.md` to `~/.claude/skills/marko/SKILL.md`
- **Codex:** copy `codex/marko.md` to `~/.codex/prompts/marko.md`

<!-- yarkr:install:start -->
## Install with Yarkr

This repo is indexed on [Yarkr](https://yarkr.com/arks/julian-galluzzo/marko) as the ark [julian-galluzzo/marko](https://yarkr.com/arks/julian-galluzzo/marko), so its skills install into Claude Code, Codex, Cursor and other agent harnesses with one command.

### CLI

Install the whole ark, which Yarkr keeps equal to this repo:

```bash
npx yarkr-cli sync julian-galluzzo/marko
```

Or add individual skills:

```bash
npx yarkr-cli add skill:julian-galluzzo/marko/marko
```

No Node.js? `curl -fsSL https://yarkr.com/install.sh | sh` (macOS, Linux) or `irm https://yarkr.com/install.ps1 | iex` (Windows PowerShell) installs `yarkr` as a standalone binary; then type `yarkr` in place of `npx yarkr-cli`.

### MCP

Connect your agent to the ark over MCP:

```bash
npx yarkr-cli mcp add julian-galluzzo/marko
```

Or point any MCP client at `https://api.yarkr.com/functions/v1/api/mcp/o/julian-galluzzo/marko`.
<!-- yarkr:install:end -->

## Use

### Claude Code

Address him by name. Natural language triggers the skill:

- `marko?`
- `what do you think marko?`
- `hey marko, take a look`
- `marko thoughts on this branch?`

He picks what to review in this order: uncommitted `git diff` → branch diff → recently edited files → asks you.

You will need to restart your Claude Code session once after install so the new skill is picked up.

### Codex

Type `/marko` in a session. Same behavior, different entry point — Codex doesn't have skill auto-triggering, so it's an explicit slash command.

### Periodic reviews

Want Marko watching while you work? In Claude Code:

```
/loop 10m marko?
```

Or wire a `Stop` hook in `~/.claude/settings.json` so he chimes in after every turn.

## How it works

Marko is a prompt, not a tool. The repo contains two files:

- `SKILL.md` — the Claude Code skill. Skills are markdown with YAML frontmatter that Claude Code loads at session start. The `description` field is what Claude consults to decide when to invoke the skill, which is why Marko triggers on being addressed by name.
- `codex/marko.md` — the Codex custom prompt. Plain markdown injected into the conversation when you type `/marko`.

The two files contain the same instructions with minor framing differences (third-person "Marko does X" vs. second-person "you do X") so each tool's invocation model reads naturally.

## Design

A few deliberate choices that make Marko actually useful instead of just funny:

- **No praise inflation.** "ok" means the code is actually good. This is the point of the whole exercise — a verdict is only information if it distinguishes good from bad.
- **No suggested fixes.** Forces each complaint to stand on its own. Vague critique gets exposed when you can't hide it behind a proposed solution. Also keeps the output short.
- **`file:line` anchors on every gripe.** The output is designed to be consumed by another agent (Claude Code, Codex) that then fixes the issues. Vague complaints are useless for that; concrete ones are actionable.
- **Few words.** A reviewer who writes three paragraphs per gripe is not reviewing, they are performing.
- **No caricature.** The "grumpy senior engineer" persona exists to strip out flattery and verbosity. No accent, no stereotypes, no theatre.

## Uninstall

```bash
rm -rf ~/.claude/skills/marko ~/.codex/prompts/marko.md
```

## License

MIT. See [LICENSE](./LICENSE).
