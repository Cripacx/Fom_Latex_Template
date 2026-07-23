---
name: literatur-recherche
description: >-
  Conduct (optionally PRISMA-oriented) literature research for an academic paper
  by driving the user's connected Chrome/Edge browser (Claude-in-Chrome MCP)
  across Google Scholar, IEEE Xplore, EBSCO Discovery Service and Internet
  Archive Scholar (scholar.archive.org). Use when the user wants to search
  databases, collect hit counts, screen results, find or verify key papers, or
  fill the search-string table in docs/prisma_recherche.md. Covers correct
  hit-count reading (incl. the EBSCO result-count pitfall) and bulk-fetching
  EBSCO records via the authenticated in-page search API. On first use it checks
  whether PRISMA research is enabled (see step 0).
---

# Literatur-Recherche (browser-driven, optional PRISMA-oriented)

Workflow for running the literature search through the user's logged-in browser.
When systematic research is enabled, the working log lives in
**`docs/prisma_recherche.md`** — read it first and write every count/screening
decision back into it.

## 0. Vor dem Start — PRISMA-Modus bestimmen (immer zuerst)

Dieser Schritt entscheidet, wie die Recherche geführt wird. Er wird bei **jeder**
Nutzung des Skills zuerst ausgeführt.

1. **Prüfe, ob `docs/prisma_recherche.md` existiert.**

2. **Datei existiert nicht:** Frage den Nutzer:
   > „Möchtest du für diese Arbeit eine systematische, reproduzierbare
   > (PRISMA-orientierte) Literaturrecherche nutzen?"
   - **Ja →** Lege `docs/prisma_recherche.md` aus der Protokoll-Vorlage in
     Abschnitt 2 an (Status `prisma-active`, Abschnitte 1–3 zum Ausfüllen) und
     fahre mit dem Workflow fort.
   - **Nein →** Lege `docs/prisma_recherche.md` dennoch an, aber mit dem
     **Deaktiviert-Marker** (siehe unten). Führe **keine** PRISMA-Schritte aus;
     biete stattdessen eine leichtgewichtige Ad-hoc-Recherche an (gezielte Suche,
     Einzelquellen prüfen/verifizieren, `literatur.bib`-Einträge erstellen).

   Deaktiviert-Marker (genau diese ersten Zeilen der Datei):
   ```markdown
   # Literaturrecherche — Status
   > Status: prisma-disabled
   >
   > Die systematische (PRISMA-orientierte) Recherche wurde für diese Arbeit
   > bewusst NICHT gewählt. Der Skill `literatur-recherche` führt daher nur
   > Ad-hoc-Recherche und Quellenverifikation aus. Zum Aktivieren: diese Datei
   > durch die Protokoll-Vorlage ersetzen und `Status: prisma-active` setzen
   > (oder den Skill erneut aufrufen und um Aktivierung bitten).
   ```

3. **Datei existiert:** Lies die `Status:`-Zeile.
   - `prisma-active` (oder ein ausgefülltes Protokoll ohne Marker) → normaler
     PRISMA-Workflow ab Abschnitt 1.
   - `prisma-disabled` → Weise den Nutzer kurz darauf hin, dass die systematische
     Recherche deaktiviert ist, und arbeite nur ad hoc. Nur wenn der Nutzer
     ausdrücklich umschalten möchte, ersetze den Marker durch die
     Protokoll-Vorlage (Status `prisma-active`).

> Der Skill respektiert den Marker eigenständig: Solange `prisma-disabled` in
> `docs/prisma_recherche.md` steht, werden die PRISMA-Schritte 2–8 übersprungen.

## Hard rules

- **Never invent or guess bibliographic data** (authors, title, year, venue,
  DOI, BibTeX). Confirm every cited source against a primary record
  (dblp / Crossref / arXiv / publisher). This is a non-negotiable rule — see
  `CLAUDE.md`.
- **PDF + Markdown before a source may be selected (recommended default).** A
  source should only be selected / cited / added to `literatur.bib` once its
  **full-text PDF** is saved to `literatur/pdf/<BibKey>.pdf`, converted to
  `literatur/pdf/<BibKey>.md` with markitdown **and read**. Abstract / snippet /
  DOI / Crossref-metadata justify *shortlisting* only. For Key-Papers this is
  mandatory. If the PDF is unobtainable, do not use the source (mark "PDF fehlt",
  ask the user). The `literatur/pdf/` folder is gitignored.
- **Never persist session cookies / tokens** into any file in the repo. Use the
  in-page `fetch()` approach below, which sends auth cookies automatically and
  leaves nothing secret on disk.
- **Inclusion / exclusion criteria are defined per paper** in
  `docs/prisma_recherche.md` (typically: peer-reviewed, a defined year range,
  language EN/DE, topical focus, full text available). Do not hardcode them —
  read them from that file.

## 1. Connect the browser

The Claude-in-Chrome extension must be installed and connected (works in Edge —
it is Chromium). Sequence:

1. `list_connected_browsers` — if empty, `switch_browser` (broadcasts a connect
   request; user clicks **Connect** in the extension), then `select_browser`
   with the returned `deviceId`.
2. `tabs_context_mcp { createIfEmpty: true }` → get a `tabId` to drive.
3. Navigate with `navigate`, read with `get_page_text` / `javascript_tool`.

Navigating to a publisher URL inside the user's session uses their institutional
access automatically (e.g. an IEEE link may resolve via the university proxy /
EBSCO).

## 2. PRISMA protocol (define before searching)

Fill these into `docs/prisma_recherche.md` before searching. Protocol-Vorlage
(neu anzulegen, wenn PRISMA aktiviert wird):

```markdown
# PRISMA-orientierte Literaturrecherche — Arbeitsprotokoll
> Status: prisma-active
> Recherchedatum: <Datum>

## 0. Bezug zur Arbeit
Übergeordnete Forschungsfrage: <…>

## 1. Datenbanken
| Datenbank | Zugang | Anmerkung |
|---|---|---|
| Google Scholar | frei | breiter Startpunkt, Trefferzahlen |
| IEEE Xplore | Bibliothek (Command Search, matchBoolean=true) | enge Metadaten-Treffer |
| EBSCO (research.ebsco.com) | Bibliothek | großer Aggregator |
| Internet Archive Scholar | frei | offener Volltext-Index |

## 2. Konzeptblöcke (AND zwischen Blöcken, OR innerhalb)
| Block | Begriffe |
|---|---|
| A – … | `"…"`, `"…"` |
| B – … | `"…"`, `"…"` |

## 3. Ein-/Ausschlusskriterien
Einschluss: peer-reviewed; <Jahresbereich>; EN/DE; <Fokus>; Volltext verfügbar.
Ausnahmen: <Landmark-/Grundlagenwerke>.

## 4. Suchstring-Tabelle
| String | Datenbank | Query | Treffer | Datum |
|---|---|---|---|---|

## 5. Screening-Log
| Quelle | Entscheidung | Begründung |
|---|---|---|

## 6. Key-Paper
| BibKey | Titel | Status (PDF/MD) |
|---|---|---|
```

Ablauf:
1. Concept blocks (AND between blocks, OR within), search strings, databases,
   inclusion/exclusion — fix these in `docs/prisma_recherche.md` first.
2. Run each string per database, record the **total** hit count.
3. **Narrow any string with more than ~50 hits before screening** — iteratively
   add terms until the result list is small enough to screen by title/abstract.
4. Screen → select key papers → verify each against a primary record.
5. Keep the search-string table + screening log up to date; the table feeds the
   appendix, the screening feeds the "Stand der Forschung" section.

## 3. Per-database recipes

### Google Scholar (broad, full-text — large counts)
- URL: `https://scholar.google.com/scholar?hl=de&q=<encoded query>`
- Query supports quotes + `OR`/`AND`. Counts are **full-text**, so they are
  large and noisy — use Scholar mainly for *discovery* (relevance-sorted top
  hits) and verify the real records elsewhere.
- Total count: `document.querySelector('#gs_ab_md .gs_ab_mdw')?.textContent`
  ("Ungefähr N Ergebnisse").

### IEEE Xplore (narrow, metadata — small, screenable counts)
- Use **Command Search**. URL form (note `matchBoolean=true`):
  `https://ieeexplore.ieee.org/search/searchresult.jsp?action=search&newsearch=true&matchBoolean=true&queryText=<encoded>`
- Query syntax tags each term: `("All Metadata":"plugin architecture" OR "All Metadata":"extension mechanism") AND ("All Metadata":"microservices" OR "All Metadata":"containerization")`
- Total count is stated explicitly: "Showing 1-X of **X** results". Small enough
  to screen all hits directly from `get_page_text`.

### EBSCO Discovery Service (library aggregator — metadata)
- URL: `https://research.ebsco.com/c/<profileIdentifier>/search/results?q=<encoded>&type=0`
  - `<profileIdentifier>` is the segment after `/c/` in any EBSCO URL of the
    current session — read it live, do not hardcode a foreign profile.
- For the UI see §4 for the count pitfall; for bulk/structured data use §5.

### Internet Archive Scholar (scholar.archive.org — free full-text index)
- Open full-text index (Fatcat catalog, > 25M articles), strong on open-access
  and long-tail / preserved journals; complements Scholar/IEEE/EBSCO. Drive it
  through the browser (no stable public JSON search API — use the UI + page text).
- URL: `https://scholar.archive.org/search?q=<encoded query>`
  - Query is Elasticsearch `query_string` syntax: quotes for phrases,
    `AND`/`OR`, parentheses.
- **Filters** (apply via the left rail, then copy the resulting URL params so the
  run is reproducible — do **not** hardcode param names you haven't confirmed
  live): Resource Type → *Journal Article*, Time → the defined year range,
  Availability → *Everything*, Language → *English* / *German*.
- **Total count:** read it from the results header text via `get_page_text`
  (e.g. "… out of **N** results") — confirm the exact wording/selector live
  before trusting it; **never** count rendered result rows (paged display).
- Verify each selected record's DOI via Crossref (§7) before it enters
  `literatur.bib`.

### Google Scholar MCP (`mcp__google-scholar__*`) — unreliable
- A Google Scholar MCP may be connected, but Scholar frequently blocks it with
  **HTTP 403** (bot detection). Do not hammer it on 403. For Scholar
  breadth/counts, **drive Google Scholar through the connected browser instead**
  (`scholar.google.com/scholar?hl=de&q=…`, count via `#gs_ab_md .gs_ab_mdw`) —
  that runs in the user's real session and works.

### Verify every record before it enters literatur.bib — Crossref (no blocking)
- Confirm DOI metadata via the Crossref REST API (reliable, unauthenticated):
  `https://api.crossref.org/works/<doi>?mailto=<email>` → `message` has
  `title`, `author[]`, `container-title`, `volume`, `issue`, `page`,
  `published`, `publisher`, `type`. Use this to fix online-first vs. issue-year
  discrepancies before writing the BibLaTeX entry.

## 4. ⚠️ EBSCO hit-count pitfall (must read)

EBSCO renders **10 results per page**. The "10" near the top of the page (and
the number of result cards in the DOM) is the **page size, not the total**.
Reading it as the total is wrong.

The **true total** is the dedicated element:

```js
document.querySelector('#results-count, [data-auto="result-count"]')?.textContent
// → "Ergebnisse: 705"
```

Always read that element (or `search.totalItems` from the API in §5). Never
count rendered cards.

## 5. EBSCO bulk records via the in-page API (preferred)

Fetch structured records directly from EBSCO's search API **from inside an
authenticated `research.ebsco.com` tab** using `javascript_tool`. With
`credentials:'include'` the session cookies (including HttpOnly) are sent
automatically — no cookie extraction, nothing secret written to disk.

**Endpoint:** `POST https://research.ebsco.com/api/search/v1/search?applyAllLimiters=true&includeSavedItems=false&excludeLinkValidation=true&includeHbrRestrictedLinks=true`

**Snippet** (set `query`, `profileIdentifier` from the live session, `offset`):

```js
const res = await fetch('https://research.ebsco.com/api/search/v1/search?applyAllLimiters=true&includeSavedItems=false&excludeLinkValidation=true&includeHbrRestrictedLinks=true', {
  method: 'POST',
  headers: {'accept':'application/json, text/plain, */*','content-type':'application/json','txn-route':'true','x-initiated-by':'refresh'},
  credentials: 'include',
  body: JSON.stringify({
    advancedSearchStrategy: "NONE",
    query: '("plugin architecture" OR "extension mechanism") AND ("microservices" OR "containerization")',
    autoCorrect: false,
    profileIdentifier: "<profileIdentifier>",   // read live from the session URL
    expanders: ["fullText","concept"],          // concept = smart/expanded matching
    // filters: [{ id:"FT1", values:["true"] }], // FT1=true → full text available only
    searchMode: "all",
    sort: "relevance",
    isNovelistEnabled: false,
    includePlacards: true,
    offset: 0,                                   // paginate: 0, 50, 100, …
    count: 50,                                   // max 50 per request
    highlightTag: "mark",
    userDirectAction: false
  })
});
const j = await res.json();
const s = j.search;
// s.totalItems  → true total (matches #results-count)
// s.dedupedItems→ total after EBSCO dedup
// s.items[]     → up to 50 records this page
```

**Response schema** (`j.search`): `totalItems`, `dedupedItems`, `facets`,
`items[]`. Each record in `items[]` exposes: `title`, `contributors[].name`,
`coverDate` / `publicationDate`, `source` (venue), `volume`, `issue`,
`pageStart`, `doi`, `peerReviewed` (boolean — use for the inclusion filter),
`docTypeDisplayNames`, `subjects`, `abstract`, `links`.

Notes:
- `title`/`source` can contain `<mark>` highlight tags — strip with
  `.replace(/<[^>]+>/g,'')`. Some fields may be objects/arrays; coerce defensively.
- `count` is capped at 50 → paginate with `offset += 50` until `offset >= totalItems`.
- Prefer `publicationDate` over `coverDate` for a clean year.
- To dump for offline screening, save the trimmed array to a temp file
  (e.g. `docs/_ebsco_<string>.json`) and gitignore it — never the raw cookies.

## 6. curl fallback (only outside the browser)

If a request must run outside the browser session, EBSCO's API also works with
`curl` **if** the current session cookies are supplied. Cookies are
session-specific and expire, so pull fresh ones via DevTools → Network → the
`/api/search/v1/search` request → **Copy as cURL**.

- **Security:** treat these as secrets — do not paste real cookie values into
  the repo, commits, or this skill. Use placeholders; the in-page `fetch()` in
  §5 avoids the problem entirely and is the default.

## 6b. Obtaining full text (download PDF → Markdown)

A source may only be cited or added to `literatur.bib` once you **hold its PDF in
`literatur/pdf/<BibKey>.pdf` AND its markitdown Markdown in
`literatur/pdf/<BibKey>.md`, and have read the Markdown** — never on
metadata/snippet/DOI/abstract alone. For every Key-Paper this is mandatory.
Access order:

1. **Internet Archive (archive.org / scholar.archive.org):** the PDF can often be
   downloaded directly — use the work's fulltext/download link.
2. **EBSCO:** most records expose a PDF / full-text download from inside the
   authenticated `research.ebsco.com` session — download it there.
3. **Other sources (Google Scholar, publisher pages, …):** first try to locate
   the same record in an accessible database; if still unavailable, **ask the
   user for the PDF**.
4. **After download:** convert the PDF to Markdown with **markitdown**, read the
   Markdown, then verify the record (§7) and cite.

## 7. Verify before citing

For every key/background paper, confirm the record before it enters
`literatur/literatur.bib`:
- **dblp** (CS, authoritative): `https://dblp.org/search/publ/api?q=<terms>&format=json`
- **Crossref**: `https://api.crossref.org/works?query.bibliographic=<terms>`
- **arXiv** / publisher page for preprints.
- Reject sources with no identifiable peer-reviewed venue unless explicitly used
  as clearly-labelled grey literature.

## 8. Output

- Update the table, screening log, and key-paper list in
  `docs/prisma_recherche.md` every pass.
- Hand verified records to the citation step; cite in the `.tex` with
  `\autocite[\vglf][\pagef N]{key}` (see `CLAUDE.md`).
- **Always give the user the links for any source whose PDF must be fetched
  manually** (gated / no OA / PDF still missing): DOI link, publisher link, and a
  ready-to-paste library/EBSCO search query (use the DOI as `q`, URL-encode the
  slash as `%2F`). State the target filename (`literatur/pdf/<BibKey>.pdf`) so the
  dropped file lands where the convert step expects it. Never present a source as
  "selected" until its PDF + Markdown exist (see Hard rules).
