#SingleInstance force

#Include %A_ScriptDir%\Class_SQLiteDB.ahk
#Include %A_ScriptDir%\Class_Trello.ahk
#Include %A_ScriptDir%\Class_JSON.ahk
#Include %A_ScriptDir%\Class_KML.ahk

IniRead, tmpPath, %A_ScriptDir%\Shropshire Places.ini, Paths, TempFolder

tmpJSON   := tmpPath . "\Ptemp.json"
tmpCSV    := tmpPath . "\Ptemp.csv"
boardsCSV := tmpPath . "\boards.csv"

IniRead, PlacesDB, %A_ScriptDir%\Shropshire Places.ini, Database, DBFile

IniRead, mapFile, %A_ScriptDir%\Shropshire Places.ini, Files, MapFile

IniRead, gmkFile, %A_ScriptDir%\Shropshire Places.ini, Files, KMLFile

argPlace := ""

gNewName := ""
gNewLat  := ""
gNewLong := ""

gPlaces    := ""
gNumPlaces := 0

NIsOnMapChanged := false
NIsOnTPEChanged := false
LHREF           := ""
LOverview       := ""

NIsOnMap  := false
NIsOnTPE  := false
NHREF     := ""
NOverview := ""
NTrelloID := ""
NAttID    := ""
	
IDIsOnMap := ""
IDIsOnTPE := ""

TrelloAPI := new Trello
TrelloAPI.SetTmpJSONFile(tmpJSON)

JSONAPI := new JSON

KMLAPI := new KMLFile

DB := new SQLiteDB
DB.OpenDB(PlacesDB)

boardID := TrelloAPI.GetBoardID("Shropshire", boardsCSV)
GetLabelsForBoard(boardID)

LoadPlaces()

Menu, FileMenu, Add, Import from KML, MenuImport
Menu, FileMenu, Add
Menu, FileMenu, Add, Import from Trello, MenuReload
Menu, FileMenu, Add
;Menu, FileMenu, Add, New, MenuNew
;Menu, FileMenu, Add
;Menu, FileMenu, Add, Save, MenuSave
;Menu, FileMenu, Add
;Menu, FileMenu, Add, Delete, MenuDelete
;Menu, FileMenu, Add
Menu, FileMenu, Add, Exit, MenuExit
Menu, FilterMenu, Add, Clear Filter, MenuClearFilter
Menu, FilterMenu, Add
Menu, FilterMenu, Add, Is On Map, MenuIsOnMap
Menu, FilterMenu, Add, Is On TPE, MenuIsOnTPE
Menu, ProjectMenu, Add, Generate GPX, MenuGenerateGPX
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

Gui, Add, ListBox, vPlaceList gPlaceList w200 h385, Empty|Null
GuiControl, , PlaceList, %gPlaces%

Gui, Add, Text, x215 y5 section w120 h20, Is on map?:
Gui, Add, CheckBox, ys vCBIsOnMap,

Gui, Add, Text, x215 y25 section w120 h20, Is on TPE?:
Gui, Add, CheckBox, ys vCBIsOnTPE,

Gui, Add, Text, x215 y45 section w120 h20, HREF:
Gui, Add, Edit, ys vHREF w400 h20,

Gui, Add, Text, x215 y65 section w120 h20,
Gui, Add, Text, ys w400 h20, Avoid using ampersand in the text below.

Gui, Add, Text, x215 y85 section w120 h20, Notepad (read only):
Gui, Add, Edit, ys vOverview +Wrap w400 h160,

Gui, Add, StatusBar, ,

Gui, Show, w750 h410, Shropshire Places

SB_SetParts(200)
SB_SetText("Number of Places: " . gNumPlaces, 1)
GetLastReload()

Return

GuiSize:
  GuiControl, Move, PlaceList, % "h" . A_GuiHeight - 25
  GuiControl, Move, Overview, % "w" .  A_GuiWidth - 350 "h" . A_GuiHeight - 250
  GuiControl, Move, HREF, % "w" .  A_GuiWidth - 350
  Return

GuiClose:
	DB.CloseDB()
	ExitApp

PlaceList:
	Gui, Submit, NoHide
	argPlace := PlaceList
; This bit of code returns the index number rather than the value
;	GuiControl, +AltSubmit, PlaceList
;	Gui, Submit, NoHide
;	argPlacePos :=	PlaceList
;	GuiControl, -AltSubmit, PlaceList
	LoadPlace()
	DrawGUI()
  Return

;CBIsOnMap:
;  NIsOnMapChanged := !NIsOnMapChanged
;  Return

;CBIsOnTPE:
;  NIsOnTPEChanged := !NIsOnTPEChanged
;  Return

;MenuNew:
;  Gui, NewStep1:Add, Text, xm section w300 h20, Enter the Lat and Long for the place:
;  Gui, NewStep1:Add, Edit, xm section w300 h20 vNewLatLong
;  Gui, NewStep1:Add, Text, xm section w300 h110, Use Google maps or similar to get the Lat and Long`nEnter as a ;single string with a comma or space between`nthe two values, e.g. 52.706600,-2.761074
;  Gui, NewStep1:Add, Button, xm section w50 h20, Next
;  Gui, NewStep1:Add, Button, ys w50 h20, Cancel
;  Gui, NewStep1:Show, w320 h200, Create New Place
;  Gui, 1:Default
;  Return

;NewStep1ButtonNext:
;	Gui, NewStep1:Submit, NoHide
;	gNewPos  := StrSplit(NewLatLong, [A_Space, ","])
;	gNewLat  := gNewPos[1]
;	gNewLong := gNewPos[2]
;  Gui, NewStep1:Destroy
;  Gui, NewStep2:Add, Text, xm section w300 h20, Enter the name of the place:
;  Gui, NewStep2:Add, Edit, xm section w300 h20 vNewName
;  Gui, NewStep2:Add, Text, xm section w300 h110,
;  Gui, NewStep2:Add, Button, xm section w50 h20, Next
;  Gui, NewStep2:Add, Button, ys w50 h20, Cancel
;  Gui, NewStep2:Show, w320 h200, Create New Place
;  Gui, 1:Default
;  Return

;NewStep2ButtonNext:
;	Gui, NewStep2:Submit, NoHide
;	gNewName := NewName
;  Gui, NewStep2:Destroy
;  Gui, NewStep3:Add, Text, xm section w300 h20, Create new place?
;  Gui, NewStep3:Add, Text, xm section w300 h20, %gNewName%
;  Gui, NewStep3:Add, Text, xm section w300 h20, %gNewLat%
;  Gui, NewStep3:Add, Text, xm section w300 h20, %gNewLong%
;  Gui, NewStep3:Add, Text, xm section w300 h50,
;  Gui, NewStep3:Add, Button, xm section w50 h20, Create
;  Gui, NewStep3:Add, Button, ys w50 h20, Cancel
;  Gui, NewStep3:Show, w320 h200, Create New Place
;  Return

;NewStep3ButtonCreate:
;  Gui, NewStep3:Destroy
;  retID := TrelloAPI.CreateCard("5ee24ea4f7b7c3593e1043fe", gNewName)
;  TrelloAPI.UpdateCard(retID, "coordinates=" . gNewLat . "," . gNewLong)
;	BackupTrello()
;  MsgBox, Trello data reloaded
;  Reload
;  Return

;NewStep1ButtonCancel:
;  Gui, NewStep1:Destroy
;  Return

;NewStep2ButtonCancel:
;  Gui, NewStep2:Destroy
;  Return

;NewStep3ButtonCancel:
;  Gui, NewStep3:Destroy
;  Return

;MenuSave:
;	Gui, Submit, NoHide
;	if StrLen(argPlace) <> 0
;	{
;		GuiValues()
;		SavePlace()
;	}
;	else 
;	{
;    MsgBox, 48, Error, No Place is Selected
;	}
;  Return

MenuImport:
	SQL := "DELETE FROM GoogleMap;"
  DB.Exec(SQL)
  KMLAPI.OpenKMLFile(gmkFile)
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
  Reload
  Return

MenuReload:
;	if StrLen(argPlace) <> 0
;	{
;    NOverview := TrelloAPI.GetField("cards/" . NTrelloID . "/desc")
;    GetLabelsForCard(NTrelloID)
;    GetURLAttachmentForCard(NTrelloID)
;    DrawGUI()
;    UpdatePlace()
;	}
;	else 
;	{
;    MsgBox, 48, Error, No Place is Selected
;	}
	SQL := "DELETE FROM TrelloCopy;"
  DB.Exec(SQL)
  TrelloAPI.RunCommand("lists/5ee24ea4f7b7c3593e1043fe/cards?fields=name,desc")
  FileRead, theJSON, %tmpJSON%
  JSONAPI.SetJSON(theJSON)
  a := JSONAPI.GetNextItem() ; Start the array of objects
  while (a <> "#EndArray")
  {
  	a := JSONAPI.GetNextItem()
  	if (a == "#StartObject")
  	{
  		JSONAPI.GetNextItem() ; id
  		JSONAPI.GetNextItem() ; :
  		i := JSONAPI.GetNextItem()
  		JSONAPI.GetNextItem() ; ,
  		JSONAPI.GetNextItem() ; name
  		JSONAPI.GetNextItem() ; :
  		n := JSONAPI.GetNextItem()
  		JSONAPI.GetNextItem() ; ,
  		JSONAPI.GetNextItem() ; desc
  		JSONAPI.GetNextItem() ; :
  		d := JSONAPI.GetNextItem()
;  		JSONAPI.GetNextItem() ; ,
;  		JSONAPI.GetNextItem() ; coordinates
;  		JSONAPI.GetNextItem() ; :
;  		z := JSONAPI.GetNextItem() ; { or null
;  		x := "0.0"
;  		y := "0.0"
;  		if (z == "#StartObject")
;  		{
;  		  JSONAPI.GetNextItem() ; lattitude
;  		  JSONAPI.GetNextItem() ; :
;  		  x := JSONAPI.GetNextItem()
;  		  JSONAPI.GetNextItem() ; ,
;  		  JSONAPI.GetNextItem() ; longitude
;  		  JSONAPI.GetNextItem() ; :
;  		  y := JSONAPI.GetNextItem()
;  		  JSONAPI.GetNextItem() ; }
;  		}
  		JSONAPI.GetNextItem() ; }
  		SQL := "INSERT INTO TrelloCopy (id, name, desc) VALUES (""" . i . """, """ . n . """, """ . d . """);"
  		DB.Exec(SQL)
  	}
  }
  FormatTime, tDT, , yyyy-MMM-dd HH:mm:ss
  SQL := "UPDATE Config SET LastReload='" . tDT . "' WHERE ID=1;"
  DB.Exec(SQL)
  RecordSet := ""
  SQL := "SELECT id, name FROM TrelloCopy;"
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0) {
    	SB_SetText(Row[2], 2)
    	GetURLAttachmentForCard(Row[1])
      SQL := "UPDATE TrelloCopy SET href='" . NHREF . "' WHERE id='" . Row[1] . "';"
      DB.Exec(SQL)
      GetLabelsForCard(Row[1])
  	  SQL := "UPDATE TrelloCopy SET IsOnMap = '" . NIsOnMap . "' WHERE id = '" . Row[1] . "';"
  	  DB.Exec(SQL)
	    SQL := "UPDATE TrelloCopy SET IsOnTPE = '" . NIsOnTPE . "' WHERE id = '" . Row[1] . "';"
	    DB.Exec(SQL)
    }
  } Until RC < 1
  RecordSet.Free()
  GetLastReload()
  MsgBox, Trello data reloaded
  Reload
  Return

;MenuDelete:
;  Return

MenuExit:
	DB.CloseDB()
	ExitApp

MenuClearFilter:
;  ClearFilter()
;  ApplyFilter()
  Return

MenuIsOnMap:
  Return

MenuIsOnTPE:
  Return

MenuGenerateGPX:
	GenerateGPXFile()
  Return

;MenuBulkLoadTrello:
;	CreateAllPlaceCards()
;  Return

;MenuBulkClearTrello:
;  DeleteAllPlaceCards()
;  Return

MenuAbout:
  Return

;ClearFilter() {
;  global
;  gFilter := "sym LIKE '%'"
;	Menu, FilterMenu, Uncheck, Blue Plus
;	Menu, FilterMenu, Uncheck, Yellow Plus
;	Menu, FilterMenu, Uncheck, Yellow Plus Ticked
;	Menu, FilterMenu, Uncheck, Green Plus
;  SB_SetText("", 2)
;}

;ApplyFilter() {
;  global
;  LoadChurches()
;	GuiControl, , ChurchList, %gChurches%
;	DefaultChurch()
;	argChurch := ""
;	DrawGUI()
;	SB_SetText("Number of Churches: " . gNumChurches, 1)
;}

;DefaultPlace() {
;	global
;  NIsOnMap  := false
;  NIsOnTPE  := false	
;	NOverview := ""
;}

LoadPlaces() {
; Note that the list of places needs a pipe as the first character so
; that it replaces the existing list otherwise it will append
  global
  gPlaces := ""
  gNumPlaces := 0
  RecordSet := ""
  SQL := "SELECT name FROM GoogleMap ORDER BY name;"
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0) {
    	gNumPlaces := gNumPlaces + 1
      gPlaces := gPlaces . "|" . row[1]
    }
  } Until RC < 1
  RecordSet.Free()
}

LoadPlace() {
  global
  RecordSet := ""
  SQL := "SELECT desc, id, IsOnMap, IsOnTPE, href FROM TrelloCopy WHERE name=""" . argPlace . """;"
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0) {
			NOverview := Row[1]
			NTrelloID := Row[2]
			NIsOnMap  := Row[3]
			NIsOnTPE  := Row[4]
			NHREF     := Row[5]
    }
  } Until RC < 1
  RecordSet.Free()
  NIsOnMapChanged := false
  NIsOnTPEChanged := false
  LHREF     := NHREF
  LOverview := NOverview
}

;SavePlace() {
;	global
;	if LOverview <> %NOverview%
;	{
;	  TrelloAPI.UpdateCard(NTrelloID, "desc=" . NOverview)
;	}
;	if NIsOnMapChanged
;	{
;  	if NIsOnMap = 1
;  	{
;  		TrelloAPI.AddLabelToCard(NTrelloID, IDIsOnMap)
;  	} else {
;  		TrelloAPI.RemoveLabelFromCard(NTrelloID, IDIsOnMap)
;  	}
;  }
;	if NIsOnTPEChanged
;	{
;  	if NIsOnTPE = 1
;  	{
;  		TrelloAPI.AddLabelToCard(NTrelloID, IDIsOnTPE)
;  	} else {
;  		TrelloAPI.RemoveLabelFromCard(NTrelloID, IDIsOnTPE)
;  	}
;  }
;  if LHREF <> %NHREF%
;  {
;  	if StrLen(NHREF) = 0
;  	{
;  		TrelloAPI.DeleteURLAttachmentFromCard(NTrelloID, NAttID)
;      SQL := "UPDATE Place SET TrelloAttachment = Null WHERE name = '" . argPlace . "';"
;      DB.Exec(SQL)
;  		NAttID := ""
;  	} else {
;  		if StrLen(LHREF) = 0
;  		{
;  			NAttID := TrelloAPI.AddURLAttachmentToCard(NTrelloID, NHREF)
;        SQL := "UPDATE Place SET TrelloAttachment = '" . NAttID . "' WHERE name = '" . argPlace . "';"
;        DB.Exec(SQL)
;  		} else {
;  		  TrelloAPI.DeleteURLAttachmentFromCard(NTrelloID, NAttID)
;  			NAttID := TrelloAPI.AddURLAttachmentToCard(NTrelloID, NHREF)
;        SQL := "UPDATE Place SET TrelloAttachment = '" . NAttID . "' WHERE name = '" . argPlace . "';"
;        DB.Exec(SQL)
;  		}
;  	}
;  }
;	UpdatePlace()
;}

;UpdatePlace() {
;	global
;	tDesc := StrReplace(NOverview, """", """""")
;	if LOverview <> %NOverview%
;	{
;	  SQL := "UPDATE Place SET desc = """ . tDesc . """ WHERE name = '" . argPlace . "';"
;	  DB.Exec(SQL)
;  }
;	if NIsOnMapChanged
;	{
;	  SQL := "UPDATE Place SET IsOnMap = '" . NIsOnMap . "' WHERE name = '" . argPlace . "';"
;	  DB.Exec(SQL)
;  }
;	if NIsOnTPEChanged
;	{
;	  SQL := "UPDATE Place SET IsOnTPE = '" . NIsOnTPE . "' WHERE name = '" . argPlace . "';"
;	  DB.Exec(SQL)
;	}
;  if LHREF <> %NHREF%
;  {
;	  SQL := "UPDATE Place SET href = '" . NHREF . "' WHERE name = '" . argPlace . "';"
;	  DB.Exec(SQL)
;	}
;  NIsOnMapChanged := false
;  NIsOnTPEChanged := false
;  LHREF     := NHREF
;  LOverview := NOverview
;}

DrawGUI() {
  global
	GuiControl, Text, Overview, %NOverview%
	GuiControl, Text, HREF, %NHREF%
	GuiControl, , CBIsOnMap, %NIsOnMap%
	GuiControl, , CBIsOnTPE, %NIsOnTPE%
}

;GUIValues() {
;  global
;	NOverview := Overview
;	NIsOnMap  := CBIsOnMap
;	NIsOnTPE  := CBIsOnTPE
;	NHREF     := HREF
;}

;CreateAllPlaceCards() {
;	global
;  SQL := "SELECT name, lat, lon, desc, gr, IsOnMap, IsOnTPE, href FROM Place ORDER BY name;"
;  Progress, 0, Starting..., Processing..., Create Trello Cards
;  count := 0
;  DB.Query(SQL, RecordSet)
;  Loop {
;    RC := RecordSet.Next(Row)
;    if (RC > 0)
;    {
;  		  tN := row[1]
;  		  tP := (count / gNumPlaces) * 100
;        Progress, %tp%, %tN%, Processing..., Create Trello Cards
;  		  retID := TrelloAPI.CreateCard("5ee24ea4f7b7c3593e1043fe", row[1])
;        SQL := "UPDATE Place SET TrelloCard = '" . retID . "' WHERE name = """ . row[1] . """;"
;        DB.Exec(SQL)
;  		  if StrLen(row[5]) > 0
;  		  {
;          TrelloAPI.UpdateCard(retID, "coordinates=" . row[2] . "," . row[3])
;  		  }
;        TrelloAPI.UpdateCard(retID, "desc=" . row[4])
;        if row[6] = 1
;        {
;          TrelloAPI.AddLabelToCard(retID, IDIsOnMap)
;        }
;        if row[7] = 1
;        {
;          TrelloAPI.AddLabelToCard(retID, IDIsOnTPE)
;        }
;  		  if StrLen(row[8]) > 0
;  		  {
;          attID := TrelloAPI.AddURLAttachmentToCard(retID, row[8])
;          SQL := "UPDATE Place SET TrelloAttachment = '" . attID . "' WHERE name = """ . row[1] . """;"
;          DB.Exec(SQL)
;        }
;  		  count := count + 1
;    }
;  }	Until RC < 1
;  RecordSet.Free()
;  Progress, Off
;}

;DeleteAllPlaceCards() {
;	global
;	SQL := "SELECT TrelloCard, name FROM Place WHERE TrelloCard IS NOT NULL;"
;  Progress, 0, Starting..., Processing..., Delete Trello Cards
;  DB.Query(SQL, RecordSet)
;  count := 0
;  Loop {
;    RC := RecordSet.Next(Row)
;    if (RC > 0)
;    {
;    	count := count + 1
;  		tN := row[2]
;  		tP := (count / gNumPlaces) * 100
;      Progress, %tp%, %tN%, Processing..., Delete Trello Cards
;    	TrelloAPI.DeleteCard(row[1])
;    }
;  }	Until RC < 1
;  RecordSet.Free()
;  SQL := "UPDATE Place SET TrelloCard = Null;"
;  DB.Exec(SQL)
;  Progress, Off
;}

GetLabelsForBoard(pID) {
	global
  TrelloAPI.RunCommand("boards/" . pID . "/labels?fields=name")
  TrelloAPI.ConvertJSONToCSV(tmpCSV)
  SQL := "DELETE FROM Label;"
  DB.Exec(SQL)

  labelsArray  := []

  Loop, read, %tmpCSV%
  {
  	labelIdx := A_Index
  	Loop, parse, A_LoopReadLine, CSV
  	{
  		labelsArray[labelIdx, A_Index] := A_LoopField
  	}
  }

  For Each, Row in labelsArray
  {
  	SQL := "INSERT INTO Label (ID, Name) VALUES (""" . Row[1] . """,""" . Row[2] . """);"
  	DB.Exec(SQL)
  	tN := Row[2]
  	if tN = Is On Map
  	{
  		IDIsOnMap := Row[1]
  	}
  	if tN = Is On TPE
  	{
  		IDIsOnTPE := Row[1]
  	}
  }
}

GetLabelsForCard(pCardID) {
  global
  NIsOnMap := 0
  NIsOnTPE := 0
  NIsOnMapChanged := true
  NIsOnTPEChanged := true
  TrelloAPI.RunCommand("cards/" . pCardID . "?fields=idLabels")
  FileGetSize, fileSize, %tmpJSON%
  if fileSize > 50
  {
    FileRead, cardLinks, %tmpJSON%
    cardLinks := SubStr(cardLinks, InStr(cardLinks, "[")+1)
    cardLinks := SubStr(cardLinks, 1, StrLen(cardLinks)-2)
    cardLinks := StrReplace(cardLinks, """", "")
    Loop, parse, cardLinks, `,
    {
    	if A_LoopField = %IDIsOnMap%
    	{
    		NIsOnMap := 1
    	}
    	if A_LoopField = %IDIsOnTPE%
    	{
    		NIsOnTPE := 1
    	}
    }
  }
}

GetURLAttachmentForCard(pCardID) {
  global
  NHREF := ""
  TrelloAPI.RunCommand("cards/" . pCardID . "/attachments?fields=url")
  FileGetSize, fileSize, %tmpJSON%
  if fileSize > 2
  {
    TrelloAPI.ConvertJSONToCSV(tmpCSV)
    Loop, read, %tmpCSV%
    {
  	  attachmentsIdx := A_Index
  	  Loop, parse, A_LoopReadLine, CSV
  	  {
  		  NHREF := A_LoopField
  	  }
    }
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
  mapFileHndl.WriteLine("<name>Shropshire - Places v" . n . "</name>")
;  mapFileHndl.WriteLine("<bounds minlat=""52.356628"" minlon=""-3.000417"" maxlat=""52.671238"" maxlon=""-2.543808""/></metadata>")
  mapFileHndl.WriteLine("</metadata>")

	SQL := "SELECT g.name, desc, lat, long FROM GoogleMap g, TrelloCopy t WHERE g.name = t.name ORDER BY g.name;"
;  Progress, 0, Starting..., Processing..., Create GPX File
  count := 0
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0)
    {
    	SB_SetText(row[1], 2)	
;		  count := count + 1
;  		tN := row[1]
;  		tP := (count / gNumPlacess) * 100
;      Progress, %tp%, %tN%, Processing..., Create GPX File
      mapFileHndl.WriteLine("<wpt lat=""" . row[3] . """ lon=""" . row[4] . """>")
;      mapFileHndl.WriteLine("<ele>" . row[5] . "</ele>")
      mapFileHndl.WriteLine("<name>" . row[1] . "</name>")
      if StrLen(row[2]) > 0
      {
      	mapFileHndl.WriteLine("<desc>" . row[2] . "</desc>")
      }
      mapFileHndl.WriteLine("<sym>yellow photo</sym>")
      mapFileHndl.WriteLine("</wpt>")
    }
  }	Until RC < 1
  RecordSet.Free()
;  Progress, Off

  mapFileHndl.WriteLine("</gpx>")
	mapFileHndl.Close()
  IniRead, GooglePath, %A_ScriptDir%\Shropshire Places.ini, Paths, GoogleDrive
  FileCopy, %mapFileName%, %GooglePath%
  GetLastReload()
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

GetLastReload() {
	global
	tDT := ""
	SQL := "SELECT LastReload FROM Config WHERE ID = 1;"
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0)
    {
    	tDT := row[1]
    }
  }	Until RC < 1
  RecordSet.Free()
  SB_SetText("Last Reload: " . tDT, 2)	
}
