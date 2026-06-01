---
sitemap: false
search: false
---

# CLAUDE.md — Debanjan Das Academic Website

## Overview

Jekyll-based academic website hosted on GitHub Pages at **https://debanjan-econpolicy.github.io**.
Repository: `debanjan-econpolicy/debanjan-econpolicy.github.io` (branch: `master`).
Theme: `mmistakes/minimal-mistakes` (loaded via `remote_theme` in `_config.yml`).

---

## Site Structure

### Navigation (in order)
| Label | URL | Source file |
|---|---|---|
| Publications | `/publications/` | `_pages/publications.html` |
| Conference | `/conference/` | `_pages/talks.md` |
| Resources | `/resources/` | `_pages/resources.md` |
| Teaching | `/teaching/` | `_pages/teaching.html` |
| CV | `/cv/` | `_pages/cv.md` |
| Get in touch | `/contact/` | `_pages/contact.md` |

Navigation config: `_data/navigation.yml`

### Key Directories

```
_pages/         Individual pages (about, cv, contact, publications, etc.)
_publications/  One .md file per working paper/publication
_teaching/      One .md file per course taught
_talks/         Empty — Conference page is manually maintained in _pages/talks.md
_portfolio/     Empty — portfolio feature not used
_posts/         Empty — blog feature removed
_data/          navigation.yml, ui-text.yml, authors.yml, cv.json
_includes/      Theme partials (do not edit unless customising the theme)
_layouts/       Theme layouts (do not edit unless customising the theme)
_sass/          Theme styles (do not edit unless customising the theme)
assets/         CSS, JS, fonts, webfonts
files/          PDFs served directly (papers, slides, CV)
images/         Site images (profile.jpg, favicons, site-logo.png)
scripts/        cv_markdown_to_json.py, update_cv_json.sh (CV JSON helpers)
```

### Files served at `/files/`
- `Debanjan_CV.pdf` — current academic CV (linked from `/cv/` and `/about/`)
- `paper1.pdf`, `paper2.pdf`, `paper3.pdf` — working paper PDFs
- `slides1.pdf`, `slides2.pdf`, `slides3.pdf` — presentation slides
- `bibtex1.bib` — BibTeX file

---

## Content Files

### Publications (`_publications/`)
Each file uses `collection: publications` and `category: manuscripts`.

| File | Title |
|---|---|
| `2024-conditional-loan-subsidies.md` | Impact of Conditional Loan Subsidies on SME Performance |
| `2024-data-quality-interviewer-training.md` | Data Quality and Autonomy-Supportive Agentic Feedback |
| `2024-honesty-enterprise-performance.md` | Does Honesty Pay? Dishonesty and Enterprise Performance |
| `2024-neff-rural-enterprises.md` | Post-Pandemic Resilience: NEFF Impact on Rural Enterprises |

### Teaching (`_teaching/`)
| File | Course |
|---|---|
| `2024-01-microeconomics.md` | Microeconomics |
| `2024-02-social-network-analysis.md` | Social Network Analysis |

### Conference page (`_pages/talks.md`)
Manually maintained markdown file at permalink `/conference/`. Lists conference presentations by year. **Do not use `_talks/` collection** — that directory is intentionally empty.

---

## How to Update the Site

### Add a new publication
Create `_publications/YYYY-title-slug.md` with this frontmatter:
```yaml
---
title: "Full Paper Title"
collection: publications
category: manuscripts
permalink: /publication/YYYY-title-slug
excerpt: 'One-sentence summary shown in the publications list.'
layout: single
---
```
Then add the body (Status, Abstract, Keywords, links to PDF/slides).

### Add a conference presentation
Edit `_pages/talks.md` directly. Add a bullet under the relevant year heading.

### Update the CV
Replace `files/Debanjan_CV.pdf` with the new version (keep the same filename). No other changes needed — both `/cv/` and the About page link to this file.

### Update the About page
Edit `_pages/about.md` (permalink `/`).

### Update navigation
Edit `_data/navigation.yml`.

---

## Deployment

GitHub Pages auto-builds on every push to `master`. No CI workflow is set up.

```bash
git add <files>
git commit -m "message"
git push origin master
```

Git identity for this repo:
- `user.email = f2101@irma.ac.in`
- `user.name = Debanjan Das`

---

## Visual Design (June 2026)

Custom styling lives in `_sass/_custom.scss`, imported at the end of `assets/css/main.scss`.

- **Font** — Inter (Google Fonts, loaded in `_includes/head/custom.html`)
- **Accent color** — `#1a6fa0` (rich academic blue); dark variant `#0d4f8c`
- **Masthead** — 3px solid blue bottom border
- **Section headings** — `h2` gets a 2px blue underline
- **Publications page** — card layout with left accent border, "Working Paper" badge, hover lift effect; defined in `_pages/publications.html`
- **About page** — styled intro highlight box, research interest pill badges, education list with icons; defined in `_pages/about.md` using `.intro-highlight`, `.badge`, `.edu-item` CSS classes

To change the accent color, edit the `$accent` variable at the top of `_sass/_custom.scss`.

---

## CV

`files/Debanjan_CV.pdf` is the live CV file. It is linked from:
- `/cv/` page (`_pages/cv.md`) — "Download CV (PDF)" button
- `/` About page (`_pages/about.md`) — inline text link

To update: replace `files/Debanjan_CV.pdf` with the new file (keep the same filename) and push.

---

## Google Search Console & SEO

- **Verification file**: `google641d2ce753795607.html` (root of repo, must not be deleted)
- **Verification meta tag**: `google_site_verification: google641d2ce753795607` in `_config.yml`
- **Sitemap**: auto-generated by `jekyll-sitemap` at `/sitemap.xml` — submitted to Google Search Console
- **robots.txt**: `robots.txt` in root, points crawlers to the sitemap
- **CLAUDE.md** is excluded from sitemap and search via `sitemap: false` / `search: false` frontmatter

---

## Cleanup History (June 2026)

The following template/demo content was removed to clean up the repo:

- **Blog feature** — removed all `_posts/` demo files, `_drafts/`, `_pages/year-archive.md`, `tag-archive.html`, `category-archive.html`, and "Blog Posts" nav entry
- **Demo pages** — `archive-layout-with-content.md`, `markdown.md`, `non-menu-page.md`, `page-archive.html`, `collection-archive.html`, `portfolio.html`, `talkmap.html`
- **Demo talks** — 4 placeholder files from `_talks/`
- **Demo portfolio** — 2 placeholder files from `_portfolio/`
- **Demo comments** — `_data/comments/` (Staticman demo data)
- **Demo images** — stock photos, image-alignment test images, theme previews
- **Dev tooling** — `talkmap.ipynb`, `talkmap.py`, `markdown_generator/`, `Dockerfile`, `docker-compose.yaml`, `package.json`
- **Stale GitHub Actions** — `scrape_talks.yml` workflow and issue templates
