{{TOC}}

# Web Site Updates

## Need Photo

- Cosford RAF Museum
- Wroxeter - Vineyard
- Wem - Henry Eckford
- Telford - Matthew Webb Statue
- Lilleshall - Abbey
- Ironbridge - Merrythought
- Harper Adams College
- David Austin Roses

## Need Notes

- Folklore - The Wrekin
- Folklore - The Devil’s Chair
- Acton Scott - Church
- Morville - Hall
- Whitchurch - Church
- Titterstone Clee Hill Quarry
- Telford - Matthew Webb Statue
- Shrewsbury - St Alkmund’s
- Shrewsbury - Mary Webb Statue

Mary Webb was a novelist and poet whose work is set mainly in the Shropshire countryside and features Shropshire characters and people.

Webb was born in Leighton in 1881.

- Pitchford - Hall
- Pitchford - Church
- Oswestry - Church
- Morville - Church
- Lilleshall - Abbey
- Hodnet - Hodnet Hall Garden
- Haughmond - Abbey
- Dudmaston Hall
- Shropshire Union Railways and Canal Company
- Betton Strange - Church
- Ightfield - Church
- Ightfield - Stone Cross

# Development

## Updates to AHK Application

Compare database with ACDSee

SELECT "Castle" AS Type, OrigName AS DBName From Place WHERE Category2 = "Castle"

SELECT NAME AS ACDSeeName FROM ACDSee_Asset, ACDSee_JoinCategoryAsset WHERE CAT_ID = "29.000000" AND ACDSee_Asset.ASSET_ID = ACDSee_JoinCategoryAsset.ASSET_ID

INSERT INTO ACDSee_Temp (Source, Category, FileName) SELECT "ACDSee" AS Source, ACDSee_Category.NAME AS Category, ACDSee_Asset.NAME AS FileName FROM ACDSee_Asset, ACDSee_JoinCategoryAsset, ACDSee_Category WHERE ACDSee_Category.CAT_ID = "29.000000" AND ACDSee_Category.CAT_ID = ACDSee_JoinCategoryAsset.CAT_ID AND ACDSee_Asset.ASSET_ID = ACDSee_JoinCategoryAsset.ASSET_ID

SELECT * FROM ACDSee_Temp WHERE Category = "Church" AND FileName NOT IN (SELECT OrigName FROM Place WHERE Category1 = "Church")

SELECT OrigName FROM Place WHERE Category1 = "Church" AND OrigName NOT IN (SELECT FileName FROM ACDSee_Temp WHERE Category = "Church")

SELECT DISTINCT SUBSTR(Name, 1, INSTR(Name, " - ")-1) FROM Place WHERE Name LIKE "% - %"
UNION
SELECT DISTINCT Name FROM Place WHERE INSTR(Name, " - ") = 0
ORDER BY Name

## Create a Reference Page


