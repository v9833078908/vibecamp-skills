# VibeCamp — Integration Report Template

Filled by the agent after a skill finishes and handed back to the founder + buyer.

```
## VibeCamp integration report — <project-slug>

Skill:        <skill name>
Date:         <YYYY-MM-DD>
Landing:      <url>  (stack: HTML / Next / Vite / Vue / Tilda)
Counter ID:   <8 digits>

### Wired
- vc_cta_click       → <selector / where>
- vc_lead            → <after which form submit>
- vc_checkout_start  → <where>
- vc_pay_intent      → <where>
- vc_payment         → server-side, NOT wired here (waits for skill ads-direct)

### Linkage
- ClientID captured:  yes / no   (getClientID → hidden fields + backend)
- UTM captured:       yes / no   (utm_* + yclid → hidden fields + backend)

### Self-check (?_ym_debug=1)
- counter loads once, before content:   pass / fail
- each client goal appears in console:  pass / fail
- SPA route change sends hit:           pass / fail / n/a

### Open risks / blockers
- <e.g. CTA is an <a href> without preventDefault, SPA hit missing>

### Before paid traffic (recommendations, not blockers)
- Privacy policy page present:           yes / no  (add before launch)
- VibeCamp confirmed goals count in cabinet: yes / no

### Next step
Run skill ads-direct to link Yandex Direct (yclid, conversion optimization,
offline upload of vc_payment).
```
