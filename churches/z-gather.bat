@echo off

CALL z-config.bat

java -cp %CP% "%EP%\ChurchesDatabaseGatherImages.java"

PAUSE
