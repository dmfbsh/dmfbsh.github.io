@echo off

set EP=C:\Users\David\Documents\OneDrive\Documents\My Documents\Java-IntelliJ\Obsidian Notebook\src
set CP="C:\Users\David\Documents\OneDrive\Documents\My Documents\Java-IntelliJ\lib\commons-cli-1.11.0.jar;C:\Users\David\Documents\OneDrive\Documents\My Documents\Java-IntelliJ\lib\commons-io-2.22.0.jar"

set TEMPLATE="C:\Users\David\Documents\NoneDrive\GitHub\dmfbsh.github.io\churches\template.html"

set OUTFOLDER=C:\Users\David\Documents\NoneDrive\GitHub\dmfbsh.github.io\churches

java "%EP%\ChurchesDatabaseVisited.java"

java "%EP%\ChurchesDatabaseMaps.java"

java -cp %CP% "%EP%\TextProcessor.java" -mode construct -file "%OUTFOLDER%\hereford.html" -template %TEMPLATE%

java -cp %CP% "%EP%\TextProcessor.java" -mode construct -file "%OUTFOLDER%\lichfield.html" -template %TEMPLATE%

pause
