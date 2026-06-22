# VibeCamp Skills

Wraps a founder's landing page to one VibeCamp standard before paid traffic, so the buyer sees every project through the same events.

The founder builds the landing and product themselves. VibeCamp hands them an
executable spec (these skills). The founder's agent runs a skill against the
landing; the platform owns the standard (shared Metrika account, the goal
contract) and manages traffic buying centrally.

## Install

### Claude Code

```bash
claude plugin marketplace add v9833078908/vibecamp-skills
claude plugin install vibecamp-landing-kit@vibecamp
```

In-app equivalent: `/plugin marketplace add v9833078908/vibecamp-skills`, then
`/plugin install vibecamp-landing-kit@vibecamp`. The marketplace name is
`vibecamp` (from `marketplace.json`); reference it with `@vibecamp`.

The repository is private — whoever installs the plugin needs read access to it
(the plugin manager clones over git, so a configured SSH key or `gh auth` is
enough).

### Codex CLI / Cursor (no plugin manager)

```bash
./install.sh
```

Copies `skills/*` into the skill directories of every detected agent
(`~/.claude/skills/`, `~/.codex/skills/`, `~/.cursor/skills/`). Run it from a
landing repo to install project-local instead.

## Skills

| Order | Skill              | Status | Purpose |
|-------|--------------------|--------|---------|
| 1     | `preflight`        | todo   | Single gate collecting all preconditions |
| 2     | `analytics-metrika`| ready  | Metrika counter + contract goals + ClientID/UTM linkage |
| 3     | `ads-direct`       | todo   | Yandex Direct linkage, offline `vc_payment` upload |
| 3     | `payments`         | todo   | Payment provider, fake → live, `vc_pay_intent` |
| 4     | `verify`           | todo   | End-to-end check + final report to the buyer |

Run order: `preflight` → `analytics-metrika` → (`ads-direct`, `payments`) → `verify`.

## The standard

`plugins/vibecamp-landing-kit/shared/` is the source of truth:

- `event-contract.md` — locked goal names (`vc_cta_click`, `vc_lead`,
  `vc_checkout_start`, `vc_pay_intent`, `vc_payment`). Never rename — the buyer
  optimizes on them.
- `naming.md` — counter naming on the shared account, UTM standard.
- `report-template.md` — the report the agent hands back after each skill.

## Preconditions (founder side)

Before running `analytics-metrika` the founder needs only:

1. A **Counter ID** issued by VibeCamp (the counter and goals are pre-created on
   the shared account — the founder never opens the Metrika UI).
2. A **privacy policy page** on the landing domain.

Everything else is done by the agent.

## Status

v0.1.0 — internal/closed. First skill (`analytics-metrika`) is ready; the rest
of the pipeline is in progress. See `AGENTS.md` for the authoring rules.
