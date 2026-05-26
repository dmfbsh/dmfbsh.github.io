@echo off

CALL z-config.bat

java "%EP%\ChurchesDatabaseVisited.java"

java -cp %CP% %EXE% -mode construct -file "%OUTFOLDER%\hereford.html" -template %TEMPLATE%

java -cp %CP% %EXE% -mode construct -file "%OUTFOLDER%\lichfield.html" -template %TEMPLATE%

PAUSE
