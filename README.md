# FOM LaTeX Template

Vorlage für wissenschaftliche Arbeiten an der FOM Hochschule – geeignet für
**Bachelor-/Master-Thesis, Hausarbeit, Seminararbeit, Projektarbeit und Exposé**.
Das Projekt verwendet einen **VS Code Dev Container**, um eine konsistente
Entwicklungsumgebung bereitzustellen.

## Art der Arbeit einstellen

Die Vorlage passt sich über einen Schalter in [`skripte/meta.tex`](skripte/meta.tex)
automatisch an die Art der Arbeit an:

- `\myArbeitsModus{thesis}` – **Abschlussarbeit**: Die Titelseite zeigt den
  angestrebten akademischen Grad (`\myAkademischerGrad`) sowie Erst- und
  (optional) Zweitgutachter (`\myBetreuer`, `\myZweitgutachter`).
- `\myArbeitsModus{lehrveranstaltung}` – **Arbeit im Rahmen einer
  Lehrveranstaltung** (Hausarbeit, Seminararbeit, Projektarbeit, Exposé …):
  Die Titelseite zeigt die Lehrveranstaltung (`\myLehrveranstaltung`) sowie den
  Betreuer (`\myBetreuer`).

Alle weiteren Metadaten (Titel, Autor, Matrikelnummer, Hochschule, Studiengang …)
werden ebenfalls in `skripte/meta.tex` gesetzt. `\myThesisArt` bestimmt die auf
der Titelseite angezeigte Bezeichnung (z. B. „Bachelor Thesis", „Hausarbeit").

## KI-Verzeichnis & Erklärung zur KI-Nutzung

Gemäß dem FOM-Leitfaden enthält die Vorlage:

- ein **KI-Verzeichnis** ([`kapitel/anhang/ki_verzeichnis.tex`](kapitel/anhang/ki_verzeichnis.tex)),
  das per `\input` in [`main.tex`](main.tex) aktiviert werden kann, und
- eine **Erklärung zur KI-Nutzung** als Teil von
  [`kapitel/anhang/erklaerung.tex`](kapitel/anhang/erklaerung.tex).

Wurde keine KI genutzt, können beide entfernt bzw. deaktiviert bleiben.

## Voraussetzungen

- Installiere [Visual Studio Code](https://code.visualstudio.com/).
- Installiere die Erweiterung [Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).
- Stelle sicher, dass Docker auf deinem System installiert und ausgeführt wird.

## Nutzung

1. Öffne das Projekt in Visual Studio Code.
2. Öffne die Kommando-Palette (`Ctrl+Shift+P` oder `Cmd+Shift+P` auf macOS).
3. Wähle **Remote-Containers: Reopen in Container**.
4. Warte, bis der Container gestartet ist. Danach kannst du direkt mit der Arbeit beginnen.

### PDF bauen

Das Hauptdokument ist [`main.tex`](main.tex).

```bash
# Deutsch (Standard) -> main.pdf
docker compose run --rm latex ./compile.sh

# Englisch -> main_englisch.pdf
docker compose run --rm latex ./compile.sh en
```

Unter Windows ohne Docker kann `compile.bat` genutzt werden.

## Planung & Recherche (optional)

Im Ordner `docs/` liegen Planungsdokumente (nicht Teil der PDF):

- [`docs/thema_uebersicht.md`](docs/thema_uebersicht.md) – zentrales
  Planungsdokument (Themenfindung, Kontext, Forschungsfrage, Methodik, Titel).
  Wird von Beginn an gepflegt.
- `docs/prisma_recherche.md` – Protokoll einer optionalen, systematischen
  (PRISMA-orientierten) Literaturrecherche. Wird vom Skill
  `literatur-recherche` (`.claude/skills/`) bei Bedarf angelegt; beim ersten
  Aufruf fragt der Skill, ob die systematische Recherche genutzt werden soll.

Details siehe [`CLAUDE.md`](CLAUDE.md).

## Weitere Informationen

- [VS Code Dev Containers Dokumentation](https://code.visualstudio.com/docs/remote/containers)
- [Docker Dokumentation](https://docs.docker.com/)
