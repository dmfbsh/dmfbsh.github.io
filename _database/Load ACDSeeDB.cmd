REM @ECHO OFF
PROMPT $Q$G

set DBFViewerEXE=C:\Program Files (x86)\DBF Viewer 2000\dbview.exe
set SQLite3EXE=C:\Users\David\Documents\iCloudDrive\27N4MQEA55~pro~writer\dmfbsh.github.io\_database\sqlite3.exe
set ACDSeeDBPath=C:\Users\David\Documents\NoneDrive\ACDSeeDB2020\ACDSeeDB2020
set TempPath=C:\Users\David\Documents\OneDrive\Documents\My Documents\3. Shropshire\Temp
set DBFile=C:\Users\David\Documents\OneDrive\Documents\My Documents\3. Shropshire\Database\Shropshire Photography.db

ECHO Exporting Category...
"%DBFViewerEXE%" "%ACDSeeDBPath%\Category.dbf" /EXPORT:"%TempPath%\ACDSee_Category.csv" /HDR /SKIPD
ECHO Exporting JoinCategoryAsset...
"%DBFViewerEXE%" "%ACDSeeDBPath%\JoinCategoryAsset.dbf" /EXPORT:"%TempPath%\ACDSee_JoinCategoryAsset.csv" /HDR /SKIPD
ECHO Exporting Asset...
"%DBFViewerEXE%" "%ACDSeeDBPath%\Asset.dbf" /EXPORT:"%TempPath%\ACDSee_Asset.csv" /HDR /SKIPD

ECHO DROP Table ACDSee_Category...
"%SQLite3EXE%" "%DBFile%" "DROP TABLE IF EXISTS ACDSee_Category;"
ECHO DROP Table ACDSee_JoinCategoryAsset...
"%SQLite3EXE%" "%DBFile%" "DROP TABLE IF EXISTS ACDSee_JoinCategoryAsset;"
ECHO DROP Table ACDSee_Asset...
"%SQLite3EXE%" "%DBFile%" "DROP TABLE IF EXISTS ACDSee_Asset;"

ECHO Import ACDSee_Category...
"%SQLite3EXE%" "%DBFile%" -cmd ".mode csv" ".import '%TempPath%\ACDSee_Category.csv' ACDSee_Category"
ECHO Import ACDSee_JoinCategoryAsset...
"%SQLite3EXE%" "%DBFile%" -cmd ".mode csv" ".import '%TempPath%\ACDSee_JoinCategoryAsset.csv' ACDSee_JoinCategoryAsset"
ECHO Import ACDSee_Asset...
"%SQLite3EXE%" "%DBFile%" -cmd ".mode csv" ".import '%TempPath%\ACDSee_Asset.csv' ACDSee_Asset"

ECHO Delete ACDSee_Temp...
"%SQLite3EXE%" "%DBFile%" "DELETE FROM ACDSee_Temp;"

ECHO Load churches...
"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Temp (Source, Category, FileName) SELECT 'ACDSee' AS Source, ACDSee_Category.NAME AS Category, ACDSee_Asset.NAME AS FileName FROM ACDSee_Asset, ACDSee_JoinCategoryAsset, ACDSee_Category WHERE ACDSee_Category.NAME = 'Church' AND ACDSee_Category.CAT_ID = ACDSee_JoinCategoryAsset.CAT_ID AND ACDSee_Asset.ASSET_ID = ACDSee_JoinCategoryAsset.ASSET_ID;"

ECHO Load gardens...
"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Temp (Source, Category, FileName) SELECT 'ACDSee' AS Source, ACDSee_Category.NAME AS Category, ACDSee_Asset.NAME AS FileName FROM ACDSee_Asset, ACDSee_JoinCategoryAsset, ACDSee_Category WHERE ACDSee_Category.NAME = 'Garden' AND ACDSee_Category.CAT_ID = ACDSee_JoinCategoryAsset.CAT_ID AND ACDSee_Asset.ASSET_ID = ACDSee_JoinCategoryAsset.ASSET_ID;"

ECHO Load history...
"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Temp (Source, Category, FileName) SELECT 'ACDSee' AS Source, ACDSee_Category.NAME AS Category, ACDSee_Asset.NAME AS FileName FROM ACDSee_Asset, ACDSee_JoinCategoryAsset, ACDSee_Category WHERE ACDSee_Category.NAME = 'History' AND ACDSee_Category.CAT_ID = ACDSee_JoinCategoryAsset.CAT_ID AND ACDSee_Asset.ASSET_ID = ACDSee_JoinCategoryAsset.ASSET_ID;"

ECHO Load castles...
"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Temp (Source, Category, FileName) SELECT 'ACDSee' AS Source, ACDSee_Category.NAME AS Category, ACDSee_Asset.NAME AS FileName FROM ACDSee_Asset, ACDSee_JoinCategoryAsset, ACDSee_Category WHERE ACDSee_Category.NAME = 'Castle' AND ACDSee_Category.CAT_ID = ACDSee_JoinCategoryAsset.CAT_ID AND ACDSee_Asset.ASSET_ID = ACDSee_JoinCategoryAsset.ASSET_ID;"

ECHO Load folklore...
"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Temp (Source, Category, FileName) SELECT 'ACDSee' AS Source, ACDSee_Category.NAME AS Category, ACDSee_Asset.NAME AS FileName FROM ACDSee_Asset, ACDSee_JoinCategoryAsset, ACDSee_Category WHERE ACDSee_Category.NAME = 'Folklore 1' AND ACDSee_Category.CAT_ID = ACDSee_JoinCategoryAsset.CAT_ID AND ACDSee_Asset.ASSET_ID = ACDSee_JoinCategoryAsset.ASSET_ID;"

"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Temp (Source, Category, FileName) SELECT 'ACDSee' AS Source, ACDSee_Category.NAME AS Category, ACDSee_Asset.NAME AS FileName FROM ACDSee_Asset, ACDSee_JoinCategoryAsset, ACDSee_Category WHERE ACDSee_Category.NAME = 'Folklore 2' AND ACDSee_Category.CAT_ID = ACDSee_JoinCategoryAsset.CAT_ID AND ACDSee_Asset.ASSET_ID = ACDSee_JoinCategoryAsset.ASSET_ID;"

ECHO Load house...
"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Temp (Source, Category, FileName) SELECT 'ACDSee' AS Source, ACDSee_Category.NAME AS Category, ACDSee_Asset.NAME AS FileName FROM ACDSee_Asset, ACDSee_JoinCategoryAsset, ACDSee_Category WHERE ACDSee_Category.NAME = 'House' AND ACDSee_Category.CAT_ID = ACDSee_JoinCategoryAsset.CAT_ID AND ACDSee_Asset.ASSET_ID = ACDSee_JoinCategoryAsset.ASSET_ID;"

ECHO Load people...
"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Temp (Source, Category, FileName) SELECT 'ACDSee' AS Source, ACDSee_Category.NAME AS Category, ACDSee_Asset.NAME AS FileName FROM ACDSee_Asset, ACDSee_JoinCategoryAsset, ACDSee_Category WHERE ACDSee_Category.NAME = 'People' AND ACDSee_Category.CAT_ID = ACDSee_JoinCategoryAsset.CAT_ID AND ACDSee_Asset.ASSET_ID = ACDSee_JoinCategoryAsset.ASSET_ID;"

ECHO Load landscape...
"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Temp (Source, Category, FileName) SELECT 'ACDSee' AS Source, ACDSee_Category.NAME AS Category, ACDSee_Asset.NAME AS FileName FROM ACDSee_Asset, ACDSee_JoinCategoryAsset, ACDSee_Category WHERE ACDSee_Category.NAME = 'Landscape' AND ACDSee_Category.CAT_ID = ACDSee_JoinCategoryAsset.CAT_ID AND ACDSee_Asset.ASSET_ID = ACDSee_JoinCategoryAsset.ASSET_ID;"

ECHO Load miscellaneous...
"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Temp (Source, Category, FileName) SELECT 'ACDSee' AS Source, ACDSee_Category.NAME AS Category, ACDSee_Asset.NAME AS FileName FROM ACDSee_Asset, ACDSee_JoinCategoryAsset, ACDSee_Category WHERE ACDSee_Category.NAME = 'Miscellaneous' AND ACDSee_Category.CAT_ID = ACDSee_JoinCategoryAsset.CAT_ID AND ACDSee_Asset.ASSET_ID = ACDSee_JoinCategoryAsset.ASSET_ID;"

ECHO Load place...
"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Temp (Source, Category, FileName) SELECT 'ACDSee' AS Source, ACDSee_Category.NAME AS Category, ACDSee_Asset.NAME AS FileName FROM ACDSee_Asset, ACDSee_JoinCategoryAsset, ACDSee_Category WHERE ACDSee_Category.NAME = 'Place' AND ACDSee_Category.CAT_ID = ACDSee_JoinCategoryAsset.CAT_ID AND ACDSee_Asset.ASSET_ID = ACDSee_JoinCategoryAsset.ASSET_ID;"

ECHO Delete ACDSee_Delta...
"%SQLite3EXE%" "%DBFile%" "DELETE FROM ACDSee_Delta;"

ECHO Compare churchs...
"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Delta (Status, FileName, Name) SELECT 'In ACDSee but NOT Database' AS Status, FileName, 'N/A' AS Name FROM ACDSee_Temp WHERE Category = 'Church' AND FileName NOT IN (SELECT OrigName FROM Place WHERE Category1 = 'Church');"

"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Delta (Status, FileName, Name) SELECT 'In Database but NOT ACDSee' AS Status, OrigName AS FileName, Name FROM Place WHERE Category1 = 'Church' AND OrigName NOT IN (SELECT FileName FROM ACDSee_Temp WHERE Category = 'Church');"

ECHO Compare gardens...
"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Delta (Status, FileName, Name) SELECT 'In ACDSee but NOT Database' AS Status, FileName, 'N/A' AS Name FROM ACDSee_Temp WHERE Category = 'Garden' AND FileName NOT IN (SELECT OrigName FROM Place WHERE Category1 = 'Garden');"

"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Delta (Status, FileName, Name) SELECT 'In Database but NOT ACDSee' AS Status, OrigName AS FileName, Name FROM Place WHERE Category1 = 'Garden' AND OrigName NOT IN (SELECT FileName FROM ACDSee_Temp WHERE Category = 'Garden');"

ECHO Compare history...
"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Delta (Status, FileName, Name) SELECT 'In ACDSee but NOT Database' AS Status, FileName, 'N/A' AS Name FROM ACDSee_Temp WHERE Category = 'History' AND FileName NOT IN (SELECT OrigName FROM Place WHERE Category1 = 'History');"

"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Delta (Status, FileName, Name) SELECT 'In Database but NOT ACDSee' AS Status, OrigName AS FileName, Name FROM Place WHERE Category1 = 'History' AND OrigName NOT IN (SELECT FileName FROM ACDSee_Temp WHERE Category = 'History');"

ECHO Compare castles...
"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Delta (Status, FileName, Name) SELECT 'In ACDSee but NOT Database' AS Status, FileName, 'N/A' AS Name FROM ACDSee_Temp WHERE Category = 'Castle' AND FileName NOT IN (SELECT OrigName FROM Place WHERE Category2 = 'Castle');"

"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Delta (Status, FileName, Name) SELECT 'In Database but NOT ACDSee' AS Status, OrigName AS FileName, Name FROM Place WHERE Category2 = 'Castle' AND OrigName NOT IN (SELECT FileName FROM ACDSee_Temp WHERE Category = 'Castle');"

ECHO Compare folklore...
"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Delta (Status, FileName, Name) SELECT 'In ACDSee but NOT Database' AS Status, FileName, 'N/A' AS Name FROM ACDSee_Temp WHERE Category = 'Folklore 1' AND FileName NOT IN (SELECT OrigName FROM Place WHERE Category1 = 'History' AND Category2 = 'Folklore');"

"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Delta (Status, FileName, Name) SELECT 'In Database but NOT ACDSee' AS Status, OrigName AS FileName, Name FROM Place WHERE Category1 = 'History' AND Category2 = 'Folklore' AND OrigName NOT IN (SELECT FileName FROM ACDSee_Temp WHERE Category = 'Folklore 1');"

"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Delta (Status, FileName, Name) SELECT 'In ACDSee but NOT Database' AS Status, FileName, 'N/A' AS Name FROM ACDSee_Temp WHERE Category = 'Folklore 2' AND FileName NOT IN (SELECT OrigName FROM Place WHERE Category1 = 'Landscape' AND Category2 = 'Folklore');"

"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Delta (Status, FileName, Name) SELECT 'In Database but NOT ACDSee' AS Status, OrigName AS FileName, Name FROM Place WHERE Category1 = 'Landscape' AND Category2 = 'Folklore' AND OrigName NOT IN (SELECT FileName FROM ACDSee_Temp WHERE Category = 'Folklore 2');"

ECHO Compare house...
"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Delta (Status, FileName, Name) SELECT 'In ACDSee but NOT Database' AS Status, FileName, 'N/A' AS Name FROM ACDSee_Temp WHERE Category = 'House' AND FileName NOT IN (SELECT OrigName FROM Place WHERE Category2 = 'House');"

"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Delta (Status, FileName, Name) SELECT 'In Database but NOT ACDSee' AS Status, OrigName AS FileName, Name FROM Place WHERE Category2 = 'House' AND OrigName NOT IN (SELECT FileName FROM ACDSee_Temp WHERE Category = 'House');"

ECHO Compare people...
"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Delta (Status, FileName, Name) SELECT 'In ACDSee but NOT Database' AS Status, FileName, 'N/A' AS Name FROM ACDSee_Temp WHERE Category = 'People' AND FileName NOT IN (SELECT OrigName FROM Place WHERE Category2 = 'People');"

"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Delta (Status, FileName, Name) SELECT 'In Database but NOT ACDSee' AS Status, OrigName AS FileName, Name FROM Place WHERE Category2 = 'People' AND OrigName NOT IN (SELECT FileName FROM ACDSee_Temp WHERE Category = 'People');"

ECHO Compare landscape...
"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Delta (Status, FileName, Name) SELECT 'In ACDSee but NOT Database' AS Status, FileName, 'N/A' AS Name FROM ACDSee_Temp WHERE Category = 'Landscape' AND FileName NOT IN (SELECT OrigName FROM Place WHERE Category1 = 'Landscape');"

"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Delta (Status, FileName, Name) SELECT 'In Database but NOT ACDSee' AS Status, OrigName AS FileName, Name FROM Place WHERE Category1 = 'Landscape' AND OrigName NOT IN (SELECT FileName FROM ACDSee_Temp WHERE Category = 'Landscape');"

ECHO Compare miscellaneous...
"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Delta (Status, FileName, Name) SELECT 'In ACDSee but NOT Database' AS Status, FileName, 'N/A' AS Name FROM ACDSee_Temp WHERE Category = 'Miscellaneous' AND FileName NOT IN (SELECT OrigName FROM Place WHERE Category1 = 'Miscellaneous');"

"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Delta (Status, FileName, Name) SELECT 'In Database but NOT ACDSee' AS Status, OrigName AS FileName, Name FROM Place WHERE Category1 = 'Miscellaneous' AND OrigName NOT IN (SELECT FileName FROM ACDSee_Temp WHERE Category = 'Miscellaneous');"

ECHO Compare place...
"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Delta (Status, FileName, Name) SELECT 'In ACDSee but NOT Database' AS Status, FileName, 'N/A' AS Name FROM ACDSee_Temp WHERE Category = 'Place' AND FileName NOT IN (SELECT OrigName FROM Place WHERE Category1 = 'Place');"

"%SQLite3EXE%" "%DBFile%" "INSERT INTO ACDSee_Delta (Status, FileName, Name) SELECT 'In Database but NOT ACDSee' AS Status, OrigName AS FileName, Name FROM Place WHERE Category1 = 'Place' AND OrigName NOT IN (SELECT FileName FROM ACDSee_Temp WHERE Category = 'Place');"

pause
