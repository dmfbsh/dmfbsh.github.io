#SingleInstance force

#Include %A_ScriptDir%\Class_SQLiteDB.ahk

tmpJSON    := "C:\Users\David\Documents\OneDrive\Documents\My Documents\3. Shropshire\Database\temp.json"
boardsCSV  := "C:\Users\David\Documents\OneDrive\Documents\My Documents\3. Shropshire\Database\boards.csv"
listsCSV   := "C:\Users\David\Documents\OneDrive\Documents\My Documents\3. Shropshire\Database\lists.csv"

ChurchesDB := "C:\Users\David\Documents\OneDrive\Documents\My Documents\3. Shropshire\Database\Shropshire - Churches.db"

mapFile    := "C:\Users\David\Documents\OneDrive\Documents\My Documents\GitHub\dmfbsh.github.io\_maps\Shropshire - Churches vXXXX.gpx"

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

DB := new SQLiteDB
DB.OpenDB(ChurchesDB)

boardID := GetBoardID()
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
Menu, ProjectMenu, Add, Bulk Load Trello, MenuBulkLoadTrello
Menu, ProjectMenu, Add
Menu, ProjectMenu, Add, Bulk Clear Trello, MenuBulkClearTrello
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
    tListID   := TrelloGetField("https://api.trello.com/1/cards/" . NTrelloID . "/idList")
    NStatus1  := GetListSymbol(tListID)
    NOverview := TrelloGetField("https://api.trello.com/1/cards/" . NTrelloID . "/desc")
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

MenuGenerateGPX:
	GenerateGPXFile()
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
}

SaveChurch() {
	global
	UpdateChurch()
  listID := ""
  switch NStatus1
  {
	  case "blue plus": listID := list1
	  case "yellow plus": listID := list2
	  case "yellow plus ticked": listID := list3
	  case "green plus": listID := list4
  }
	TrelloUpdateCard(NTrelloID, "idList=" . listID)
	TrelloUpdateCard(NTrelloID, "desc=" . NOverview)
}

UpdateChurch() {
	global
	tDesc := StrReplace(NOverview, """", """""")
	SQL := "UPDATE Church SET desc = """ . tDesc . """ WHERE name = '" . argChurch . "';"
	DB.Exec(SQL)
	SQL := "UPDATE Church SET sym = '" . NStatus1 . "' WHERE name = '" . argChurch . "';"
	DB.Exec(SQL)
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
  		  retID := TrelloCreateCard(listID, row[1])
        TrelloUpdateCard(retID, "coordinates=" . row[2] . "," . row[3])
        TrelloUpdateCard(retID, "desc=" . row[4])
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
    	TrelloDeleteCard(row[1])
    }
  }	Until RC < 1
  RecordSet.Free()
  SQL := "UPDATE Church SET TrelloCard = Null;"
  DB.Exec(SQL)
  Progress, Off
}

TrelloCreateCard(pListID, pCardName) {
	global
	tCardName := StrReplace(pCardName, " ", "%20")
	tCardName := StrReplace(tCardName, "'", "%27")
	tCardName := StrReplace(tCardName, """", "%22")
  cmd := """C:\Program Files\cURL\bin\curl.exe"" --request POST ""https://api.trello.com/1/cards?key=9ffaa9fbca828239fcb4034ee4e524b7&token=905e27f47d66cac8ffc9bb046924bf8e52c5f7c0780224fe466633d02e91bdf7&idList=" . pListID . "&name=" . tCardName . """ -o """ . tmpJSON . """"
  RunWait, %cmd%, , Hide
  FileRead, retJSON, %tmpJSON%
  return SubStr(retJSON, 8, 24)
}

TrelloUpdateCard(pCardID, pWhat) {
	global
	tWhat := StrReplace(pWhat, " ", "%20")
	tWhat := StrReplace(tWhat, "'", "%27")
	tWhat := StrReplace(tWhat, """", "%22")
	tWhat := StrReplace(tWhat, "`r", "%0D")
	tWhat := StrReplace(tWhat, "`n", "%0A")
  cmd := """C:\Program Files\cURL\bin\curl.exe"" --request PUT ""https://api.trello.com/1/cards/" . pCardID . "?key=9ffaa9fbca828239fcb4034ee4e524b7&token=905e27f47d66cac8ffc9bb046924bf8e52c5f7c0780224fe466633d02e91bdf7&" . tWhat . """"
  RunWait, %cmd%, , Hide
}

TrelloDeleteCard(pCardID) {
  global
  cmd := """C:\Program Files\cURL\bin\curl.exe"" --request DELETE ""https://api.trello.com/1/cards/" . pCardID . "?key=9ffaa9fbca828239fcb4034ee4e524b7&token=905e27f47d66cac8ffc9bb046924bf8e52c5f7c0780224fe466633d02e91bdf7"""
  RunWait, %cmd%, , Hide
}

GetBoardID() {
	global
  RunTrelloCommand("https://api.trello.com/1/members/me/boards?fields=name")
  ConvertJSONToCSV(boardsCSV)

  FoundIt := false
  BoardID := ""

  Loop, read, %boardsCSV%
  {
    Loop, parse, A_LoopReadLine, CSV
    {
      if FoundIt
      {
      	BoardID := A_LoopField
      	FoundIt := false
      }
    	if A_LoopField = Shropshire - Churches
    	{
    		FoundIt := true
    	}
    }
  }
  Return BoardID
}

GetListsForBoard(pID) {
  global
  RunTrelloCommand("https://api.trello.com/1/boards/" . pID . "/lists?fields=name")
  ConvertJSONToCSV(listsCSV)
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
  	if tList = Pending Visit
  	{
  		list1 := Row[1]
  		tSym := "blue plus"
  	}
  	if tList = Planned to Visit
  	{
  		list2 := Row[1]
  		tSym := "yellow plus"
  	}
  	if tList = Planned to Visit - Priority
  	{
  		list3 := Row[1]
  		tSym := "yellow plus ticked"
  	}
  	if tList = Visited
  	{
  		list4 := Row[1]
  		tSym := "green plus"
  	}
  	SQL := "INSERT INTO List (ID, Name, Board, Symbol) VALUES (""" . Row[1] . """,""" . Row[2] . """,""" . pID . """,""" . tSym . """);"
  	DB.Exec(SQL)
  }
}

TrelloGetField(pCommand) {
	global
  cmd := """C:\Program Files\cURL\bin\curl.exe"" """ . pCommand . "?key=9ffaa9fbca828239fcb4034ee4e524b7&token=905e27f47d66cac8ffc9bb046924bf8e52c5f7c0780224fe466633d02e91bdf7"" -o """ . tmpJSON . """"
  RunWait, %cmd%, , Hide
  FileRead, retJSON, %tmpJSON%
  retJSON := SubStr(retJSON, 12, StrLen(retJSON)-14)
  retJSON := StrReplace(retJSON, "\""", """")
  retJSON := StrReplace(retJSON, "\n", "`n")
  Return retJSON
}

RunTrelloCommand(pCommand) {
	global
  cmd := """C:\Program Files\cURL\bin\curl.exe"" """ . pCommand . "&key=9ffaa9fbca828239fcb4034ee4e524b7&token=905e27f47d66cac8ffc9bb046924bf8e52c5f7c0780224fe466633d02e91bdf7"" -o """ . tmpJSON . """"
  RunWait, %cmd%, , Hide
}

ConvertJSONToCSV(pName) {
  global
  cmd := "powershell ""(Get-Content -Path '" . tmpJSON . "' | ConvertFrom-Json) | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1 | Set-Content '" . pName . "'"""
  RunWait, %cmd%, , Hide
}

GenerateGPXFile() {
	global
	mapFileName := StrReplace(mapFile, "XXXX", GetNextFileID())
	mapFileHndl := FileOpen(mapFileName, "w")
	mapFileHndl.WriteLine("<?xml version=""1.0""?>")
  mapFileHndl.WriteLine("<gpx xmlns=""http://www.topografix.com/GPX/1/1"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" xsi:schemaLocation=""http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd"" xmlns:gs=""http://ukmapapp.com/GPX_STYLESHEET/v1"" xmlns:i=""http://ukmapapp.com/GPX_IMPORTANCE/v1"" xmlns:gr=""http://ukmapapp.com/GPX_GRIDREF/v1"" version=""1.1"" creator=""UK Map 4.2"">")
  mapFileHndl.WriteLine("<metadata>")
  mapFileHndl.WriteLine("<name>Shropshire - Churches</name>")
  mapFileHndl.WriteLine("<bounds minlat=""52.307598"" minlon=""-3.183949"" maxlat=""52.978367"" maxlon=""-2.277569""/></metadata>")

	SQL := "SELECT gr, lat, lon, desc, ele, importance, number, href, name, sym FROM Church ORDER BY name;"
  Progress, 0, Starting..., Processing..., Create GPX File
  count := 0
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0)
    {
		  count := count + 1
  		tN := row[9]
  		tP := (count / 313) * 100
      Progress, %tp%, %tN%, Processing..., Create GPX File
      mapFileHndl.WriteLine("<wpt gr:gr=""" . row[1] . """ lat=""" . row[2] . """ lon=""" . row[3] . """>")
      mapFileHndl.WriteLine("<ele>" . row[5] . "</ele>")
      mapFileHndl.WriteLine("<name>" . row[9] . "</name>")
      if StrLen(row[4]) > 0
      {
      	mapFileHndl.WriteLine("<desc>" . row[4] . "</desc>")
      }
      if StrLen(row[8]) > 0
      {
      	mapFileHndl.WriteLine("<link href=""" . row[8] . """/>")
      }
      mapFileHndl.WriteLine("<sym>" . row[10] . "</sym>")
      mapFileHndl.WriteLine("<extensions>")
      mapFileHndl.WriteLine("<number>" . row[7] . "</number>")
      mapFileHndl.WriteLine("<i:importance>" . row[6] . "</i:importance></extensions></wpt>")
    }
  }	Until RC < 1
  RecordSet.Free()
  Progress, Off

  mapFileHndl.WriteLine("</gpx>")
	mapFileHndl.Close()
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

;"C:\Program Files\cURL\bin\curl.exe" --request PUT "https://api.trello.com/1/cards/5ed792b106ef775c3b9fef16?key=9ffaa9fbca828239fcb4034ee4e524b7&token=905e27f4;7d66cac8ffc9bb046924bf8e52c5f7c0780224fe466633d02e91bdf7&locationName=locNam789"

;"C:\Program Files\cURL\bin\curl.exe" --request PUT "https://api.trello.com/1/cards/5ed792b106ef775c3b9fef16?key=9ffaa9fbca828239fcb4034ee4e524b7&token=905e27f47d66cac8ffc9bb046924bf8e52c5f7c0780224fe466633d02e91bdf7&address=addr456"

;"C:\Program Files\cURL\bin\curl.exe" --request PUT "https://api.trello.com/1/cards/5ed7a2dbe2fac00ab8989755?key=9ffaa9fbca828239fcb4034ee4e524b7&token=905e27f47d66cac8ffc9bb046924bf8e52c5f7c0780224fe466633d02e91bdf7&coordinates=52.613159,-2.690590"

;"C:\Program Files\cURL\bin\curl.exe" --request PUT "https://api.trello.com/1/cards/5ed792b106ef775c3b9fef16?key=9ffaa9fbca828239fcb4034ee4e524b7&token=905e27f47d66cac8ffc9bb046924bf8e52c5f7c0780224fe466633d02e91bdf7&name=update123"

;"C:\Program Files\cURL\bin\curl.exe" --request POST "https://api.trello.com/1/cards?key=9ffaa9fbca828239fcb4034ee4e524b7&token=905e27f47d66cac8ffc9bb046924bf8e52c5f7c0780224fe466633d02e91bdf7&idList=5ed792adb072c014e36d4f12&name=New Card"
