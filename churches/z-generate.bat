@echo off

CALL z-config.bat

java -cp %CP% %EXE% -mode split -file %MARKDOWNFILE% -sep "___" -folder "%OUTFOLDER%"

del "%OUTFOLDER%\index.html"
copy "%OUTFOLDER%\index.md" "%OUTFOLDER%\index.html"
java -cp %CP% %EXE% -mode convert -file "%OUTFOLDER%\index.html"
java -cp %CP% %EXE% -mode construct -file "%OUTFOLDER%\index.html" -template %TEMPLATE%

del "%OUTFOLDER%\visiting.html"
copy "%OUTFOLDER%\visiting.md" "%OUTFOLDER%\visiting.html"
java -cp %CP% %EXE% -mode convert -file "%OUTFOLDER%\visiting.html"
java -cp %CP% %EXE% -mode construct -file "%OUTFOLDER%\visiting.html" -template %TEMPLATE%

del "%OUTFOLDER%\about.html"
copy "%OUTFOLDER%\about.md" "%OUTFOLDER%\about.html"
java -cp %CP% %EXE% -mode convert -file "%OUTFOLDER%\about.html"
java -cp %CP% %EXE% -mode construct -file "%OUTFOLDER%\about.html" -template %TEMPLATE%

java -cp %CP% %EXE% -mode convert -file "%OUTFOLDER%\0.html"
java -cp %CP% %EXE% -mode construct -file "%OUTFOLDER%\0.html" -template %TEMPLATE%

java -cp %CP% %EXE% -mode convert -file "%OUTFOLDER%\1.html"
java -cp %CP% %EXE% -mode construct -file "%OUTFOLDER%\1.html" -template %TEMPLATE%

java -cp %CP% %EXE% -mode convert -file "%OUTFOLDER%\2.html"
java -cp %CP% %EXE% -mode construct -file "%OUTFOLDER%\2.html" -template %TEMPLATE%

java -cp %CP% %EXE% -mode convert -file "%OUTFOLDER%\3.html"
java -cp %CP% %EXE% -mode construct -file "%OUTFOLDER%\3.html" -template %TEMPLATE%

java -cp %CP% %EXE% -mode convert -file "%OUTFOLDER%\4.html"
java -cp %CP% %EXE% -mode construct -file "%OUTFOLDER%\4.html" -template %TEMPLATE%

java -cp %CP% %EXE% -mode convert -file "%OUTFOLDER%\5.html"
java -cp %CP% %EXE% -mode construct -file "%OUTFOLDER%\5.html" -template %TEMPLATE%

java -cp %CP% %EXE% -mode convert -file "%OUTFOLDER%\6.html"
java -cp %CP% %EXE% -mode construct -file "%OUTFOLDER%\6.html" -template %TEMPLATE%

java -cp %CP% %EXE% -mode convert -file "%OUTFOLDER%\7.html"
java -cp %CP% %EXE% -mode construct -file "%OUTFOLDER%\7.html" -template %TEMPLATE%

java -cp %CP% %EXE% -mode convert -file "%OUTFOLDER%\8.html"
java -cp %CP% %EXE% -mode construct -file "%OUTFOLDER%\8.html" -template %TEMPLATE%

java -cp %CP% %EXE% -mode convert -file "%OUTFOLDER%\9.html"
java -cp %CP% %EXE% -mode construct -file "%OUTFOLDER%\9.html" -template %TEMPLATE%

java -cp %CP% %EXE% -mode convert -file "%OUTFOLDER%\10.html"
java -cp %CP% %EXE% -mode construct -file "%OUTFOLDER%\10.html" -template %TEMPLATE%

java -cp %CP% %EXE% -mode convert -file "%OUTFOLDER%\13.html"
java -cp %CP% %EXE% -mode construct -file "%OUTFOLDER%\13.html" -template %TEMPLATE%

java -cp %CP% %EXE% -mode convert -file "%OUTFOLDER%\14.html"
java -cp %CP% %EXE% -mode construct -file "%OUTFOLDER%\14.html" -template %TEMPLATE%

java -cp %CP% %EXE% -mode convert -file "%OUTFOLDER%\15.html"
java -cp %CP% %EXE% -mode construct -file "%OUTFOLDER%\15.html" -template %TEMPLATE%

java -cp %CP% %EXE% -mode convert -file "%OUTFOLDER%\16.html"
java -cp %CP% %EXE% -mode construct -file "%OUTFOLDER%\16.html" -template %TEMPLATE%

java -cp %CP% %EXE% -mode convert -file "%OUTFOLDER%\17.html"
java -cp %CP% %EXE% -mode construct -file "%OUTFOLDER%\17.html" -template %TEMPLATE%

pause
