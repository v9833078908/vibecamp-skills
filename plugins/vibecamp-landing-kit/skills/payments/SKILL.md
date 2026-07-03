---
name: payments
description: >
  Use when a founder needs to wire a landing page's checkout to the Callisto
  payment provider using an operator-issued integration brief - embedding the
  checkout snippet, wiring the payment redirect, and running the sandbox smoke
  test before real traffic. Works on any landing (plain HTML, Next.js, Vite, Vue,
  Tilda). Triggers (RU): «подключи оплату», «настрой Callisto checkout», «вставь
  чекаут на лендинг», «обвяжи оплату на лендинге», «настрой оплату по брифу»,
  «оплата не проходит», «подключи Callisto». Triggers (EN): "wire the checkout",
  "connect payments", "payments integration", "set up Callisto checkout", "embed
  the checkout snippet", "wire up the payment redirect".
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
---

# VibeCamp · Callisto payments integration

You are leading a founder by the hand. They built the landing themselves; your
job is to wire its checkout to Callisto using ONLY the operator-issued
**integration brief** - the founder never sees a secret, never touches the
payments backend, and you never call it either.

This skill has no MCP access, no Callisto credentials, and no Metrika token. It
signs nothing and calls neither Callisto nor Metrika directly. Every fact it
acts on comes from the brief. If the brief is missing something, the answer is
always "ask the operator for a corrected brief" - never invent, infer, or work
around it.

## How to work - phase by phase

Run the blocks in order. **After each block, stop, show the founder in plain
Russian what you did, and get a "yes" before the next block.** Do not run all
blocks silently - the whole point is to lead the founder by the hand.

When a choice depends on the founder (which button is the Pay action, which
page is the thank-you page), **ask - never guess silently.** Use
`AskUserQuestion` if your runtime supports it; otherwise ask in plain text and
wait.

---

## Block 0 - Preconditions gate (STOP until satisfied)

Check for the integration brief at `.vibecamp/integration-brief.md` (or a path
the founder points you to). If it is missing or incomplete, **stop the
integration** and tell the founder to request the brief from VibeCamp - the
operator runs `register_product` and issues it.

The brief must contain all of:

1. **`productId`** - identifies the product to the backend.
2. **Publishable key** - the only credential the browser ever holds.
3. **Counter ID** - the Metrika counter for this product (8 digits).
4. **Checkout snippet** - ready-made code that builds the `/v1/checkout`
   request and the payment redirect. You embed it; you do not write it.
5. **Event contract version** - so you know which goal set applies.

Any of these missing or unclear -> stop and ask for a corrected brief. Do not
proceed on a partial brief.

### Do not rationalize past this gate

If you catch yourself about to do any of these - STOP, you are breaking the
secret boundary:

- "I'll just query the MCP for the missing key." No - this skill has no MCP
  access and never will. Ask the founder to get an updated brief from the
  operator instead.
- "The founder can SSH to the backend and get it themselves." No - Callisto
  and Metrika secrets live only in the backend. A founder with backend access
  defeats the entire point of the secret boundary.
- "I'll create the counter / goals myself in the Metrika UI to unblock." No -
  provisioning is owned by `register_product`, run by the operator. A
  self-made counter is invisible to the buyer.
- "The brief is missing a value, I'll infer or guess it." No - stop at this
  gate and ask for a corrected brief.
- "I'll hand-write the `/v1/checkout` request myself, the snippet looks
  incomplete." No - the snippet in the brief IS the verified contract. A
  hand-rolled request risks sending fields the backend does not expect (see
  Block 1) and the checkout will be rejected or, worse, silently wrong.
- "I'll ask the founder for the Callisto login/password to test faster." No -
  this skill and the founder never see or handle the Callisto password. It
  lives only in the backend.

Brief in hand and complete - continue. Otherwise print what is missing and
stop. **Check-in:** confirm with the founder that the brief is the one issued
for this exact product, before touching any code.

---

## Block 1 - Embed the checkout snippet

Find the Pay action in the landing (the button/form that starts payment) -
confirm it with the founder if it is not obvious, do not guess. Embed the
checkout snippet from the brief there, unmodified.

The snippet already does everything required:

- Fires `vc_pay_intent` on submit.
- Captures the Metrika ClientID via `getClientID` with a 300ms timeout.
- Reads UTM params and `yclid` from the URL query string.
- Builds the `POST /v1/checkout` request and attaches an `Idempotency-Key`
  header.

**Confirmed contract (for your own verification, not for you to reimplement):**
`/v1/checkout` accepts, in the JSON body, ONLY `publishableKey`, optional
`clientId`, optional `yclid`, optional `utm` (object) - plus the
`Idempotency-Key` header. It explicitly does NOT accept `productId` and does
NOT accept an amount; the amount is resolved server-side from the product
record tied to the publishable key. If the snippet you were given sends
anything else in that body, stop and flag it to the founder - it does not
match the verified contract and should not be patched locally.

Your job here is placement and wiring, not authorship: drop the snippet at the
Pay action, make sure it fires on submit, and do not alter the request it
builds.

**Check-in:** show the founder where the snippet went and that `vc_pay_intent`
fires on submit, before wiring the redirect.

---

## Block 2 - Wire the redirect

Wire the Pay action's success path to redirect the browser to
`authorizationUrl` from the checkout response. The snippet's
`vcBuildRedirectUrl` helper appends the payment-method query params for you:

- `?useSbp=true` for SBP.
- `?payType=Sber&deviceType=<Desktop|Mobile>` for SberPay (device type is
  auto-detected from the user agent - do not hardcode it).

The post-payment return page (`/pay/return`) is a static thank-you page and
must fire NOTHING client-side. This is not a placeholder to fill in later -
the contract forbids a client-side `vc_payment`. Payment truth arrives only
through the provider webhook to the backend; the browser never confirms
payment on its own authority.

**Check-in:** show the founder the redirect wiring and confirm the thank-you
page is inert, before the smoke test.

---

## Block 3 - Smoke test (two-sided)

This step needs the operator - it cannot be completed by the skill alone.

1. The founder (or you, on their behalf) asks the operator for a test invoice.
2. The operator runs `create_test_invoice` and hands back a FRESH
   `authorizationUrl`. Never reuse a URL copied from the brief or from an
   earlier test - invoice URLs expire.
3. The founder opens that URL and completes the hosted payment with the
   provided test card.
4. Check in with the operator, who runs `verify_test_payment` and confirms
   payment + conversion evidence back to you.

What THIS skill verifies, on the client side only:

- `vc_pay_intent` fired - visible via `?_ym_debug=1` or the equivalent debug
  view.
- The checkout `POST` succeeded: `200` with `orderId` and `authorizationUrl`
  in the response.
- The redirect actually lands on the hosted payment page.

Do not claim more than this. Whether the payment itself was accepted and
whether the conversion reached Metrika/Direct is the operator's confirmation
from `verify_test_payment`, not something this skill can see or assert.

**Check-in:** report the client-side checks above, and relay the operator's
`verify_test_payment` result, before the client-side checklist.

---

## Block 4 - Client-side checklist

- Counter tag installed on every page. Delegate the tag mechanics to skill
  `analytics-metrika` - do not reimplement counter installation here.
- Applicable goals placed with the exact canonical names from the brief - no
  renaming, no aliasing.
- No client-side `vc_payment` anywhere in the codebase.
- Thank-you page (`/pay/return`) is inert - fires nothing.

**Out of scope for this skill:** server-side configuration - Callisto
callback/return URL registration, webhook handling - is verified by the
operator via `verify_integration`, NOT by this skill. This skill has no way to
check server-side wiring and must not claim it works.

**Check-in:** walk the founder through the checklist above before the report.

---

## Block 5 - Report

Generate a report from `${CLAUDE_PLUGIN_ROOT}/shared/report-template.md` and
hand it to the founder. Fill in the payment-specific evidence:

- The checkout snippet's location and that `vc_pay_intent` fires on submit.
- The redirect target and that the thank-you page is inert.
- The client-side smoke-test results from Block 3, with the operator's
  `verify_test_payment` confirmation reported as the operator's word, not this
  skill's own claim.
- `vc_payment` stays server-side, confirmed only by the operator - never claim
  payment success on this skill's own authority.
- Any open risks (e.g. brief fields that felt ambiguous, elements the founder
  had to confirm manually).

---

## Language

Reply to the founder in Russian. All explanations, prompts, check-ins, and the
final report go to a Russian-speaking founder - write them in Russian. Keep
code, event names (`vc_*`), and technical terms in English.
