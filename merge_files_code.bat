@echo off
setlocal enabledelayedexpansion

REM Creiamo il file se non esiste o lo cancelliamo se esiste già
if exist mergedFile.txt del mergedFile.txt

REM Lista di file da escludere (separati da spazi)
set "EXCLUDED_FILES=config.c test.h temp.fam"

REM Lista di cartelle da escludere (separati da spazi)
set "EXCLUDED_FOLDERS=nfc mizip trea swimtag microel gui_extensions backup temp"

for /r %%f in (*.py *.env *.fam) do (
    REM Ottiene solo il nome del file senza percorso
    set "filename=%%~nxf"
    
    REM Ottiene il percorso completo
    set "fullpath=%%f"
    
    REM Flag per verificare se il file deve essere escluso
    set "exclude_file=0"
    
    REM Controlla se il file è nella lista dei file esclusi
    for %%e in (%EXCLUDED_FILES%) do (
        if "!filename!"=="%%e" (
            set "exclude_file=1"
        )
    )
    
    REM Controlla se il file è in una cartella esclusa
    for %%d in (%EXCLUDED_FOLDERS%) do (
        echo !fullpath! | findstr /i /c:"\\%%d\\" > nul
        if !errorlevel! equ 0 (
            set "exclude_file=1"
        )
    )
    
    REM Se il file non deve essere escluso, lo aggiungiamo al file finale
    if !exclude_file! equ 0 (
        echo ---- File: %%f ---- >> mergedFile.txt
        type "%%f" >> mergedFile.txt
        echo. >> mergedFile.txt
    )
)

echo Completato! File mergedFile.txt creato con successo.
endlocal