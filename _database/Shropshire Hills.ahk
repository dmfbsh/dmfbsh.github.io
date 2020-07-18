#SingleInstance force

#Include %A_ScriptDir%\Class_SQLiteDB.ahk
#Include %A_ScriptDir%\Class_Trello.ahk
#Include %A_ScriptDir%\Class_JSON.ahk
#Include %A_ScriptDir%\Class_KML.ahk

IniRead, tmpPath, %A_ScriptDir%\Shropshire Hills.ini, Paths, TempFolder

tmpJSON := tmpPath . "\Htemp.json"

IniRead, HillsDB, %A_ScriptDir%\Shropshire Hills.ini, Database, DBFile

IniRead, mapFile, %A_ScriptDir%\Shropshire Hills.ini, Files, MapFile

IniRead, gmkFile, %A_ScriptDir%\Shropshire Hills.ini, Files, KMLFile

argHill := ""

gHills    := ""
gNumHills := 0

NOverview := ""
;LOverview := ""
;NTrelloID := ""

TrelloAPI := new Trello
TrelloAPI.SetTmpJSONFile(tmpJSON)

JSONAPI := new JSON

KMLAPI := new KMLFile

DB := new SQLiteDB
DB.OpenDB(HillsDB)

LoadHills()

;Menu, FileMenu, Add, Save, MenuSave
;Menu, FileMenu, Add
Menu, FileMenu, Add, Import from KML, MenuImport
Menu, FileMenu, Add
Menu, FileMenu, Add, Import from Trello, MenuReload
Menu, FileMenu, Add
Menu, FileMenu, Add, Exit, MenuExit
Menu, ProjectMenu, Add, Generate GPX, MenuGenerateGPX
;Menu, ProjectMenu, Add
;Menu, ProjectMenu, Add, Backup Trello, MenuBackupTrello
;Menu, ProjectMenu, Add
;Menu, ProjectMenu, Add, Bulk Load Trello, MenuBulkLoadTrello
;Menu, ProjectMenu, Add
;Menu, ProjectMenu, Add, Bulk Clear Trello, MenuBulkClearTrello
Menu, HelpMenu, Add, About, MenuAbout
Menu, MyMenuBar, Add, File, :FileMenu
Menu, MyMenuBar, Add, Project, :ProjectMenu
Menu, MyMenuBar, Add, Help, :HelpMenu
Gui, Menu, MyMenuBar

Gui +Resize +MinSize450x410

Gui, Add, ListBox, vHillList gHillList w200 h385, Empty|Null
GuiControl, , HillList, %gHills%

Gui, Add, Text, x215 y5 section w120 h20,
Gui, Add, Text, ys w400 h20, Avoid using ampersand in the text below.

Gui, Add, Text, x215 y25 section w120 h20, Notepad (read only):
Gui, Add, Edit, ys vOverview +Wrap w400 h160,

Gui, Add, StatusBar, ,

Gui, Show, w750 h410, Shropshire Hills

SB_SetParts(200)
SB_SetText("Number of Hills: " . gNumHills, 1)
GetLastReload()

Return

GuiSize:
  GuiControl, Move, HillList, % "h" . A_GuiHeight - 25
  GuiControl, Move, Overview, % "w" .  A_GuiWidth - 350 "h" . A_GuiHeight - 250
  Return

GuiClose:
	DB.CloseDB()
	ExitApp

HillList:
	Gui, Submit, NoHide
	argHill := HillList
; This bit of code returns the index number rather than the value
;	GuiControl, +AltSubmit, PlaceList
;	Gui, Submit, NoHide
;	argPlacePos :=	PlaceList
;	GuiControl, -AltSubmit, PlaceList
	LoadHill()
	DrawGUI()
  Return

;MenuSave:
;	Gui, Submit, NoHide
;	if StrLen(argHill) <> 0
;	{
;		GuiValues()
;		SaveHill()
;	}
;	else 
;	{
;    MsgBox, 48, Error, No Hill is Selected
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
;	if StrLen(argHill) <> 0
;	{
;    NOverview := TrelloAPI.GetField("cards/" . NTrelloID . "/desc")
;    DrawGUI()
;    UpdateHill()
;	}
;	else 
;	{
;    MsgBox, 48, Error, No Hill is Selected
;	}
	SQL := "DELETE FROM TrelloCopy;"
  DB.Exec(SQL)
  TrelloAPI.RunCommand("lists/5ee24ea21d034544ab584c90/cards?fields=name,desc")
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
;  		JSONAPI.GetNextItem() ; {
;  		JSONAPI.GetNextItem() ; lattitude
;  		JSONAPI.GetNextItem() ; :
;  		x := JSONAPI.GetNextItem()
;  		JSONAPI.GetNextItem() ; ,
;  		JSONAPI.GetNextItem() ; longitude
;  		JSONAPI.GetNextItem() ; :
;  		y := JSONAPI.GetNextItem()
;  		JSONAPI.GetNextItem() ; }
  		JSONAPI.GetNextItem() ; }
  		SQL := "INSERT INTO TrelloCopy (id, name, desc) VALUES (""" . i . """, """ . n . """, """ . d . """);"
  		DB.Exec(SQL)
  	}
  }
  FormatTime, tDT, , yyyy-MMM-dd HH:mm:ss
  SQL := "UPDATE Config SET LastReload='" . tDT . "' WHERE ID=1;"
  DB.Exec(SQL)
  GetLastReload()
  MsgBox, Trello data reloaded
  Reload
  Return

MenuExit:
	DB.CloseDB()
	ExitApp

MenuGenerateGPX:
	GenerateGPXFile()
  Return

;MenuBackupTrello:
;	BackupTrello()
;  Return

;MenuBulkLoadTrello:
;	CreateAllHillCards()
;  Return

;MenuBulkClearTrello:
;  DeleteAllHillCards()
;  Return

MenuAbout:
  Return

LoadHills() {
; Note that the list of places needs a pipe as the first character so
; that it replaces the existing list otherwise it will append
  global
  gHills := ""
  gNumHills := 0
  RecordSet := ""
  SQL := "SELECT name FROM GoogleMap ORDER BY name;"
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0) {
    	gNumHills := gNumHills + 1
      gHills := gHills . "|" . row[1]
    }
  } Until RC < 1
  RecordSet.Free()
}

LoadHill() {
  global
  RecordSet := ""
  SQL := "SELECT desc FROM TrelloCopy WHERE name=""" . argHill . """;"
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0) {
			NOverview := Row[1]
;			NTrelloID := Row[2]
    }
  } Until RC < 1
  RecordSet.Free()
;  LOverview := NOverview
}

;SaveHill() {
;	global
;	if LOverview <> %NOverview%
;	{
;	  TrelloAPI.UpdateCard(NTrelloID, "desc=" . NOverview)
;	}
;  UpdateHill()
;}

;UpdateHill() {
;	global
;	tDesc := StrReplace(NOverview, """", """""")
;	if LOverview <> %NOverview%
;	{
;  	SQL := "UPDATE Hill SET desc = """ . tDesc . """ WHERE name = '" . argHill . "';"
;	  DB.Exec(SQL)
;	}
;  LOverview := NOverview
;}

DrawGUI() {
  global
	GuiControl, Text, Overview, %NOverview%	
}

;GUIValues() {
;  global
;	NOverview := Overview
;}

;CreateAllHillCards() {
;	global
;  SQL := "SELECT name, lat, lon, desc FROM Hill ORDER BY name;"
;  Progress, 0, Starting..., Processing..., Create Trello Cards
;  count := 0
;  DB.Query(SQL, RecordSet)
;  Loop {
;    RC := RecordSet.Next(Row)
;    if (RC > 0)
;    {
;  		  listID := ""
;  		  tN := row[1]
;  		  tP := (count / gNumHills) * 100
;        Progress, %tp%, %tN%, Processing..., Create Trello Cards
;  		  retID := TrelloAPI.CreateCard("5ee24ea21d034544ab584c90", row[1])
;        TrelloAPI.UpdateCard(retID, "coordinates=" . row[2] . "," . row[3])
;        TrelloAPI.UpdateCard(retID, "desc=" . row[4])
;        SQL := "UPDATE Hill SET TrelloCard = '" . retID . "' WHERE name = """ . row[1] . """;"
;        DB.Exec(SQL)
;  		  count := count + 1
;    }
;  }	Until RC < 1
;  RecordSet.Free()
;  Progress, Off
;}

;DeleteAllHillCards() {
;	global
;	SQL := "SELECT TrelloCard, name FROM Hill WHERE TrelloCard IS NOT NULL;"
;  Progress, 0, Starting..., Processing..., Delete Trello Cards
;  DB.Query(SQL, RecordSet)
;  count := 0
;  Loop {
;    RC := RecordSet.Next(Row)
;    if (RC > 0)
;    {
;    	count := count + 1
;  		tN := row[2]
;  		tP := (count / gNumHills) * 100
;      Progress, %tp%, %tN%, Processing..., Delete Trello Cards
;    	TrelloAPI.DeleteCard(row[1])
;    }
;  }	Until RC < 1
;  RecordSet.Free()
;  SQL := "UPDATE Hill SET TrelloCard = Null;"
;  DB.Exec(SQL)
;  Progress, Off
;}

GenerateGPXFile() {
	global
	n := GetNextFileID()
	mapFileName := StrReplace(mapFile, "XXXX", n)
	mapFileHndl := FileOpen(mapFileName, "w")
	mapFileHndl.WriteLine("<?xml version=""1.0""?>")
;  mapFileHndl.WriteLine("<gpx xmlns=""http://www.topografix.com/GPX/1/1"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" xsi:schemaLocation=""http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd"" xmlns:gs=""http://ukmapapp.com/GPX_STYLESHEET/v1"" xmlns:i=""http://ukmapapp.com/GPX_IMPORTANCE/v1"" xmlns:gr=""http://ukmapapp.com/GPX_GRIDREF/v1"" version=""1.1"" creator=""UK Map 4.2"">")
  mapFileHndl.WriteLine("<gpx xmlns=""http://www.topografix.com/GPX/1/1"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" xsi:schemaLocation=""http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd"" >")
  mapFileHndl.WriteLine("<metadata>")
  mapFileHndl.WriteLine("<name>Shropshire - Hills v" . n . "</name>")
;  mapFileHndl.WriteLine("<bounds minlat=""52.356628"" minlon=""-3.000417"" maxlat=""52.671238"" maxlon=""-2.543808""/></metadata>")
  mapFileHndl.WriteLine("</metadata>")

	SQL := "SELECT g.name, desc, lat, long FROM GoogleMap g, TrelloCopy t WHERE g.name = t.name ORDER BY g.name;"
;  Progress, 0, Starting..., Processing..., Create GPX File
;  count := 0
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0)
    {
    	SB_SetText(row[1], 2)	
;		  count := count + 1
;  		tN := row[1]
;  		tP := (count / gNumHills) * 100
;      Progress, %tp%, %tN%, Processing..., Create GPX File
      mapFileHndl.WriteLine("<wpt lat=""" . row[3] . """ lon=""" . row[4] . """>")
;      mapFileHndl.WriteLine("<ele>" . row[5] . "</ele>")
      mapFileHndl.WriteLine("<name>" . row[1] . "</name>")
      if StrLen(row[2]) > 0
      {
      	mapFileHndl.WriteLine("<desc>" . row[2] . "</desc>")
      }
      mapFileHndl.WriteLine("<sym>yellow</sym>")
      mapFileHndl.WriteLine("</wpt>")
    }
  }	Until RC < 1
  RecordSet.Free()
;  Progress, Off

  mapFileHndl.WriteLine("</gpx>")
	mapFileHndl.Close()
;  IniRead, GooglePath, %A_ScriptDir%\Shropshire Hills.ini, Paths, GoogleDrive
;  FileCopy, %mapFileName%, %GooglePath%
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
  SB_SetText("Last Trello Reload: " . tDT, 2)	
}
