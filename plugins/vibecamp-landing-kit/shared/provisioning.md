# VibeCamp — Counter Provisioning (operator runbook)

Audience: the VibeCamp operator who owns the shared Metrika account. NOT the
founder, and NOT the `analytics-metrika` skill. This is the step that produces a
"properly provisioned Counter ID" — a counter on the shared account **with the 5
standard goals already created on it**. Run it once per project, before the Counter
ID is handed to the founder.

Why it matters: `reachGoal` sends an event even when the goal does not exist on the
counter. So a landing can look fully wired in `?_ym_debug=1` while the cabinet
counts zero conversions. The only thing that makes a goal count is its prior
existence in the counter. Skipping this step is the #1 silent failure.

## Goals to create (exact identifiers — never rename)

Type for all: **JavaScript event** (Метрика: «JavaScript-событие»). The goal's
identifier must equal the name exactly. Source of truth: `event-contract.md`.

| Goal name           | Suggested display name |
|---------------------|------------------------|
| `vc_cta_click`      | VC · CTA click         |
| `vc_lead`           | VC · Lead              |
| `vc_checkout_start` | VC · Checkout start    |
| `vc_pay_intent`     | VC · Pay intent        |
| `vc_payment`        | VC · Payment           |

`vc_payment` is also created here as a JavaScript-event goal slot, even though it
is never fired from the browser — the **payments backend** fills it via offline
conversion upload by ClientID. Create it now so the slot exists. Provisioning
itself (the counter + the applicable goal subset) is now performed by the
backend's `register_product` tool, run by the VibeCamp operator - not by a human
working through the "Manual procedure (cabinet)" section below.

## Manual procedure (cabinet — use now)

1. Create the counter on the shared VibeCamp account. Name it per `naming.md`:
   `VC · <project-slug> · <primary-domain>`. Add the landing's domain.
2. Open the counter → **Settings (Настройки) → Goals (Цели)**.
3. For each of the 5 rows above: **Add goal (Добавить цель)** →
   - Name: the display name from the table.
   - Type (Тип условия): **JavaScript event (JavaScript-событие)**.
   - Identifier (Идентификатор цели): the exact `vc_*` name. No spaces, no typos.
   - Save.
4. Confirm all 5 goals are listed and active.
5. Hand the **Counter ID** (8 digits) to the founder. The founder needs nothing
   else from the cabinet.

A goal-name typo here breaks optimization silently and is invisible to the founder.
Copy-paste the identifiers from the table, do not type them.

## Automation (target — Management API)

The end state is API provisioning so no one touches the cabinet: register project
→ API creates the counter → API creates the 5 goals → return Counter ID. Yandex
Metrika exposes this via the Management API (`https://api-metrika.yandex.net`):

- create counter: `POST /management/v1/counters`
- create goal:    `POST /management/v1/counter/{counterId}/goals`

JavaScript-event goals are created with the goal `type` set to the action/JS-event
variant and the identifier equal to the `vc_*` name. Confirm the exact payload
against the current official docs before scripting — the goal-type field naming has
changed across API versions, so do not hardcode from memory.

Docs: https://yandex.ru/dev/metrika/en/management/

Until this script exists, the manual procedure above is the source of truth. Every
Counter ID issued to a founder MUST have passed step 4.
