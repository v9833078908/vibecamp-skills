# VibeCamp — Event Contract (Source of Truth)

These names are locked. Yandex Direct optimizes on these exact strings.
Do not rename, alias, or invent variants. Changes require platform approval.

## Client-side goals (fired from the browser)

Each is registered in Metrika as a goal of type **JavaScript event**, with the
identifier equal to the name below. The platform creates them (procedure in
`provisioning.md`); the founder's skill only fires them. A `reachGoal` for a goal
that does not yet exist on the counter is silently lost.

| Goal target         | Fire when                                      |
|---------------------|------------------------------------------------|
| `vc_cta_click`      | Click on the primary CTA button                |
| `vc_lead`           | Form submitted AND server returned OK          |
| `vc_checkout_start` | Checkout / payment screen opened               |
| `vc_pay_intent`     | "Pay" submitted (incl. fake-payment smoke test)|

## Server-side goal (NOT fired from the browser)

| Goal target  | Confirmed by            | How it reaches Metrika / Direct        |
|--------------|-------------------------|----------------------------------------|
| `vc_payment` | Payment provider webhook| Offline conversion by ClientID (21-day window) |

`vc_payment` exists as a goal slot but `reachGoal('vc_payment')` is never called
client-side. It is uploaded by the **payments backend**. The Metrika skill only
makes sure the linkage data (ClientID + UTM + yclid) is captured so that upload
is possible later.

## Linkage data (mandatory — without it nothing joins)

Every lead and every order must carry, stored on the founder's backend next to
the record:

- `ClientID` — from `ym(COUNTER_ID, 'getClientID', cb)`
- `utm_source`, `utm_medium`, `utm_campaign`, `utm_content`, `utm_term`
- `yclid` — Yandex Direct click id from the URL

## Page views

`vc_page_view` is NOT a goal — a standard Metrika hit covers it.
SPAs must fire `ym(COUNTER_ID, 'hit', location.href)` on every route change.

## reachGoal params (optional)

Goals may carry params for segmentation, but params are NOT required for the
contract. Do not block integration on them.
