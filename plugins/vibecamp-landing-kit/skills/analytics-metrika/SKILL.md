---
name: analytics-metrika
description: >
  Use when a founder needs to wire a landing page to Yandex Metrika to the
  VibeCamp standard before paid traffic — adding analytics, conversion goals, or
  preparing a site for traffic buying. Works on any landing (plain HTML, Next.js,
  Vite, Vue, Tilda). Triggers (RU): «настрой метрику», «подключи аналитику»,
  «обвяжи лендинг событиями», «добавь цели на лендинг», «подготовь сайт к закупке
  трафика», «vibecamp метрика», «цели/события не засчитываются». Triggers (EN):
  "connect Metrika", "set up analytics", "instrument the landing", "wire landing
  events", "add conversion goals", "prepare the site for paid traffic", "goals not
  firing".
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
---

# VibeCamp · Yandex Metrika integration

You are leading a founder by the hand. They built the landing themselves; your
job is to instrument it to the VibeCamp standard so the founder **never touches
code or opens the Metrika UI**. The counter and goals already exist on the shared
VibeCamp account — the founder receives the Counter ID via the operator-issued
integration brief.

Goal names come from `${CLAUDE_PLUGIN_ROOT}/shared/event-contract.md`. They are
locked: the buyer optimizes on them. The names are also inlined below, so the
skill works even if that file is unavailable.

## How to work — phase by phase

Run the blocks in order. **After each block, stop, show the founder in plain
Russian what you did, and get a "yes" before the next block.** Do not run all four
blocks silently — the whole point is to lead the founder by the hand.

When a choice depends on the founder (which button is the main CTA, which form is
the lead form), **ask — never guess silently.** Use `AskUserQuestion` if your
runtime supports it; otherwise ask in plain text and wait.

---

## Block 0 — Preconditions gate (STOP until satisfied)

Check `.vibecamp/credentials.json` in the project root. If it is missing or
incomplete, **stop the integration**, tell the founder what is missing, and help
them get it. 90% of "it didn't work" failures are a missing or half-provisioned
Counter ID, not landing code.

The one hard precondition is a **properly provisioned Counter ID** from VibeCamp.
The counter and the goals both live on the shared VibeCamp account — the founder
creates none of it. "Properly provisioned" means two things must be true on the
VibeCamp side before you wire anything:

1. **Counter ID issued by VibeCamp** (8 digits). The founder gets it from the
   operator-issued integration brief at `.vibecamp/integration-brief.md`, produced
   when the VibeCamp operator runs `register_product` (see
   `${CLAUDE_PLUGIN_ROOT}/shared/naming.md`). Without the number, do not proceed —
   events have nowhere to go.

2. **The applicable goal subset already exists on that counter** (drawn from
   `vc_cta_click`, `vc_lead`, `vc_checkout_start`, `vc_pay_intent`, `vc_payment`).
   They are created on the VibeCamp side (see
   `${CLAUDE_PLUGIN_ROOT}/shared/provisioning.md`), NOT by this skill and NOT by
   the founder. The founder has no Metrika UI access and cannot check them —
   `register_product`'s own verification step (run by the operator) guarantees the
   applicable goals exist and are valid before the brief is issued. **Critical:**
   `reachGoal` sends the event even when no goal exists, so the landing "looks
   wired" in the debug console while the cabinet counts nothing. A missing goal is
   a silent loss, not an error.

Save the Counter ID (add the file to `.gitignore`):

```json
{
  "metrika": {
    "counter_id": "00000000"
  }
}
```

### Do not rationalize past this gate

If you catch yourself about to do any of these — STOP, you are breaking the
standard:

- "I'll use a placeholder Counter ID for now and swap it later." No — events sent
  to a wrong/placeholder ID are lost, and the founder will think it works.
- "The founder probably already has a counter — I'll just use it." Verify. Only a
  VibeCamp-issued ID lives on the shared account; a personal counter is invisible
  to the buyer.
- "I'll just create the counter / the goals myself in the Metrika UI to unblock."
  No — provisioning is owned by the platform. A self-made counter is not on the
  shared account, the buyer never sees it, and goal-name typos break optimization.
  Request the ID (with goals) instead.

Counter ID in hand and goals confirmed — continue. Otherwise print what is missing
and stop. **Check-in:** confirm the Counter ID with the founder, before touching
any code.

---

## Block 1 — Install the counter

Substitute `counter_id` from credentials for `COUNTER_ID`. The counter is
installed once, as high as possible in `<head>`, so it loads before the content.

```html
<!-- Yandex.Metrika counter -->
<script type="text/javascript">
  (function(m,e,t,r,i,k,a){
    m[i]=m[i]||function(){(m[i].a=m[i].a||[]).push(arguments)};
    m[i].l=1*new Date();
    for (var j=0;j<document.scripts.length;j++){if(document.scripts[j].src===r)return;}
    k=e.createElement(t),a=e.getElementsByTagName(t)[0],
    k.async=1,k.src=r,a.parentNode.insertBefore(k,a)
  })(window,document,"script","https://mc.yandex.ru/metrika/tag.js","ym");

  ym(COUNTER_ID, "init", {
    clickmap: true,
    trackLinks: true,
    accurateTrackBounce: true,
    webvisor: false
  });
</script>
<noscript><div><img src="https://mc.yandex.ru/watch/COUNTER_ID"
  style="position:absolute; left:-9999px;" alt="" /></div></noscript>
<!-- /Yandex.Metrika counter -->
```

**Where to insert depends on the stack. Detect the stack first.**

| Stack          | Where to install the counter                                  | Page views (hit)                          |
|----------------|---------------------------------------------------------------|-------------------------------------------|
| Plain HTML     | in `<head>` of every page (or the shared template/include)    | automatic                                 |
| Next.js        | `next/script` with `strategy="afterInteractive"` in `app/layout` | on route change: `ym(ID,'hit',location.href)` |
| Vite / React   | once in `index.html` or the root component                    | in the router on path change — `hit`      |
| Vue            | once in `index.html` / `main`, hit in `router.afterEach`      | `hit`                                      |
| Tilda          | Site settings → "More" → HTML code inserted inside HEAD       | automatic (multi-page — verify)           |

Do NOT create a `vc_page_view` goal — a page view is a standard counter hit.
For SPAs without a manual `hit`, Metrika sees only the first page.

**Check-in:** show the founder where the counter went, confirm it loads once
(Network tab / `?_ym_debug=1`), then ask before wiring goals.

---

## Block 2 — Contract goals + cross-cutting ClientID and UTM

The applicable goal subset **already exists** on the VibeCamp side. Your job is
only to **fire** them at the right places in the landing. Do not create goals in
the Metrika UI.

First, find the elements — then **confirm with the founder before wiring:** which
button is the primary CTA, which form is the lead form, where checkout opens. Do
not guess silently; ask.

Safe helper (does not lose a goal if the counter is still loading):

```js
function vcGoal(name, params){
  if (window.ym) window.ym(COUNTER_ID, "reachGoal", name, params || {});
}
```

### 2.1 `vc_cta_click` — primary CTA click
Find the main call-to-action button (hero block / "Try" / "Buy"), add the
attribute `data-vc="cta"` (more reliable than binding to classes), and wire it:

```js
document.querySelectorAll("[data-vc='cta']").forEach(function(el){
  el.addEventListener("click", function(){ vcGoal("vc_cta_click"); });
});
```
If the CTA is an `<a href>`, the goal may not send before navigation. Either bind
to `click` without leaving the page, or add a short delay / `callback`.

### 2.2 `vc_lead` — lead / contact
Fire AFTER a successful form submission (in the callback), not on click:

```js
async function submitLead(payload){
  const res = await fetch("/api/lead", { method:"POST", body: JSON.stringify(payload) });
  if (res.ok) vcGoal("vc_lead");
  return res;
}
```

### 2.3 `vc_checkout_start` — checkout opened
```js
function openCheckout(){ vcGoal("vc_checkout_start"); /* show the payment form */ }
```

### 2.4 `vc_pay_intent` — intent to pay
On card-form submit / "Pay" (also fires in fake-payment mode — the strongest
demand signal in a smoke test):
```js
function onPaySubmit(){ vcGoal("vc_pay_intent"); /* send to the payment provider */ }
```

### 2.5 `vc_payment` — NOT client-side
The goal already exists as a slot. Do NOT call it from the browser — payment is
confirmed by the provider webhook, and the server-side conversion is uploaded by
the **payments backend**. Do nothing here except note it in the report.

### 2.6 Cross-cutting ClientID and UTM (mandatory)
Without these, ads cannot be joined to payments and offline conversions cannot be
uploaded.

```js
// 1) Metrika ClientID → hidden fields on all forms + send to backend with the lead/order
ym(COUNTER_ID, "getClientID", function(clientID){
  document.querySelectorAll("input[name='vc_client_id']").forEach(function(i){ i.value = clientID; });
  window.__vcClientId = clientID;
});

// 2) UTM + yclid from the URL → sessionStorage + hidden fields
(function(){
  var p = new URLSearchParams(location.search), utm = {};
  ["utm_source","utm_medium","utm_campaign","utm_content","utm_term","yclid"]
    .forEach(function(k){ if (p.get(k)) utm[k] = p.get(k); });
  try { sessionStorage.setItem("vc_utm", JSON.stringify(utm)); } catch(e){}
  Object.keys(utm).forEach(function(k){
    document.querySelectorAll("input[name='vc_"+k+"']").forEach(function(i){ i.value = utm[k]; });
  });
})();
```

Into every lead/payment form add hidden fields: `vc_client_id`, `vc_utm_source`,
`vc_utm_medium`, `vc_utm_campaign`, `vc_utm_content`, `vc_utm_term`, `vc_yclid`.
The founder's backend stores them next to the lead/order — this is the contract
linkage.

**Check-in:** list each goal and where you attached it; confirm with the founder
before the self-check.

---

## Block 3 — Self-check (do not hand off until green)

1. Open the landing with `?_ym_debug=1` → goal sends are visible in the console.
2. The counter loads once (no duplicates), before the main content.
3. Click the CTA, submit a form, open checkout, press "pay" → the debug console
   shows `vc_cta_click`, `vc_lead`, `vc_checkout_start`, `vc_pay_intent`.
4. The submitted form actually carries `vc_client_id` and `vc_utm_*` values.
5. For SPAs: navigation between screens sends a `hit` (page views grow).

Common breakages: a goal fires before the counter loads; curly quotes instead of
straight `'` after copying from an editor — the code silently fails; `reachGoal` on
an `<a href>` without a delay, and navigation leaves the page before the send;
ad/antivirus blockers strip the counter.

The founder needs no Metrika access to verify the CODE: `?_ym_debug=1` shows each
`reachGoal` was SENT. But a sent event is not a counted goal — that the goal is
REGISTERED and counting is only visible to VibeCamp in the shared cabinet. If
VibeCamp sees events arriving but zero goal conversions, the goal was never created
on the counter (provisioning gap, not a code bug) — see
`${CLAUDE_PLUGIN_ROOT}/shared/provisioning.md`.

---

## Block 4 — Report

Generate a report from `${CLAUDE_PLUGIN_ROOT}/shared/report-template.md` and hand
it to the founder: Counter ID, which goals are wired and where, that `vc_payment`
is server-side and uploaded by the payments backend, ClientID/UTM linkage status,
self-check result, open risks.

Point to the next step: skill `ads-direct` — Yandex Direct linkage (yclid,
conversion optimization).

---

## Before paid traffic (pre-launch recommendations)

These are NOT needed to instrument or test the landing — do NOT gate the
integration on them. Surface them at hand-off, as the last thing before traffic is
bought:

- **Privacy policy page.** Metrika collects behavioral data; before paid traffic
  reaches real users, the landing needs a privacy policy page (a dedicated URL like
  `/privacy`), plus consent if it collects contacts. Recommend the founder add it
  before launch — it is a legal requirement once real users arrive, not a dev-time
  blocker.
- **Confirm goals count in the cabinet.** Ask VibeCamp to verify the test events
  registered as conversions on the shared counter. This is the only proof the goals
  were provisioned — the founder's debug console cannot show it.

---

## Language

Reply to the founder in Russian. All explanations, prompts, check-ins, and the
final report go to a Russian-speaking founder — write them in Russian. Keep code,
event names (`vc_*`), and technical terms in English.
