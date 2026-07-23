# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A reusable LaTeX template for academic papers at **FOM Hochschule**, based on the
[FOM-LaTeX-Template](https://github.com/andygrunwald/FOM-LaTeX-Template). It suits
several kinds of work — Bachelor/Master thesis, term paper (Hausarbeit), seminar
paper, project report, and Exposé — selected via a single switch (see "Type of
work" below). The `kapitel/` folders (`einleitung/`, `kapitel_1/`, `kapitel_2/`,
`fazit/`) ship with placeholder/demo content and the entries in
`literatur/literatur.bib` are demo entries — replace them with real material.

## Building the PDF

Build via the `texlive/texlive` Docker image. A `docker-compose.yml` defines a
`latex` service that mounts the repo at `/workspace`.

```bash
# German (default) — produces main.pdf
docker compose run --rm latex ./compile.sh

# English — produces main_englisch.pdf
docker compose run --rm latex ./compile.sh en
```

`compile.sh` runs the full pipeline: **lualatex → biber → lualatex → lualatex**
(three lualatex passes are required for correct cross-references, TOC,
bibliography, and glossary; biber resolves citations). It deletes the old PDF and
all temp files before and after. `compile.bat` is the Windows-native equivalent
(no Docker). The compiler is **lualatex**, not pdflatex — `--shell-escape` is
passed (needed for `minted`/`plantuml`/TikZ externalization if enabled). Don't
switch the engine.

CI (`.github/workflows/build_pdf.yml`) compiles the German PDF on every push to
`main` and attaches `main.pdf` to a GitHub release.

### Word count

`./countwords.sh` counts words from "Einleitung" to "Anhang". Requires `detex`
on the host (`brew install opendetex`), so it does not run inside the LaTeX
container.

## Architecture of the document

`main.tex` is the single root file and orchestrates everything: it sets
`\documentclass` (KOMA-Script `scrartcl`), loads all packages, configures the
bibliography, and `\input`s the parts in order. Editing flow is almost always:
change a file under `skripte/`, `kapitel/`, or `abkuerzungen/` — rarely `main.tex`
itself.

- **`skripte/meta.tex`** — all document metadata as `\newcommand`s (title,
  author, supervisor, matriculation number, degree, etc.), the type-of-work
  switch, and the language switch logic. Edit identity fields here, nowhere else.
- **`skripte/kapitelUebersicht.tex`** — the ordered list of `\input`s for the
  content chapters. Add/reorder chapters here, not in `main.tex`.
- **`kapitel/`** — chapter content, one folder per chapter, plus `titelseite.tex`
  and `anhang/` (appendix: `erklaerung.tex` = honesty declaration + AI-use
  declaration, `ki_verzeichnis.tex` = list of AI tools, `sperrvermerk.tex` =
  confidentiality notice).
- **`skripte/`** (other files) — formatting machinery: `weitereEbene.tex`
  (enables `\paragraph` as a numbered 4th heading level), `textcommands.tex`,
  `symbolDef.tex`, `leereVerzeichnisse.tex` (auto-hides empty front-matter
  directories — see below), `modsBiblatex2018.tex` / `modsBiblatex.tex`
  (citation-style tweaks loaded conditionally — see below).
- **`abkuerzungen/`** — `acronyms.tex` (the `acronym` list; only `[printonlyused]`
  acronyms appear) and `glossar.tex` (`glossaries` entries).
- **`literatur/literatur.bib`** — the BibLaTeX database. `literatur/pdf/` (source
  full texts + markitdown Markdown) is gitignored.
- **`abbildungen/`** — figures; `\graphicspath` includes this folder so images
  are referenced by bare filename.
- **`docs/`** — planning artifacts, **not** part of the compiled PDF:
  `thema_uebersicht.md` (topic/planning) and, if used, `prisma_recherche.md`
  (literature-search log). See "Planning & research workflow".

### Type of work (thesis vs. Lehrveranstaltung)

`skripte/meta.tex` defines `\myArbeitsModus`, which drives the title page layout:

- `thesis` — final thesis: shows the academic degree (`\myAkademischerGrad`) and
  first/second examiner (`\myBetreuer`, optional `\myZweitgutachter`).
- `lehrveranstaltung` — work within a course (Hausarbeit, Seminararbeit, project
  report, Exposé): shows the course (`\myLehrveranstaltung`) and the advisor
  (`\myBetreuer`).

`\myThesisArt` is the free-text label printed on the title page. Do not
re-introduce manual comment-toggling on the title page — use the switch.

### Language switching (German / English)

The document is bilingual via the `\FOMEN` macro. Default is **German**. The
English build passes `\def\FOMEN{}` on the command line, which flips `babel`,
`csquotes`, and sets the `\ifen` flag. In content, wrap language-specific text
with `\langde{...}` and `\langen{...}` — only the active language renders.

### Citation style

`main.tex` selects the BibLaTeX style via `\newcommand{\citationstyle}{...}`.
Valid values: `fom_2018` (default, current FOM Leitfaden — `ext-authoryear-ibid`,
footnote citations), `ieee`, or `fom_alt`. Each branch loads a different
`biblatex` config and the matching `skripte/modsBiblatex*.tex`.

### Empty front-matter directories are auto-hidden

`skripte/leereVerzeichnisse.tex` automatically suppresses the list of figures,
list of tables, list of abbreviations, list of symbols, and the glossary —
including their heading, TOC entry, and `\newpage` — when they would be empty. No
manual commenting is needed. Definitions (`\input{symbolDef}`, the acronym
environment, glossary entries) always load so `\ac{...}`, symbols, and `\gls{...}`
keep working in the body; only the *presentation* is gated. Detection is
per-directory: figures/tables via persisted `figure`/`table` counts
(`\iffiguresexist`/`\iftablesexist`), symbols via a scan of `.sym`
(`\ifsymbolsexist`), abbreviations via an `\acronymused` flag (`\ifacronymsused`),
and the glossary via `\forglsentries`/`\ifglsused` (`\ifglossaryused`). Because the
signals come from the previous run, the multi-pass build (lualatex ×3) converges
on its own.

## Conventions

### Language policy

- All document **content** (LaTeX prose) is written in **formal academic German**
  (or English when writing the `\langen{}` variant), in the style of a scientific
  paper.
- Comments, filenames, and technical config (`.yml`, `.sh`, `.cfg`) stay in
  **English**.

### Writing content — LaTeX style

- **Citations always come from `literatur/literatur.bib`** — never invent sources
  (authors, titles, years, or BibTeX entries). If a source is not available, say
  so and ask.
- **Use `\autocite`, not `\footcite`, for normal citations.** `\autocite` honours
  the active `autocite=` option, so citations adapt if the style switch changes.
  Argument order: `\autocite[<prenote>][<postnote>]{<key>}` — with a single
  bracket, BibLaTeX treats it as the *postnote* (page).
- **Indirect citation (default):** footnote *after* the period, using the
  project's macros:
  `...zentrales Element im Marketing.\autocite[\vglf][\pagef 23]{Müller2020}`
  `\vglf` expands to "Vgl." and `\pagef` to "S. " (defined in
  `skripte/textcommands.tex`).
- **Direct citation (verbatim quote):** drop the `\vglf` prenote:
  `...Aussage.\autocite[\pagef 23]{Müller2020}`. For "adapted from" sources (e.g.
  under tables) use `\cite[Quelle: In Anlehnung an][S. 4]{Beckert.2012}`.
- **Always cite with a page number** for paginated sources; only genuinely
  unpaginated sources (websites, online-only articles) may omit it. Never guess
  page numbers.
- **Cross-references:** `\autoref{}` or `\ref{}`. Give each chapter a
  `\label{kapitel:...}`.
- **Abbreviations:** use `\ac{ERP}` in prose; the acronym must first be defined in
  `abkuerzungen/acronyms.tex` (e.g. `\acro{ERP}{Enterprise Resource Planning}`).
- **Figures:** `\begin{figure}[H]` with `\caption{}` and `\label{fig:...}`, image
  referenced by bare filename (the `abbildungen/` folder is on `\graphicspath`),
  plus a source line (`Quelle: Eigene Darstellung`).
- **Tables:** `\begin{table}[H]` with `\caption{}` and `\label{tbl:...}`, body in
  `tabularx` (`{\textwidth}`), source via `\cite[...][...]{...}`.

### Diagrams — prefer TikZ

Author schematic graphics (flowcharts, architecture/UML/sequence diagrams, Gantt
charts) as vector diagrams with **TikZ/PGF** rather than imported bitmaps, so they
stay editable, scalable, and typographically consistent. `main.tex` already loads
`\usepackage{tikz}` (with libraries `shapes.geometric,arrows.meta,positioning,fit,calc`)
and `\usepackage{pgfgantt}` for Gantt charts. Wrap every TikZ picture in the
standard figure convention. Reserve `\includegraphics` for genuine raster content
(screenshots, photos). The engine is lualatex with `--shell-escape`, so TikZ works
out of the box.

### AI-use documentation (FOM Leitfaden)

If AI tools were used, document them in **`kapitel/anhang/ki_verzeichnis.tex`**
(activate the `\input` in `main.tex`) and keep the **"Erklärung zur KI-Nutzung"**
in `kapitel/anhang/erklaerung.tex`. Remove/deactivate both if no AI tools were
used.

## Planning & research workflow

These artifacts live in `docs/` and steer the work before/while prose is written.

### `docs/thema_uebersicht.md` — the planning single-source-of-truth

`docs/thema_uebersicht.md` captures the **fundamental decisions** of the work:
module/exam framework conditions (word count, weighting, deadlines, permitted
methods, topic areas), a short profile of the author, differentiation from
already-assigned topics, the evaluated topic options and the final choice with its
justification, the research question(s), the intended methodology, a draft outline
with word budget, and open next steps. Maintain it as follows:

- **Mandatory kickoff:** at the start of a new work, fill this file **together with
  the author** — interactively, section by section — **before** writing any prose
  into the `.tex` files. Do not skip it and do not fill it in alone from
  assumptions; ask the author for each section's content.
- Section 3 ("Bereits vergebene Themen") is a pure **exclusion list** — topics the
  author must not pick. Never use it as inspiration or a reference for topic
  finding (that only yields near-duplicate suggestions).
- **Read it first** at the start of every working session — it is the source of
  truth for *what the work is about*, ahead of the `.tex` files.
- **Write decisions here first,** then implement them in `.tex`. When the topic,
  scope, research question, structure, or methodology changes, update this file in
  the same session.
- Keep it in **German**, Markdown, with concrete content (no vague fragments).
- It is a planning document — it is **not** part of the compiled PDF.

### `docs/prisma_recherche.md` + the `literatur-recherche` skill (optional)

Systematic literature research is **optional** and driven by the
`literatur-recherche` skill (`.claude/skills/literatur-recherche/`). On first use
the skill checks whether `docs/prisma_recherche.md` exists:

- **Missing →** it asks whether to run a PRISMA-oriented search. If yes, it
  creates the protocol (status `prisma-active`). If no, it still creates
  `docs/prisma_recherche.md` but marks it `prisma-disabled` and only does ad-hoc
  search + source verification afterwards.
- **Existing →** it reads the `Status:` line and behaves accordingly. The skill
  respects the `prisma-disabled` marker on its own; do not run PRISMA steps while
  it is set.

### Literature — never guess

- **Never invent or guess bibliographic data** (authors, title, year, venue, DOI,
  BibTeX). Confirm every source against a primary record (dblp / Crossref / arXiv
  / publisher).
- **Recommended default: PDF + Markdown before selecting a source.** A source
  should only be cited / added to `literatur.bib` once its full-text PDF is in
  `literatur/pdf/<BibKey>.pdf`, converted to `<BibKey>.md` with markitdown, and
  read. Metadata/abstract/DOI justify *shortlisting* only; for Key-Papers the
  PDF+Markdown is mandatory. `literatur/pdf/` is gitignored.
