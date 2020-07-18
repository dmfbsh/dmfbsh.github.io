#SingleInstance force

#Include %A_ScriptDir%\Class_SQLiteDB.ahk
#Include %A_ScriptDir%\Class_Trello.ahk
#Include %A_ScriptDir%\Class_KML.ahk

IniRead, tmpPath, %A_ScriptDir%\Shropshire Churches.ini, Paths, TempFolder

tmpJSON    := tmpPath . "\Ctemp.json"
boardsCSV  := tmpPath . "\boards.csv"
listsCSV   := tmpPath . "\lists.csv"

IniRead, ChurchesDB, %A_ScriptDir%\Shropshire Churches.ini, Database, DBFile

IniRead, mapFile, %A_ScriptDir%\Shropshire Churches.ini, Files, MapFile

IniRead, gmkFileN, %A_ScriptDir%\Shropshire Churches.ini, Files, KMLFileNorth
IniRead, gmkFileS, %A_ScriptDir%\Shropshire Churches.ini, Files, KMLFileSouth

list1 := ""
list2 := ""
list3 := ""
list4 := ""

gFilter := "sym LIKE '%'"

argChurch := ""

gChurches    := ""
gNumChurches := 0

NStatus1  := ""
NOverview := ""
NTrelloID := ""
LStatus1  := ""
LOverview := ""

TrelloAPI := new Trello
TrelloAPI.SetTmpJSONFile(tmpJSON)

KMLAPI := new KMLFile

DB := new SQLiteDB
DB.OpenDB(ChurchesDB)

boardID := TrelloAPI.GetBoardID("Shropshire", boardsCSV)
GetListsForBoard(boardID)

LoadChurches()

Menu, FileMenu, Add, Save, MenuSave
Menu, FileMenu, Add
Menu, FileMenu, Add, Reload, MenuReload
Menu, FileMenu, Add
Menu, FileMenu, Add, Exit, MenuExit
Menu, FilterMenu, Add, Clear Filter, MenuClearFilter
Menu, FilterMenu, Add
Menu, FilterMenu, Add, Blue Plus, MenuBluePlus
Menu, FilterMenu, Add, Yellow Plus, MenuYellowPlus
Menu, FilterMenu, Add, Yellow Plus Ticked, MenuYellowPlusTicked
Menu, FilterMenu, Add, Green Plus, MenuGreenPlus
Menu, ProjectMenu, Add, Generate GPX, MenuGenerateGPX
Menu, ProjectMenu, Add
Menu, ProjectMenu, Add, Import from KML, MenuImport
Menu, ProjectMenu, Add
Menu, ProjectMenu, Add, Compare Trello, MenuCompareTrello
;Menu, ProjectMenu, Add
;Menu, ProjectMenu, Add, Bulk Load Trello, MenuBulkLoadTrello
;Menu, ProjectMenu, Add
;Menu, ProjectMenu, Add, Bulk Clear Trello, MenuBulkClearTrello
Menu, HelpMenu, Add, About, MenuAbout
Menu, MyMenuBar, Add, File, :FileMenu
Menu, MyMenuBar, Add, Filter, :FilterMenu
Menu, MyMenuBar, Add, Project, :ProjectMenu
Menu, MyMenuBar, Add, Help, :HelpMenu
Gui, Menu, MyMenuBar

Gui +Resize +MinSize450x410

Gui, Add, ListBox, vChurchList gChurchList w200 h385, Empty|Null
GuiControl, , ChurchList, %gChurches%

Gui, Add, Text, x215 y5 section w120 h20, Status:
Gui, Add, DropDownList, ys vStatus1 gStatus1 w196 h180, blue plus|yellow plus|yellow plus ticked|green plus

Gui, Add, Text, x215 y25 section w120 h20,
Gui, Add, Text, ys w400 h20, Avoid using ampersand in the text below.

Gui, Add, Text, x215 y45 section w120 h20, Notepad:
Gui, Add, Edit, ys vOverview +Wrap w400 h160,

Gui, Add, StatusBar, ,

Gui, Show, w750 h410, Shropshire Churches

SB_SetParts(200)
SB_SetText("Number of Churches: " . gNumChurches, 1)

Return

GuiSize:
  GuiControl, Move, ChurchList, % "h" . A_GuiHeight - 25
  GuiControl, Move, Status1, % "w" .  A_GuiWidth - 350
  GuiControl, Move, Overview, % "w" .  A_GuiWidth - 350 "h" . A_GuiHeight - 250
  Return

GuiClose:
	DB.CloseDB()
	ExitApp

Status1:
	Gui, Submit, NoHide
  Return

ChurchList:
	Gui, Submit, NoHide
	argChurch := ChurchList
; This bit of code returns the index number rather than the value
;	GuiControl, +AltSubmit, PlaceList
;	Gui, Submit, NoHide
;	argPlacePos :=	PlaceList
;	GuiControl, -AltSubmit, PlaceList
	LoadChurch()
	DrawGUI()
  Return

MenuSave:
	Gui, Submit, NoHide
	if StrLen(argChurch) <> 0
	{
		GuiValues()
		SaveChurch()
	}
	else 
	{
    MsgBox, 48, Error, No Church is Selected
	}
  Return

MenuReload:
	if StrLen(argChurch) <> 0
	{
    tListID   := TrelloAPI.GetField("cards/" . NTrelloID . "/idList")
    NStatus1  := GetListSymbol(tListID)
    NOverview := TrelloAPI.GetField("cards/" . NTrelloID . "/desc")
    DrawGUI()
    UpdateChurch()
	}
	else 
	{
    MsgBox, 48, Error, No Church is Selected
	}
  Return

MenuExit:
	DB.CloseDB()
	ExitApp

MenuClearFilter:
  ClearFilter()
  ApplyFilter()
  Return

MenuBluePlus:
	ClearFilter()
	Menu, FilterMenu, Check, Blue Plus
	SB_SetText("Filter: Blue Plus", 2)
  gFilter := "sym = 'blue plus' OR sym = 'plus blue'"
  ApplyFilter()
  Return

MenuYellowPlus:
	ClearFilter()
	Menu, FilterMenu, Check, Yellow Plus
	SB_SetText("Filter: Yellow Plus", 2)
  gFilter := "sym = 'yellow plus' OR sym = 'plus yellow'"
  ApplyFilter()
  Return

MenuYellowPlusTicked:
	ClearFilter()
	Menu, FilterMenu, Check, Yellow Plus Ticked
	SB_SetText("Filter: Yellow Plus Ticked", 2)
  gFilter := "sym LIKE '%ticked%'"
  ApplyFilter()
  Return

MenuGreenPlus:
	ClearFilter()
	Menu, FilterMenu, Check, Green Plus
	SB_SetText("Filter: Green Plus", 2)
  gFilter := "sym = 'green plus' OR sym = 'plus green'"
  ApplyFilter()
  Return

MenuImport:
	SQL := "DELETE FROM GoogleMap;"
  DB.Exec(SQL)
  KMLAPI.OpenKMLFile(gmkFileN)
  l := ""
  while (!(l == "END_OF_FILE"))
  {
    l := KMLAPI.GetNextPlacemarkName()
    if (!(l == "END_OF_FILE"))
    {
    	n := l
    	p := KMLAPI.GetNextPlacemarkCoords()
    	c := StrSplit(p, [","])
    	SQL := "INSERT INTO GoogleMap (name, lat, long) VALUES (""" . n . """,""" . c[1] . """,""" . c[2] . """);"
      DB.Exec(SQL)
    }
  }
  KMLAPI.CloseKMLFile()
  KMLAPI.OpenKMLFile(gmkFileS)
  l := ""
  while (!(l == "END_OF_FILE"))
  {
    l := KMLAPI.GetNextPlacemarkName()
    if (!(l == "END_OF_FILE"))
    {
    	n := l
    	p := KMLAPI.GetNextPlacemarkCoords()
    	c := StrSplit(p, [","])
    	SQL := "INSERT INTO GoogleMap (name, lat, long) VALUES (""" . n . """,""" . c[1] . """,""" . c[2] . """);"
      DB.Exec(SQL)
    }
  }
  KMLAPI.CloseKMLFile()
  MsgBox, Google Maps data reloaded
  Return

MenuGenerateGPX:
	GenerateGPXFile()
  Return

MenuCompareTrello:
	CompareTrello()
  Return

MenuBulkLoadTrello:
	CreateAllChurchCards()
  Return

MenuBulkClearTrello:
  DeleteAllChurchCards()
  Return

MenuAbout:
  Return

ClearFilter() {
  global
  gFilter := "sym LIKE '%'"
	Menu, FilterMenu, Uncheck, Blue Plus
	Menu, FilterMenu, Uncheck, Yellow Plus
	Menu, FilterMenu, Uncheck, Yellow Plus Ticked
	Menu, FilterMenu, Uncheck, Green Plus
  SB_SetText("", 2)
}

ApplyFilter() {
  global
  LoadChurches()
	GuiControl, , ChurchList, %gChurches%
	DefaultChurch()
	argChurch := ""
	DrawGUI()
	SB_SetText("Number of Churches: " . gNumChurches, 1)
}

DefaultChurch() {
	global
	NOverview := ""
}

LoadChurches() {
; Note that the list of places needs a pipe as the first character so
; that it replaces the existing list otherwise it will append
  global
  gChurches := ""
  gNumChurches := 0
  RecordSet := ""
  SQL := "SELECT name FROM Church WHERE " . gFilter . " ORDER BY name;"
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0) {
    	gNumChurches := gNumChurches + 1
      gChurches := gChurches . "|" . row[1]
    }
  } Until RC < 1
  RecordSet.Free()
}

LoadChurch() {
  global
  RecordSet := ""
  SQL := "SELECT desc, sym, TrelloCard FROM Church WHERE name=""" . argChurch . """;"
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0) {
			NOverview := Row[1]
			NStatus1  := Row[2]
			NTrelloID := Row[3]
    }
  } Until RC < 1
  RecordSet.Free()
  switch NStatus1
  {
    case "plus blue": NStatus1 := "blue plus"
    case "plus yellow": NStatus1 := "yellow plus"
    case "plus yellow ticked": NStatus1 := "yellow plus ticked"
    case "yellow ticked plus": NStatus1 := "yellow plus ticked"
    case "plus ticked yellow": NStatus1 := "yellow plus ticked"
    case "ticked yellow plus": NStatus1 := "yellow plus ticked"
    case "ticked plus yellow": NStatus1 := "yellow plus ticked"
    case "plus green": NStatus1 := "green plus"
  }
  LOverview := NOverview
  LStatus1  := NStatus1
}

SaveChurch() {
	global
  listID := ""
  switch NStatus1
  {
	  case "blue plus": listID := list1
	  case "yellow plus": listID := list2
	  case "yellow plus ticked": listID := list3
	  case "green plus": listID := list4
  }
  if LStatus1 <> %NStatus1%
  {
	  TrelloAPI.UpdateCard(NTrelloID, "idList=" . listID)
  }
  if LOverview <> %NOverview%
  {
	  TrelloAPI.UpdateCard(NTrelloID, "desc=" . NOverview)
  }
	UpdateChurch()
}

UpdateChurch() {
	global
	tDesc := StrReplace(NOverview, """", """""")
  if LOverview <> %NOverview%
  {
	  SQL := "UPDATE Church SET desc = """ . tDesc . """ WHERE name = '" . argChurch . "';"
	  DB.Exec(SQL)
  }
  if LStatus1 <> %NStatus1%
  {
  	SQL := "UPDATE Church SET sym = '" . NStatus1 . "' WHERE name = '" . argChurch . "';"
	  DB.Exec(SQL)
  }
  LOverview := NOverview
  LStatus1  := NStatus1
}

DrawGUI() {
  global
	GuiControl, Text, Overview, %NOverview%	
	GuiControl, ChooseString, Status1, %NStatus1%
}

GUIValues() {
  global
	NOverview := Overview
	NStatus1  := Status1
}

GetListSymbol(pListID) {
	global
	retSym := ""
  SQL := "SELECT Symbol FROM List WHERE ID = '" . pListID . "';"
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0)
    {
    	retSym := row[1]
    }
  }	Until RC < 1
  RecordSet.Free()
  Return retSym
}

CompareTrello() {
	global
  SQL := "SELECT TrelloCard, name, sym, desc FROM Church ORDER BY name;"
  DB.Query(SQL, RecordSetC)
  Loop {
    RCC := RecordSetC.Next(RowC)
    if (RCC > 0)
    {
      SB_SetText(RowC[2], 2)	
      tListID  := TrelloAPI.GetField("cards/" . RowC[1] . "/idList")
      tStatus1 := GetListSymbol(tListID)
      if (RowC[3] <> tStatus1)
      {
      	tN := RowC[2]
      	MsgBox, Card is in the wrong column: %tN%
      }
      tOverview := TrelloAPI.GetField("cards/" . RowC[1] . "/desc")
      if (RowC[4] <> tOverview)
      {
      	tN := RowC[2]
      	MsgBox, Card has mismatched descriptions: %tN%
      }
      tName := TrelloAPI.GetField("cards/" . RowC[1] . "/name")
      if (RowC[2] <> tName)
      {
      	tN := RowC[2]
      	MsgBox, Card has mismatched names: %tN%
      }
    }
  }	Until RCC < 1
  RecordSetC.Free()
  SB_SetText("", 2)	
}

CreateAllChurchCards() {
	global
  SQL := "SELECT name, lat, lon, desc, sym FROM Church ORDER BY name;"
  Progress, 0, Starting..., Processing..., Create Trello Cards
  count := 0
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0)
    {
;  	  if (count < 6)
;  	  {
  		  listID := ""
  		  tSym := row[5]
  		  IfInString, tSym, ticked
  		  {
  			  tSym := "ticked"
  		  }
  		  switch tSym
  		  {
  			  case "blue plus": listID := list1
  			  case "plus blue": listID := list1
  			  case "yellow plus": listID := list2
  			  case "plus yellow": listID := list2
  			  case "ticked": listID := list3
  			  case "green plus": listID := list4
  			  case "plus green": listID := list4
  		  }
  		  tN := row[1]
  		  tP := (count / 313) * 100
        Progress, %tp%, %tN%, Processing..., Create Trello Cards
  		  retID := TrelloAPI.CreateCard(listID, row[1])
        TrelloAPI.UpdateCard(retID, "coordinates=" . row[2] . "," . row[3])
        TrelloAPI.UpdateCard(retID, "desc=" . row[4])
        SQL := "UPDATE Church SET TrelloCard = '" . retID . "' WHERE name = """ . row[1] . """;"
        DB.Exec(SQL)
  		  count := count + 1
;  	  }
    }
  }	Until RC < 1
  RecordSet.Free()
  Progress, Off
}

DeleteAllChurchCards() {
	global
	SQL := "SELECT TrelloCard, name FROM Church WHERE TrelloCard IS NOT NULL;"
  Progress, 0, Starting..., Processing..., Delete Trello Cards
  DB.Query(SQL, RecordSet)
  count := 0
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0)
    {
    	count := count + 1
  		tN := row[2]
  		tP := (count / 313) * 100
      Progress, %tp%, %tN%, Processing..., Delete Trello Cards
    	TrelloAPI.DeleteCard(row[1])
    }
  }	Until RC < 1
  RecordSet.Free()
  SQL := "UPDATE Church SET TrelloCard = Null;"
  DB.Exec(SQL)
  Progress, Off
}

GetListsForBoard(pID) {
  global
  TrelloAPI.RunCommand("boards/" . pID . "/lists?fields=name")
  TrelloAPI.ConvertJSONToCSV(listsCSV)
  SQL := "DELETE FROM List;"
  DB.Exec(SQL)

  listsArray := []

  Loop, read, %listsCSV%
  {
  	listIdx := A_Index
  	Loop, parse, A_LoopReadLine, CSV
  	{
  		listsArray[listIdx, A_Index] := A_LoopField
  	}
  }

  For Each, Row in listsArray
  {
  	tList := Row[2]
  	tSym := ""
  	if tList = Church - Pending Visit
  	{
  		list1 := Row[1]
  		tSym := "blue plus"
  	}
  	if tList = Church - Planned to Visit
  	{
  		list2 := Row[1]
  		tSym := "yellow plus"
  	}
  	if tList = Church - Planned to Visit - Priority
  	{
  		list3 := Row[1]
  		tSym := "yellow plus ticked"
  	}
  	if tList = Church - Visited
  	{
  		list4 := Row[1]
  		tSym := "green plus"
  	}
  	SQL := "INSERT INTO List (ID, Name, Board, Symbol) VALUES (""" . Row[1] . """,""" . Row[2] . """,""" . pID . """,""" . tSym . """);"
  	DB.Exec(SQL)
  }
}

GenerateGPXFile() {
	global
	n := GetNextFileID()
	mapFileName := StrReplace(mapFile, "XXXX", n)
	mapFileHndl := FileOpen(mapFileName, "w")
	mapFileHndl.WriteLine("<?xml version=""1.0""?>")
;  mapFileHndl.WriteLine("<gpx xmlns=""http://www.topografix.com/GPX/1/1"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" xsi:schemaLocation=""http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd"" xmlns:gs=""http://ukmapapp.com/GPX_STYLESHEET/v1"" xmlns:i=""http://ukmapapp.com/GPX_IMPORTANCE/v1"" xmlns:gr=""http://ukmapapp.com/GPX_GRIDREF/v1"" version=""1.1"" creator=""UK Map 4.2"">")
  mapFileHndl.WriteLine("<gpx xmlns=""http://www.topografix.com/GPX/1/1"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" xsi:schemaLocation=""http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd"" >")
  mapFileHndl.WriteLine("<metadata>")
  mapFileHndl.WriteLine("<name>Shropshire - Churches v" . n . "</name>")
;  mapFileHndl.WriteLine("<bounds minlat=""52.356628"" minlon=""-3.000417"" maxlat=""52.671238"" maxlon=""-2.543808""/></metadata>")
  mapFileHndl.WriteLine("</metadata>")

  SQL := "SELECT c.name, c.sym, g.lat, g.long, c.desc, c.href FROM Church c, GoogleMap g WHERE c.name = g.name;"
;	SQL := "SELECT gr, lat, lon, desc, ele, importance, number, href, name, sym FROM Church ORDER BY name;"
;  Progress, 0, Starting..., Processing..., Create GPX File
;  count := 0
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0)
    {
    	SB_SetText(row[1], 2)	
;		  count := count + 1
;  		tN := row[9]
;  		tP := (count / 313) * 100
;      Progress, %tp%, %tN%, Processing..., Create GPX File
;      mapFileHndl.WriteLine("<wpt gr:gr=""" . row[1] . """ lat=""" . row[2] . """ lon=""" . row[3] . """>")
      mapFileHndl.WriteLine("<wpt lat=""" . row[3] . """ lon=""" . row[4] . """>")
;      mapFileHndl.WriteLine("<ele>" . row[5] . "</ele>")
      mapFileHndl.WriteLine("<name>" . row[1] . "</name>")
      if StrLen(row[5]) > 0
      {
      	mapFileHndl.WriteLine("<desc>" . row[5] . "</desc>")
      }
      if StrLen(row[6]) > 0
      {
      	mapFileHndl.WriteLine("<link href=""" . row[6] . """/>")
      }
      mapFileHndl.WriteLine("<sym>" . row[2] . "</sym>")
;      mapFileHndl.WriteLine("<extensions>")
;      mapFileHndl.WriteLine("<number>" . row[7] . "</number>")
;      mapFileHndl.WriteLine("<i:importance>" . row[6] . "</i:importance></extensions></wpt>")
      mapFileHndl.WriteLine("</wpt>")
    }
  }	Until RC < 1
  RecordSet.Free()
;  Progress, Off
 	SB_SetText("", 2)	

  mapFileHndl.WriteLine("</gpx>")
	mapFileHndl.Close()
;  IniRead, GooglePath, %A_ScriptDir%\Shropshire Churches.ini, Paths, GoogleDrive
;  FileCopy, %mapFileName%, %GooglePath%
}

GetNextFileID() {
	global
	nextID := "0000"
	nxtVer := 0
	SQL := "SELECT NextVersion FROM Config WHERE ID = 1;"
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0)
    {
    	nextID := nextID . row[1]
    	nxtVer := row[1] + 1
    }
  }	Until RC < 1
  RecordSet.Free()
  SQL := "UPDATE Config SET NextVersion = " . nxtVer . " WHERE ID = 1;"
  DB.Exec(SQL)
  Return SubStr(nextID, -3)
}
