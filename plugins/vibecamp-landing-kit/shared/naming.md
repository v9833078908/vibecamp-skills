# VibeCamp — Naming & Conventions

## Metrika counter (platform-side)

Counters live on the shared VibeCamp Metrika account. The platform (API or admin)
creates them; founders never create their own. Naming so the buyer finds them in
one cabinet:

```
VC · <project-slug> · <primary-domain>
```

Example: `VC · legalbot · legalbot.ru`

## UTM standard (buyer + founder)

The buyer fills UTMs on campaigns; the landing must read and store them as-is.

| Param          | Value convention                          |
|----------------|-------------------------------------------|
| `utm_source`   | traffic source, lowercase: `yandex`, `vk` |
| `utm_medium`   | `cpc`, `cpm`, `email`                      |
| `utm_campaign` | `<project-slug>-<offer>-<geo>`            |
| `utm_content`  | creative id                               |
| `utm_term`     | keyword / placement                       |
| `yclid`        | auto-appended by Yandex Direct            |

## Goal names

Locked in `event-contract.md`. Never define campaign-specific goal names — the
buyer optimizes on the shared contract goals only.

## Who issues the Counter ID

The founder receives the Counter ID after registering the project with VibeCamp.
If automation is not yet live, the VibeCamp traffic owner issues it manually. The
counter must already carry the 5 standard goals before the ID is handed over — see
`provisioning.md` for the procedure. Contact: TODO — fill in the responsible person / channel.
