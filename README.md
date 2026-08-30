# MyCV

Sorgenti LaTeX del mio curriculum vitae (italiano e inglese).

## Struttura

- `CV-IT/` — sorgente della versione italiana (`main.tex`)
- `CV-EN/` — sorgente della versione inglese (`main.tex`)
- `dist/` — PDF compilati automaticamente (non modificare a mano)
- `PRE2024-CV-*` — vecchio template, archiviato

## Release automatiche

Ad ogni push su `main` che tocca `CV-IT/` o `CV-EN/`, la GitHub Action
`Release CVs` compila entrambi i PDF e:

1. aggiorna le copie in `dist/`;
2. pubblica/aggiorna la release **`latest`** con gli asset
   `CVE_IT_LucaTomei.pdf` e `CVE_EN_LucaTomei.pdf`.

Il mio sito personale scarica i CV direttamente dalla release `latest` di
questa repository, quindi per aggiornare il CV online basta modificare il
`.tex` e fare push.
