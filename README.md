# Debanjan Das — Academic Website

Personal academic website for **Debanjan Das**, Ph.D. Candidate in Development Economics at IRMA and Research Associate at IIM Ahmedabad.

**Live site:** https://debanjan-econpolicy.github.io  
**Repository:** https://github.com/Debanjan-econpolicy/debanjan-econpolicy.github.io  
**Branch:** `master` (auto-deploys via GitHub Pages)

---

## Technology Stack

| Layer | Choice |
|---|---|
| Static site generator | Jekyll (via GitHub Pages) |
| Remote theme | `mmistakes/minimal-mistakes` (kept for config, not for visual rendering) |
| Custom layout | `_layouts/custom-page.html` — standalone HTML used by all inner pages |
| Homepage | `index.html` — fully standalone HTML, no Jekyll theme |
| Fonts | Playfair Display (headings) + Inter (body) + JetBrains Mono (labels/tags) via Google Fonts |
| Hosting | GitHub Pages (free, auto-builds on push to `master`) |

---

## Architecture

The site uses a **hybrid approach**:

- `index.html` — completely standalone HTML/CSS page. No Jekyll layout, no theme. Acts as the homepage.
- All inner pages — use `layout: custom-page` defined in `_layouts/custom-page.html`. This is also standalone HTML (no minimal-mistakes theme). It provides the same nav, design tokens, and footer as the homepage.
- `_config.yml` — Jekyll configuration. Still references `remote_theme: mmistakes/minimal-mistakes` for plugin support and collection handling, but the visual theme is fully overridden.

**Result:** Every page on the site shares the same visual identity — same nav, same fonts, same color palette — regardless of whether it is the homepage or a Jekyll-generated inner page.

---

## Directory Structure

```
website/
│
├── index.html              # Homepage (standalone HTML, no Jekyll layout)
├── _config.yml             # Jekyll config: site metadata, collections, plugins
├── _layouts/
│   └── custom-page.html    # Shared layout for ALL inner pages (nav + footer + CSS)
│
├── _pages/                 # One file per site section
│   ├── about.md            # /about/ — not in main nav
│   ├── contact.md          # /contact/
│   ├── cv.md               # /cv/
│   ├── publications.html   # /publications/
│   ├── resources.md        # /resources/
│   ├── talks.md            # /conference/
│   └── teaching.html       # /teaching/
│
├── _publications/          # One .md file per working paper
├── _teaching/              # One .md file per course (for record-keeping)
├── _talks/                 # Empty — conference page is manually maintained in _pages/talks.md
├── _portfolio/             # Empty — not used
├── _posts/                 # Empty — blog removed
│
├── _data/
│   ├── navigation.yml      # Nav links (used by minimal-mistakes default pages only)
│   ├── authors.yml
│   └── ui-text.yml
│
├── _sass/
│   └── _custom.scss        # Kept for backward compat; visual style now in custom-page.html
│
├── assets/                 # CSS, JS, webfonts
├── files/                  # PDFs served at /files/<name>.pdf
│   ├── Debanjan_CV.pdf     # Live CV — replace to update
│   ├── paper1.pdf ...      # Working paper PDFs
│   └── slides1.pdf ...     # Presentation slides
│
├── images/                 # profile.jpg, favicons, site-logo.png
├── scripts/                # cv_markdown_to_json.py, update_cv_json.sh (CV helpers)
├── progress_logs/          # Session-by-session change log (maintained by Claude)
│
├── CLAUDE.md               # Instructions for Claude Code (AI assistant context)
├── Gemfile                 # Ruby gem dependencies
├── robots.txt              # SEO: points crawlers to sitemap
└── google641d2ce753795607.html  # Google Search Console verification (do not delete)
```

---

## Navigation Structure

All nav links live in `_layouts/custom-page.html` (inner pages) and `index.html` (homepage). Both must be kept in sync manually.

| Label | URL | Source |
|---|---|---|
| Research | `/#research` | Section on homepage |
| Conferences | `/#conferences` | Section on homepage |
| Teaching | `/teaching/` | `_pages/teaching.html` |
| Background | `/#education` | Section on homepage |
| Contact | `/#contact` | Section on homepage |
| CV ↗ | `/files/Debanjan_CV.pdf` | PDF in `files/` |

---

## Design System

All design tokens are defined as CSS custom properties in both `index.html` and `_layouts/custom-page.html`. If you change a color, update it in **both files**.

| Token | Value | Used for |
|---|---|---|
| `--bg` | `#F8F7F4` | Page background (warm off-white) |
| `--surface` | `#FFFFFF` | Cards, nav |
| `--text` | `#1A1917` | Primary text |
| `--text-mid` | `#4A4845` | Secondary text |
| `--text-soft` | `#78756F` | Labels, captions |
| `--blue` | `#1B5E8A` | Accent, links, card borders |
| `--blue-dark` | `#133F5C` | Hover states |
| `--blue-wash` | `#EAF3F9` | Light blue backgrounds |
| `--rust` | `#C44B1B` | Hover accent on cards |
| `--border` | `#E4E2DC` | Dividers, card borders |
| `--font-serif` | Playfair Display | Headings, name |
| `--font-sans` | Inter | Body text |
| `--font-mono` | JetBrains Mono | Labels, tags, code |

---

## How to Update Content

### Add a new working paper

1. Create `_publications/YYYY-short-title.md`:

```yaml
---
title: "Full Paper Title"
collection: publications
category: manuscripts
permalink: /publication/YYYY-short-title
excerpt: 'One-sentence summary shown in the publications list.'
layout: single
---

**Status:** Working Paper

**Abstract:** ...

**Keywords:** keyword1, keyword2
```

2. Upload the PDF to `files/` (e.g. `files/paper4.pdf`).
3. Add a link in the publication `.md` file if needed.
4. The paper automatically appears on `/publications/` via the Liquid loop.

### Add a conference presentation

Edit `_pages/talks.md` directly. Add a bullet under the correct year heading:

```markdown
* DD Month: **Conference Name** at **Institution** on "Paper Title"
  [Download Slides](link-to-slides)
```

### Add a teaching entry

Edit `_pages/teaching.html` directly — the teaching cards are hardcoded HTML in that file. Add a new `<div class="course-card">` block following the existing pattern. Also create a record file in `_teaching/` for documentation.

### Update the CV

Replace `files/Debanjan_CV.pdf` with the new version (keep the exact same filename). No other changes needed — both `/cv/` and the About page link to this file.

### Update the About / homepage bio

Edit `index.html`. The hero section (`<header class="hero">`) contains the name, bio text, and action buttons.

### Change a nav link

Edit the `<ul class="nav-links">` block in **both**:
- `index.html` (homepage nav)
- `_layouts/custom-page.html` (all inner pages nav)

---

## Deployment

GitHub Pages auto-builds and deploys on every push to `master`. No CI setup needed.

```bash
git add <files>
git commit -m "describe what changed"
git push origin master
```

Build typically completes in 1–2 minutes. Git identity for this repo:
- `user.name = Debanjan Das`
- `user.email = f2101@irma.ac.in`

### Check build status

Go to: `https://github.com/Debanjan-econpolicy/debanjan-econpolicy.github.io/actions`

If the build fails, GitHub will show the Jekyll error in the Actions log.

---

## Local Development

To preview changes locally before pushing:

**Prerequisites:** Ruby, Bundler

```bash
# Install dependencies (first time only)
bundle install

# Serve locally with live reload
bundle exec jekyll serve -l -H localhost
```

Site available at `http://localhost:4000`. Changes to most files hot-reload automatically; changes to `_config.yml` require a restart.

> **Windows note:** If you get permission errors, run: `bundle config set --local path 'vendor/bundle'` then `bundle install` again.

---

## SEO & Search Console

- **Google Search Console** verified via `google641d2ce753795607.html` (root of repo — do not delete) and the `google_site_verification` meta tag in `_config.yml` and `_layouts/custom-page.html`.
- **Sitemap** auto-generated by `jekyll-sitemap` plugin at `/sitemap.xml` — submitted to Google Search Console.
- **robots.txt** in root points crawlers to the sitemap.
- `CLAUDE.md` is excluded from sitemap and search via frontmatter flags.

---

## Files That Must Not Be Deleted

| File | Why |
|---|---|
| `google641d2ce753795607.html` | Google Search Console ownership verification |
| `google0dcc01e512363f70.html` | Secondary GSC verification file |
| `robots.txt` | SEO crawler instructions |
| `Gemfile` | Ruby dependency definition for GitHub Pages |
| `_config.yml` | Jekyll won't build without this |
| `_layouts/custom-page.html` | All inner pages break without this |

---

## Progress Log

Session-by-session changes are recorded in [`progress_logs/`](progress_logs/). See that folder's README for the log format.
