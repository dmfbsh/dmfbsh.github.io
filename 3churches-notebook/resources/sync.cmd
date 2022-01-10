REM @echo off

REM DAVID-LT is the HP Spectre
REM LAPTOP-KR938IFA is the HP Envy

if "%COMPUTERNAME%" == "DAVID-LT" goto :lt1

if "%COMPUTERNAME%" == "LAPTOP-KR938IFA" goto :lt2

:lt1
set winmerge=C:\Program Files (x86)\WinMerge\WinMergeU.exe
set icloud=C:\Users\David\iCloudDrive\iCloud~com~aschmid~notebooks\9. Churches - Notebook
set github=C:\Users\David\Documents\GitHub\dmfbsh.github.io\3churches-notebook
goto :doit

:lt2
set winmerge=C:\Program Files\WinMerge\WinMergeU.exe
set icloud=C:\Users\small\iCloudDrive\iCloud~com~aschmid~notebooks\9. Churches - Notebook
set github=C:\Users\David\Documents\OneDrive\Documents\My Documents\GitHub\dmfbsh.github.io\3churches-notebook
set attachments=C:\Users\David\Documents\OneDrive\Documents\My Documents\GitHub\dmfbsh.github.io\3churches-notebook\resources\WinMerge-attachments.WinMerge
goto :doit

:doit
"%winmerge%" /x "%icloud%\1. Visiting.md" "%github%\1. Visiting.md"
"%winmerge%" /x "%icloud%\2. Architectural Styles.md" "%github%\2. Architectural Styles.md"
"%winmerge%" /x "%icloud%\3. Architectural Structure.md" "%github%\3. Architectural Structure.md"
"%winmerge%" /x "%icloud%\4. Internal Features.md" "%github%\4. Internal Features.md"
"%winmerge%" "%attachments%"
