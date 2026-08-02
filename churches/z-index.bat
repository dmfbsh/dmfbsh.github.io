@echo off

CALL z-config.bat

del "%OUTFOLDER%\index.html"
copy "%OUTFOLDER%\index.md" "%OUTFOLDER%\index.html"
java -cp %CP% %EXE% -mode convert -file "%OUTFOLDER%\index.html"
java -cp %CP% %EXE% -mode construct -file "%OUTFOLDER%\index.html" -template %TEMPLATE%

del "%OUTFOLDER%\visiting.html"
copy "%OUTFOLDER%\visiting.md" "%OUTFOLDER%\visiting.html"
java -cp %CP% %EXE% -mode convert -file "%OUTFOLDER%\visiting.html"
java -cp %CP% %EXE% -mode construct -file "%OUTFOLDER%\visiting.html" -template %TEMPLATE%

pause
