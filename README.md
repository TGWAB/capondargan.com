# Counseling and Psychiatry on Dargan

Client Fully managed static site for **Counseling and Psychiatry on Dargan (CAPD / Cap on Dargan)** in Florence, South Carolina. Public repository, MIT License, matching the standing client-static pattern of `elsanjose.com` and `grandfathershoney.com`. Owner is `TGWAB/` because this is a business repo created after the DS §10 owner split; those two analogs remain under `MichalAFerber/`.

**Live:** [https://capondargan.com](https://capondargan.com)

This is not a TGWAB product site. Product-facing DS §1 branding, §10 link-backs, and the §17 product launch kit do not apply. Plumbing, headers, CI, one deploy path, and a canonical host still do.

## About

CAP on Dargan is a collaboration of independent psychiatry and psychology providers under one roof.

**Address:** 523 S Dargan St, Florence, SC 29506
**Phone:** [(843) 503-1235](tel:+18435031235)

### Hours

| Day | Hours |
| --- | --- |
| Weekdays | 8:00 am — 8:00 pm |
| Saturday | 9:30 am — 5:30 pm |
| Sunday | 9:30 am — 3:00 pm |

Emergency services are not available at the clinic. The homepage keeps the live Squarespace crisis copy pointing at 911 and The Carolina Center for Behavioral Health.

## Canonical host

The canonical host is **`capondargan.com`** (apex). `www.capondargan.com` 301s to it. Squarespace served `www` as canonical and `/home` as a second 200 of the homepage; the cutover keeps those URLs working with 301s:

- `https://www.capondargan.com/*` → `https://capondargan.com/:splat`
- `https://capondargan-com.pages.dev/*` → `https://capondargan.com/:splat`
- `/home` and `/home/` → `/`

That matches house Cloudflare Pages sites (`elsanjose.com`, `grandfathershoney.com`) and is recorded here so it is not reversed.

## Deploy

One repo → one Cloudflare Pages project (`capondargan-com`, TechGuyWithABeard account), deployed by **GitHub Actions** with `wrangler pages deploy`. Framework preset **None**. No build step: the repo is the output. Cloudflare's Pages Git integration is off. There is no other deploy path.

1. Open a draft pull request
2. CI (`ci` job) must pass
3. Merge to `main`
4. The deploy workflow uploads the repo root to Pages

## Mail

Google Workspace on this zone. Do not change MX, the Google SPF (`include:_spf.google.com -all`), the `google-site-verification` TXT, DKIM, or the `mta-sts-google` Worker on `mta-sts.capondargan.com`.

## Credits

| Asset | Source | License |
| --- | --- | --- |
| Manrope 400/600/700 woff2 | [Fontsource](https://fontsource.org/fonts/manrope) / [Google Fonts](https://fonts.google.com/specimen/Manrope) | SIL Open Font License 1.1 |
| Nunito Sans 400/600 woff2 | [Fontsource](https://fontsource.org/fonts/nunito-sans) / [Google Fonts](https://fonts.google.com/specimen/Nunito+Sans) | SIL Open Font License 1.1 |
| Hero photograph | Getty Images 1331029545, Drazen Zigic, previously served from the Squarespace site | Getty license held by the client; hosted first-party, not hotlinked |
| Provider illustrations, resource photos, directions background, wordmark | Previously served from the live Squarespace site | Client content; hosted first-party |

## Standards

Built to the TGWAB Dev Standards **v2.86.0** (internal). Client property, **Fully managed** tier.

### Deviations

- §2—Astro + Tailwind stack—hand-authored static HTML, no build step, matching elsanjose.com / grandfathershoney.com—2026-09-11—permanent
- §11—generated sitemap—no build step on this site, so `sitemap.xml` is maintained by hand—2026-09-11—permanent
- §14—dark mode legibility—site is light-only by client design (`color-scheme: light only`)—2026-09-11—permanent
- §1—JetBrains Mono headings—client clinic keeps the inherited Manrope / Nunito Sans pairing, self-hosted as woff2—2026-09-11—permanent
- §9—Privacy / Terms pages—client brochure site, same omission as elsanjose.com and grandfathershoney.com; not a TGWAB product—2026-09-11—permanent
- §15—npm CI template—no `package.json` because there is no Node build; `ci.yml` runs bash gates (no-eval, no mailto, headers, CDN scan) instead of `npm ci`—2026-09-11—permanent

## License

[MIT](LICENSE) © CAP on Dargan.
