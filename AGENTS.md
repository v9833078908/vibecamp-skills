# VibeCamp Skills (marketplace)

> **Part of the i-Free boost product.** This repo is the *published marketplace* half
> (installed by founders via `claude plugin marketplace add v9833078908/vibecamp-skills`).
> The other half — the payments backend, the MCP server it calls, and all design/plan
> docs — lives at `/Users/eli/Documents/PythonProjects/i-Free boost/` (read its
> `CLAUDE.md` first). The `payments` skill here works from an operator-issued
> integration brief; it never calls that backend's MCP tools, signs Callisto requests,
> or holds secrets. This repo stays in the Obsidian vault as its
> own git repo — commit here, do not relocate it.

Internal package that wraps a founder's landing page before traffic is poured on
it: analytics, contract goals, payments, ad-cabinet linkage — all to one VibeCamp
standard so the buyer sees every project in one place.

The founder builds the landing; the agent runs these skills against it. The
platform owns the standard (shared Metrika account, goal contract); the founder
owns the landing code and just receives a Counter ID.

## Layout

```
.claude-plugin/marketplace.json        # marketplace registry
plugins/vibecamp-landing-kit/          # the plugin
├── .claude-plugin/plugin.json         # plugin manifest
├── shared/                            # source of truth (governance)
│   ├── event-contract.md              #   locked goal names — never rename
│   ├── naming.md                      #   counter naming, UTM standard
│   ├── provisioning.md                #   operator runbook: create counter + goals
│   └── report-template.md             #   what the agent hands back
└── skills/
    └── analytics-metrika/SKILL.md     # Metrika counter + contract goals  [ready]
```

## Skills

Skill folder names are semantic (no numeric prefixes). Pipeline order lives here,
not in the names.

| Order | Skill              | Status | Purpose |
|-------|--------------------|--------|---------|
| 1     | `preflight`        | todo   | Single gate collecting all preconditions |
| 2     | `analytics-metrika`| ready  | Metrika counter + contract goals + ClientID/UTM |
| 3     | `ads-direct`       | todo   | Yandex Direct linkage |
| 3     | `payments`         | ready  | Payment provider, fake → live, `vc_pay_intent` |
| 4     | `verify`           | todo   | End-to-end check + final report to the buyer |

Run order: `preflight` → `analytics-metrika` → (`ads-direct`, `payments`) → `verify`.

## Rule for skill authors

Core Agent Skills format: YAML `name` + `description`, then imperative markdown.
`SKILL.md` body under 500 lines; reference shared files via `${CLAUDE_PLUGIN_ROOT}`.
Keep it portable across Claude Code / Codex / Cursor — avoid context-forking and
subagents (not every runtime understands them). `allowed-tools` is permitted
(widely supported) and may declare the tools a skill uses.

- `name`: semantic, hyphenated, no numeric prefix (the folder name is the
  registered skill name).
- `description`: third person, lead with when-to-use triggers + keywords (RU and
  EN). Do NOT summarize the internal workflow — a workflow summary makes the agent
  follow the description and skip reading the body (shallow execution).
- Discipline blocks (gates): state the rule AND close the loopholes — list the
  rationalizations the agent must not use to skip the gate.
- Lead the user by the hand: run phase by phase with a check-in after each block,
  ask (don't guess) when a choice depends on the user.
