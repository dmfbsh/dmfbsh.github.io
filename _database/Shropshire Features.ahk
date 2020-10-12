#SingleInstance force

#Include %A_ScriptDir%\Class_SQLiteDB.ahk
;#Include %A_ScriptDir%\Class_Airtable.ahk
;#Include %A_ScriptDir%\Class_JSON.ahk
#Include %A_ScriptDir%\Class_KML.ahk
#Include %A_ScriptDir%\Class_GoogleMyMaps.ahk
#Include %A_ScriptDir%\Class_Joplin.ahk

IniRead, tmpPath, %A_ScriptDir%\Shropshire Photography.ini, Paths, TempFolder
tmpJSON := tmpPath . "\Ftemp.json"

JoplinAPI := new Joplin
;AirtableAPI := new Airtable
;AirtableAPI.SetTmpJSONFile(tmpJSON)
KMLAPI  := new KMLFile
;JSONAPI := new JSON
MAPSAPI := new GoogleMyMaps

currTab := "Churches"

argChurch   := ""
gChurches   := ""
gNumChurchs := 0
gFilter     := "Status LIKE '%'"
gShropshirePlaces    := ""
gShropshireNumPlaces := 0
gShropshireLoaded    := false

argPlace    := ""
gPlaces     := ""
gNumPlaces  := 0

argHill     := ""
gHills      := ""
gNumHills   := 0

NData := {}

IniRead, FeaturesDB, %A_ScriptDir%\Shropshire Photography.ini, Database, DBFile

DB := new SQLiteDB
DB.OpenDB(FeaturesDB)

Menu, FileMenu, Add, Save, MenuSave
Menu, FileMenu, Add
Menu, FileMenu, Add, Reload, MenuReload
Menu, FileMenu, Add
Menu, FileMenu, Add, Exit, MenuExit
Menu, FilterMenu, Add, Clear Filter, MenuClearFilter
Menu, FilterMenu, Add
Menu, FilterMenu, Add, Not Yet Visited, MenuNotYetVisited
Menu, FilterMenu, Add, Planned to Visit, MenuPlannedtoVisit
Menu, FilterMenu, Add, Planned to Visit - Priority, MenuPlannedtoVisitPriority
Menu, FilterMenu, Add, Visited, MenuVisited
Menu, ChurchesMenu, Add, Open Map, MenuChurchesOpenMap
Menu, ChurchesMenu, Add, Download Map, MenuChurchesDownloadMap
Menu, ChurchesMenu, Add
Menu, ChurchesMenu, Add, Import KML, MenuChurchesImportKML
Menu, ChurchesMenu, Add
Menu, ChurchesMenu, Add, Compare Joplin, MenuChurchesCompareJoplin
Menu, ChurchesMenu, Add
Menu, ChurchesMenu, Add, Generate GPX, MenuChurchesGenerateGPX
Menu, PlacesMenu, Add, Open Map, MenuPlacesOpenMap
Menu, PlacesMenu, Add, Download Map, MenuPlacesDownloadMap
Menu, PlacesMenu, Add
Menu, PlacesMenu, Add, Joplin Import, MenuPlacesJoplinImport
Menu, PlacesMenu, Add
Menu, PlacesMenu, Add, Generate GPX, MenuPlacesGenerateGPX
Menu, HillsMenu, Add, Open Map, MenuHillsOpenMap
Menu, HillsMenu, Add, Download Map, MenuHillsDownloadMap
Menu, HillsMenu, Add
Menu, HillsMenu, Add, Joplin Import, MenuHillsJoplinImport
Menu, HillsMenu, Add
Menu, HillsMenu, Add, Generate GPX, MenuHillsGenerateGPX
Menu, HelpMenu, Add, About, MenuAbout

Menu, MyMenuBar, Add, File, :FileMenu
Menu, MyMenuBar, Add, Filter, :FilterMenu
Menu, MyMenuBar, Add, Churches, :ChurchesMenu
Menu, MyMenuBar, Add, Places, :PlacesMenu
Menu, MyMenuBar, Add, Hills, :HillsMenu
Menu, MyMenuBar, Add, Help, :HelpMenu

Gui, Menu, MyMenuBar

Gui +Resize +MinSize450x410

Gui, Add, Tab3, vDataTabs gDataTabs w730 h380, Churches||Places|Hills

Gui, Tab, 1
Gui, Add, ListBox, vChurchList gChurchList w200 h350, Empty|Null
Gui, Add, Text, x230 y35 section w120 h20, Shropshire Link:
Gui, Add, DropDownList, ys vShropshireList gShropshireList w370 h180,
Gui, Add, Text, x230 y55 section w120 h20, Status:
Gui, Add, DropDownList, ys vChurchStatus gChurchStatus w370 h180, Not Yet Visited|Planned to Visit|Planned to Visit - Priority|Visited
Gui, Add, Text, x230 y75 section w120 h20, Date:
Gui, Add, Edit, ys vChurchDates w370 h20,
Gui, Add, Text, x230 y100 section w120 h20, Need to Re-Visit?
Gui, Add, CheckBox, ys vCBChurchReVisit gCBChurchRevisit,
Gui, Add, Text, x230 y120 section w120 h20, Area:
Gui, Add, Edit, ys vChurchArea w370 h20,
Gui, Add, Text, x230 y140 section w120 h20,
Gui, Add, Text, ys w370 h20, Avoid using ampersand and double quotes in the text below.
Gui, Add, Text, x230 y160 section w120 h20, Notes:
Gui, Add, Edit, ys vChurchNotes +Wrap w370 h60,
Gui, Add, Text, x230 y225 section w120 h20, Details:
Gui, Add, Edit, ys vChurchDetails +Wrap w370 h145,

Gui, Tab, 2
Gui, Add, ListBox, vPlaceList gPlaceList w200 h350, Empty|Null
Gui, Add, Text, x230 y35 section w120 h20, In on Map?
Gui, Add, CheckBox, ys vCBPlaceIsonMap,
Gui, Add, Text, x230 y55 section w120 h20, In on TPE?
Gui, Add, CheckBox, ys vCBPlaceIsonTPE,
Gui, Add, Text, x230 y75 section w120 h20, Visited?
Gui, Add, CheckBox, ys vCBPlaceVisited,
Gui, Add, Text, x230 y95 section w120 h20, HREF:
Gui, Add, Edit, ys vPlaceHREF w370 h20,
Gui, Add, Text, x230 y115 section w120 h20,
Gui, Add, Text, ys w370 h20, Avoid using ampersand in the text below.
Gui, Add, Text, x230 y135 section w120 h20, Details:
Gui, Add, Edit, ys vPlaceDetails +Wrap w370 h160,

Gui, Tab, 3
Gui, Add, ListBox, vHillList gHillList w200 h350, Empty|Null
Gui, Add, Text, x230 y35 section w120 h20, Height:
Gui, Add, Edit, ys vHillHeight w370 h20,
Gui, Add, Text, x230 y60 section w120 h20, In on Map?
Gui, Add, CheckBox, ys vCBHillIsonMap,
Gui, Add, Text, x230 y80 section w120 h20, In on TPE?
Gui, Add, CheckBox, ys vCBHillIsonTPE,
Gui, Add, Text, x230 y100 section w120 h20,
Gui, Add, Text, ys w400 h20, Avoid using ampersand and double quotes in the text below.
Gui, Add, Text, x230 y120 section w120 h20, Details:
Gui, Add, Edit, ys vHillDetails +Wrap w370 h160,

Gui, Add, StatusBar, ,

Gui, Show, w750 h410, Shropshire Features

SB_SetParts(200)

Menu, PlacesMenu, Disable, Open Map
Menu, PlacesMenu, Disable, Download Map
Menu, PlacesMenu, Disable, Joplin Import
Menu, PlacesMenu, Disable, Generate GPX
Menu, HillsMenu, Disable, Open Map
Menu, HillsMenu, Disable, Download Map
Menu, HillsMenu, Disable, Joplin Import
Menu, HillsMenu, Disable, Generate GPX

LoadShropshirePlacesList()

LoadChurches()
GuiControl, , ChurchList, %gChurches%
SB_SetText("Number of Churches: " . gNumChurches, 1)
GetLastReload()

Return

GuiSize:
  GuiControl, Move, ChurchList, % "h" . A_GuiHeight - 60
  GuiControl, Move, ShropshireList, % "w" . A_GuiWidth - 380
  GuiControl, Move, ChurchStatus, % "w" . A_GuiWidth - 380
  GuiControl, Move, ChurchDates, % "w" . A_GuiWidth - 380
  GuiControl, Move, ChurchArea, % "w" . A_GuiWidth - 380
  GuiControl, Move, ChurchNotes, % "w" . A_GuiWidth - 380
  GuiControl, Move, ChurchDetails, % "w" . A_GuiWidth - 380 "h" . A_GuiHeight - 265
  GuiControl, Move, PlaceList, % "h" . A_GuiHeight - 60
  GuiControl, Move, PlaceHREF, % "w" . A_GuiWidth - 380
  GuiControl, Move, PlaceDetails, % "w" . A_GuiWidth - 380 "h" . A_GuiHeight - 250
  GuiControl, Move, HillList, % "h" . A_GuiHeight - 60
  GuiControl, Move, HillHeight, % "w" . A_GuiWidth - 380
  GuiControl, Move, HillDetails, % "w" . A_GuiWidth - 380 "h" . A_GuiHeight - 250
  ; Must be last, otherwise some controls won't render properly
  GuiControl, Move, DataTabs, % "w" . A_GuiWidth - 20 "h" . A_GuiHeight - 30
  Return

DataTabs:
  Gui, Submit, NoHide
  currTab := DataTabs
  if currTab = Churches
  {
    Menu, FileMenu, Enable, Save
    Menu, FileMenu, Enable, Reload
    Menu, FilterMenu, Enable, Clear Filter
    Menu, FilterMenu, Enable, Not Yet Visited
    Menu, FilterMenu, Enable, Planned to Visit
    Menu, FilterMenu, Enable, Planned to Visit - Priority
    Menu, FilterMenu, Enable, Visited
    Menu, ChurchesMenu, Enable, Open Map
    Menu, ChurchesMenu, Enable, Download Map
    Menu, ChurchesMenu, Enable, Generate GPX
    Menu, ChurchesMenu, Enable, Import KML
    Menu, ChurchesMenu, Enable, Compare Joplin
    Menu, PlacesMenu, Disable, Open Map
    Menu, PlacesMenu, Disable, Download Map
    Menu, PlacesMenu, Disable, Joplin Import
    Menu, PlacesMenu, Disable, Generate GPX
    Menu, HillsMenu, Disable, Open Map
    Menu, HillsMenu, Disable, Download Map
    Menu, HillsMenu, Disable, Joplin Import
    Menu, HillsMenu, Disable, Generate GPX
    LoadChurches()
    GuiControl, , ChurchList, %gChurches%
    SB_SetText("Number of Churches: " . gNumChurches, 1)
    GetLastReload()
  }
  if currTab = Places
  {
    Menu, FileMenu, Disable, Save
    Menu, FileMenu, Disable, Reload
    Menu, FilterMenu, Disable, Clear Filter
    Menu, FilterMenu, Disable, Not Yet Visited
    Menu, FilterMenu, Disable, Planned to Visit
    Menu, FilterMenu, Disable, Planned to Visit - Priority
    Menu, FilterMenu, Disable, Visited
    Menu, ChurchesMenu, Disable, Open Map
    Menu, ChurchesMenu, Disable, Download Map
    Menu, ChurchesMenu, Disable, Generate GPX
    Menu, ChurchesMenu, Disable, Import KML
    Menu, ChurchesMenu, Disable, Compare Joplin
    Menu, PlacesMenu, Enable, Open Map
    Menu, PlacesMenu, Enable, Download Map
    Menu, PlacesMenu, Enable, Joplin Import
    Menu, PlacesMenu, Enable, Generate GPX
    Menu, HillsMenu, Disable, Open Map
    Menu, HillsMenu, Disable, Download Map
    Menu, HillsMenu, Disable, Joplin Import
    Menu, HillsMenu, Disable, Generate GPX
    LoadPlaces()
    GuiControl, , PlaceList, %gPlaces%
    SB_SetText("Number of Places: " . gNumPlaces, 1)
    GetLastReload()
  }
  if currTab = Hills
  {
    Menu, FileMenu, Disable, Save
    Menu, FileMenu, Disable, Reload
    Menu, FilterMenu, Disable, Clear Filter
    Menu, FilterMenu, Disable, Not Yet Visited
    Menu, FilterMenu, Disable, Planned to Visit
    Menu, FilterMenu, Disable, Planned to Visit - Priority
    Menu, FilterMenu, Disable, Visited
    Menu, ChurchesMenu, Disable, Open Map
    Menu, ChurchesMenu, Disable, Download Map
    Menu, ChurchesMenu, Disable, Generate GPX
    Menu, ChurchesMenu, Disable, Import KML
    Menu, ChurchesMenu, Disable, Compare Joplin
    Menu, PlacesMenu, Disable, Open Map
    Menu, PlacesMenu, Disable, Download Map
    Menu, PlacesMenu, Disable, Joplin Import
    Menu, PlacesMenu, Disable, Generate GPX
    Menu, HillsMenu, Enable, Open Map
    Menu, HillsMenu, Enable, Download Map
    Menu, HillsMenu, Enable, Joplin Import
    Menu, HillsMenu, Enable, Generate GPX
    LoadHills()
    GuiControl, , HillList, %gHills%
    SB_SetText("Number of Hills: " . gNumHills, 1)
    GetLastReload()
  }
  Return

ShropshireList:
	Gui, Submit, NoHide
  Return

ChurchStatus:
	Gui, Submit, NoHide
  Return

CBChurchReVisit:
  NData["Need to Revisit"] := !NData["Need to Revisit"]
  Return

GuiClose:
	DB.CloseDB()
  ExitApp

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
;    rJSON := AirtableAPI.Select("Churches", gAirtable)
;    JSONAPI.SetJSON(rJSON)
;    NData["Details"] := ""
;    NData["Notes"] := ""
;    NData["Status"] := ""
;    NData["Date"] := ""
;    NData["Need to Revisit"] := 0
;    i := JSONAPI.GetNextItem() ; {
;    i := JSONAPI.GetNextItem() ; id
;    i := JSONAPI.GetNextItem() ; :
;    i := JSONAPI.GetNextItem() ; <id>
;    i := JSONAPI.GetNextItem() ; ,
;    i := JSONAPI.GetNextItem() ; fields
;    i := JSONAPI.GetNextItem() ; :
;    i := JSONAPI.GetNextItem() ; {
;    while (i <> "#EndObject")
;    {
;      k := JSONAPI.GetNextItem()
;      i := JSONAPI.GetNextItem()
;      v := JSONAPI.GetNextItem()
;      i := JSONAPI.GetNextItem()
;      if k = Details
;      {
;        NData[k] := v
;      }
;      if k = Notes
;      {
;        NData[k] := v
;      }
;      if k = Status
;      {
;        NData[k] := v
;      }
;      if k = Date
;      {
;        NData[k] := v
;      }
;      if k = Need to Revisit
;      {
;        if v = true
;          NData[k] := 1
;      }
;    }
    updChurch := JoplinAPI.SelectChurch(NData["Place"], NData["Dedication"])
    NData["Date"]    := updChurch["Date"]
    NData["Details"] := updChurch["Details"]
    NData["Notes"]   := updChurch["Notes"]
    NData["Status"]  := updChurch["Status"]
    v := updChurch["Revisit"]
    if v = No
      NData["Need to Revisit"] := 0
    else
      NData["Need to Revisit"] := 1
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

MenuNotYetVisited:
	ClearFilter()
	Menu, FilterMenu, Check, Not Yet Visited
	SB_SetText("Filter: Not Yet Visited", 2)
	gFilter := "Status = 'Not Yet Visited'"
  ApplyFilter()
  Return

MenuPlannedtoVisit:
	ClearFilter()
	Menu, FilterMenu, Check, Planned to Visit
	SB_SetText("Filter: Planned to Visit", 2)
	gFilter := "Status = 'Planned to Visit'"
  ApplyFilter()
  Return

MenuPlannedtoVisitPriority:
	ClearFilter()
	Menu, FilterMenu, Check, Planned to Visit - Priority
	SB_SetText("Filter: Planned to Visit - Priority", 2)
	gFilter := "Status = 'Planned to Visit - Priority'"
  ApplyFilter()
  Return

MenuVisited:
	ClearFilter()
	Menu, FilterMenu, Check, Visited
	SB_SetText("Filter: Visited", 2)
	gFilter := "Status = 'Visited'"
  ApplyFilter()
  Return

ClearFilter() {
  global
  gFilter := "Status LIKE '%'"
	Menu, FilterMenu, Uncheck, Not Yet Visited
	Menu, FilterMenu, Uncheck, Planned to Visit
	Menu, FilterMenu, Uncheck, Planned to Visit - Priority
	Menu, FilterMenu, Uncheck, Visited
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

MenuChurchesOpenMap:
  MAPSAPI.OpenChurches()
  Return

MenuChurchesDownloadMap:
  MAPSAPI.DownloadChurches()
  Return

MenuChurchesImportKML:
  ChurchesImportKML()
  Return

MenuChurchesCompareJoplin:
  ChurchesCompareJoplin()
  Return

MenuChurchesGenerateGPX:
  ChurchesGenerateGPXFile()
  Return

MenuPlacesOpenMap:
  MAPSAPI.OpenPlaces()
  Return

MenuPlacesDownloadMap:
  MAPSAPI.DownloadPlaces()
  Return

MenuPlacesJoplinImport:
  MsgBox, Sync Joplin
  PlacesJoplinImport()
  Return

MenuPlacesGenerateGPX:
  PlacesGenerateGPXFile()
  Return

MenuHillsOpenMap:
  MAPSAPI.OpenHills()
  Return

MenuHillsDownloadMap:
  MAPSAPI.DownloadHills()
  Return

MenuHillsJoplinImport:
  MsgBox, Sync Joplin
  HillsJoplinImport()
  Return

MenuHillsGenerateGPX:
  HillsGenerateGPXFile()
  Return

MenuAbout:
  Return

ChurchList:
	Gui, Submit, NoHide
	argChurch := ChurchList
; This bit of code returns the index number rather than the value
;	GuiControl, +AltSubmit, ChurchList
;	Gui, Submit, NoHide
;	argChurchPos :=	ChurchList
;	GuiControl, -AltSubmit, ChurchList
	LoadChurch()
	DrawGUI()
  Return

DefaultChurch() {
	global
  NData["Details"] := ""
  NData["Notes"]   := ""
  NData["Status"]  := ""
  NData["Date"]    := ""
  NData["Need to Revisit"] := 0
  NData["Shropshire"] := ""
}

LoadChurches() {
; Note that the list of places needs a pipe as the first character so
; that it replaces the existing list otherwise it will append
  global
  gChurches    := ""
  gNumChurches := 0
  RecordSet    := ""
  SQL := "SELECT Place, Dedication FROM Churches WHERE " . gFilter . " ORDER BY Place;"
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0) {
    	gNumChurches := gNumChurches + 1
      gChurches := gChurches . "|" . row[1] . " - " . row[2]
    }
  } Until RC < 1
  RecordSet.Free()
}

LoadShropshirePlacesList() {
  global
; Note that the list of places needs a pipe as the first character so
; that it replaces the existing list otherwise it will append
  gShropshirePlaces    := ""
  gShropshireNumPlaces := 0
;  IniRead, ShropshireDB, %A_ScriptDir%\Shropshire Photography.ini, Database, DBFile
;  DBS := new SQLiteDB
;  DBS.OpenDB(ShropshireDB)
  RecordSet := ""
  SQL := "SELECT Name FROM Place WHERE Name LIKE '% Church%' OR Name LIKE '% Chapel%' OR Name LIKE '% Abbey%' OR Name LIKE '% Priory%' ORDER BY Name;"
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0) {
    	gShropshireNumPlaces := gShropshireNumPlaces + 1
    	if (gShropshireNumPlaces > 1) {
    		gShropshirePlaces := gShropshirePlaces . "|"
    	}
      gShropshirePlaces := gShropshirePlaces . Row[1]
    }
  } Until RC < 1
  RecordSet.Free()
;  DBS.CloseDB()
 	GuiControl, , ShropshireList, ||%gShropshirePlaces%
  gShropshireLoaded := true
}

LoadChurch() {
  global
  tWhere := StrSplit(argChurch, " - ")
  tW1 := tWhere[1]
  tW2 := tWhere[2]
  RecordSet := ""
  SQL := "SELECT Place, Dedication, Date, Details, Notes, Status, NeedToRevisit, Area, AirtableID, lat, long, Link FROM Churches c, GoogleMap g WHERE c.GoogleName = g.name AND c.Place=""" . tW1 . """ AND c.Dedication = """ . tW2 . """;"
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0) {
      NData["Place"]           := Row[1]
      NData["Dedication"]      := Row[2]
      NData["Date"]            := Row[3]
      NData["Details"]         := Row[4]
      NData["Notes"]           := Row[5]
      NData["Status"]          := Row[6]
      NData["Need to Revisit"] := Row[7]
      NData["Area"]            := Row[8]
      NData["lat"]             := Row[10]
      NData["long"]            := Row[11]
      NData["Shropshire"]      := Row[12]
      gAirtable := Row[9]
    }
  } Until RC < 1
  RecordSet.Free()
}

SaveChurch() {
	global
  jD := ""
  jD .= "- Status: " . NData["Status"] . "`n"
  jD .= "- Date: " . NData["Date"] . "`n"
  v := NData["Need to Revisit"]
  if v = 0
    jD .= "- Need to Revisit: No`n"
  else
    jD .= "- Need to Revisit: Yes`n"
  jD .= "- Area: " . NData["Area"] . "`n"
  jD .= "* * *`n"
  jD .= "## Details`n`n"
  jD .= NData["Details"] . "`n"
  jD .= "* * *`n"
  jD .= "## Notes`n`n"
  jD .= NData["Notes"] . "`n"
  JoplinAPI.SaveChurch(NData["Place"], NData["Dedication"], jD)
;  uData := {}
;  uData["Details"] := NData["Details"]
;  uData["Notes"]   := NData["Notes"]
;  uData["Status"]  := NData["Status"]
;  uData["Date"]    := NData["Date"]
;  uData["Area"]    := NData["Area"]
;  if NData["Need to Revisit"] = 0
;    uData["Need to Revisit"] := "No"
;  if NData["Need to Revisit"] = 1
;    uData["Need to Revisit"] := "Yes"
;  jData := AirtableAPI.CreateJSONData(uData, gAirtable)
;  AirtableAPI.Update("Churches", jData)
	UpdateChurch()
}

UpdateChurch() {
	global
  a := NData["Place"]
  b := NData["Dedication"]
  d := NData["Details"]
  n := NData["Notes"]
  s := NData["Status"]
  t := NData["Date"]
  r := NData["Need to Revisit"]
  l := NData["Shropshire"]
	td := StrReplace(d, """", """""")
	tn := StrReplace(n, """", """""")
	SQL := "UPDATE Churches SET Details = """ . td . """, Notes = """ . tn . """, Status = """ . s . """, Date = """ . t . """, NeedToRevisit =  " . r . ", Link = """ . l . """ WHERE Place = """ . a . """ AND Dedication = """ . b . """;"
;	DB.Exec(SQL)
;	SQL := "UPDATE Churches SET Notes = """ . tn . """ WHERE Place = """ . a . """ AND Dedication = '" . b . "';"
;	DB.Exec(SQL)
;	SQL := "UPDATE Churches SET Status = """ . s . """ WHERE Place = """ . a . """ AND Dedication = '" . b . "';"
;	DB.Exec(SQL)
;	SQL := "UPDATE Churches SET Date = """ . t . """ WHERE Place = """ . a . """ AND Dedication = '" . b . "';"
;	DB.Exec(SQL)
;	SQL := "UPDATE Churches SET NeedToRevisit =  " . r . " WHERE Place = """ . a . """ AND Dedication = '" . b . "';"
;	DB.Exec(SQL)
;	SQL := "UPDATE Churches SET Link = """ . l . """ WHERE Place = """ . a . """ AND Dedication = '" . b . "';"
	DB.Exec(SQL)
}

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

LoadPlaces() {
; Note that the list of places needs a pipe as the first character so
; that it replaces the existing list otherwise it will append
  global
  gPlaces := ""
  gNumPlaces := 0
  RecordSet := ""
  SQL := "SELECT Name FROM Places ORDER BY Name;"
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
  SQL := "SELECT Details, HREF, IsonMap, IsonTPE, Visited FROM Places WHERE name=""" . argPlace . """;"
  NData := {}
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0) {
      NData["Details"] := Row[1]
      NData["HREF"]    := Row[2]
      NData["IsonMap"] := Row[3]
      NData["IsonTPE"] := Row[4]
      NData["Visited"] := Row[5]
    }
  } Until RC < 1
  RecordSet.Free()
}

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

LoadHills() {
; Note that the list of hills needs a pipe as the first character so
; that it replaces the existing list otherwise it will append
  global
  gHills := ""
  gNumHills := 0
  RecordSet := ""
  SQL := "SELECT Name FROM Hills ORDER BY Name;"
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
  SQL := "SELECT Details, Height, IsonMap, IsonTPE FROM Hills WHERE name=""" . argHill . """;"
  NData := {}
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0) {
      NData["Details"] := Row[1]
      NData["Height"]  := Row[2]
      NData["IsonMap"] := Row[3]
      NData["IsonTPE"] := Row[4]
    }
  } Until RC < 1
  RecordSet.Free()
}

ChurchesImportKML() {
  global
  IniRead, gmkFileN, %A_ScriptDir%\Shropshire Photography.ini, Files, KMLFileNorth
  IniRead, gmkFileS, %A_ScriptDir%\Shropshire Photography.ini, Files, KMLFileSouth
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
      SB_SetText("North: " . n, 2)
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
      SB_SetText("South: " . n, 2)
    	p := KMLAPI.GetNextPlacemarkCoords()
    	c := StrSplit(p, [","])
    	SQL := "INSERT INTO GoogleMap (name, lat, long) VALUES (""" . n . """,""" . c[1] . """,""" . c[2] . """);"
      DB.Exec(SQL)
    }
  }
  KMLAPI.CloseKMLFile()
  SB_SetText("", 2)
}

ChurchesCompareJoplin() {
  global
  RecordSetC := ""
  SQL := "SELECT Place, Dedication, Date, Details, Notes, Status, NeedToRevisit, Area FROM Churches ORDER BY Place;"
  DB.Query(SQL, RecordSetC)
  Loop {
    RCC := RecordSetC.Next(RowC)
    if (RCC > 0)
    {
      tZ := RowC[1] . " - " . RowC[2]
      tX := RowC[1]
      tY := RowC[2]
      SB_SetText(tZ, 2)
      tT := RowC[3]
      tD := RowC[4]
      tN := RowC[5]
      tS := RowC[6]
      tR := RowC[7]
      tA := RowC[8]
      if tR = 0
        tR := "No"
      if tR = 1
        tR := "Yes"
      rJ := JoplinAPI.SelectChurch(tX, tY)
      aZ := tZ
      aT := rJ["Date"]
      aD := rJ["Details"]
      aN := rJ["Notes"]
      aS := rJ["Status"]
      aR := rJ["Revisit"]
      diff := false
      if (tT <> aT)
        diff := true
      if (tD <> aD)
        diff := true
      if (tN <> aN)
        diff := true
      if (tS <> aS)
        diff := true
      if (tR <> aR)
        diff := true
      if (diff)
      {
			  Gui, SyncJoplin:Add, Text, x5 y5 w300 h20, Database
			  Gui, SyncJoplin:Add, Text, x310 y5 w300 h20, Joplin
			  Gui, SyncJoplin:Add, Edit, x5 y25 w300 h20, %tZ%
			  Gui, SyncJoplin:Add, Edit, x310 y25 w300 h20, %aZ%
			  Gui, SyncJoplin:Add, Edit, x5 y45 w300 h20, %tS%
			  Gui, SyncJoplin:Add, Edit, x310 y45 w300 h20, %aS%
			  Gui, SyncJoplin:Add, Edit, x5 y65 w300 h20, %tT%
			  Gui, SyncJoplin:Add, Edit, x310 y65 w300 h20, %aT%
			  Gui, SyncJoplin:Add, Edit, x5 y85 w300 h100, %tD%
			  Gui, SyncJoplin:Add, Edit, x310 y85 w300 h100, %aD%
			  Gui, SyncJoplin:Add, Edit, x5 y185 w300 h100, %tN%
			  Gui, SyncJoplin:Add, Edit, x310 y185 w300 h100, %aN%
			  Gui, SyncJoplin:Add, Edit, x5 y285 w300 h20, %tR%
			  Gui, SyncJoplin:Add, Edit, x310 y285 w300 h20, %aR%
				Gui, SyncJoplin:Add, Button, xm section x5 w300 h20, Database to Joplin >>
			  Gui, SyncJoplin:Add, Button, ys x310 w300 h20, << Joplin to Database
			  Gui, SyncJoplin:Add, Button, xm section x5 w60 h20, Cancel
			  Gui, SyncJoplin:Show, w620 h365, Sync Database and Joplin
			  Gui, SyncJoplin:Default
			  WinWaitClose, Sync Database and Joplin
				Gui, 1:Default
      }
    }
  } Until RCC < 1
  RecordSetC.Free()
  SB_SetText("", 2)
}

SyncJoplinButtonDatabasetoJoplin>>:
  jD := ""
  jD .= "- Status: " . tS . "`n"
  jD .= "- Date: " . tT . "`n"
  jD .= "- Need to Revisit: " . tR . "`n"
  jD .= "- Area: " . tA . "`n"
  jD .= "* * *`n"
  jD .= "## Details`n`n"
  jD .= tD . "`n"
  jD .= "* * *`n"
  jD .= "## Notes`n`n"
  jD .= tN . "`n"
  JoplinAPI.SaveChurch(tX, tY, jD)
	Gui, SyncJoplin:Destroy
  Return

SyncJoplinButton<<JoplintoDatabase:
  if aR = No
    aV := 0
  else
    aV := 1
  SQL := "UPDATE Churches SET Details = """ . aD . """, Notes = """ . aN . """, Status = """ . aS . """, Date = """ . aT . """, NeedToRevisit = " . aV . " WHERE Place = """ . tX . """ AND Dedication = '" . tY . "';"
  DB.Exec(SQL)
	Gui, SyncJoplin:Destroy
  Return

SyncJoplinButtonCancel:
	Gui, SyncJoplin:Destroy
  Return

;ChurchesCompareAirtable() {
;  global
;  RecordSetC := ""
;  SQL := "SELECT Place, Dedication, Date, Details, Notes, Status, NeedToRevisit, Area, AirtableID, lat, ;long FROM Churches c, GoogleMap g WHERE c.GoogleName = g.name;"
;  DB.Query(SQL, RecordSetC)
;  Loop {
;    RCC := RecordSetC.Next(RowC)
;    if (RCC > 0)
;    {
;      tZ := RowC[1] . " - " . RowC[2]
;      tX := RowC[1]
;      tY := RowC[2]
;      SB_SetText(tZ, 2)
;      tA := RowC[9]
;      tT := RowC[3]
;      tD := RowC[4]
;      tN := RowC[5]
;      tS := RowC[6]
;      tR := RowC[7]
;      if tR = 0
;        tR := "false"
;      if tR = 1
;        tR := "true"
;      aZ := ""
;      aT := ""
;      aD := ""
;      aN := ""
;      aS := ""
;      aR := "false"
;      Sleep, 250
;      rJSON := AirtableAPI.Select("Churches", tA)
;      JSONAPI.SetJSON(rJSON)
;      i := JSONAPI.GetNextItem() ; {
;      i := JSONAPI.GetNextItem() ; id
;      i := JSONAPI.GetNextItem() ; :
;      i := JSONAPI.GetNextItem() ; <id>
;      i := JSONAPI.GetNextItem() ; ,
;      i := JSONAPI.GetNextItem() ; fields
;      i := JSONAPI.GetNextItem() ; :
;      i := JSONAPI.GetNextItem() ; {
;      while (i <> "#EndObject")
;      {
;        k := JSONAPI.GetNextItem()
;        i := JSONAPI.GetNextItem()
;        v := JSONAPI.GetNextItem()
;        i := JSONAPI.GetNextItem()
;        if k = Date
;        {
;          aT := v
;        }
;        if k = Details
;        {
;          aD := v
;        }
;        if k = Notes
;        {
;          aN := v
;        }
;        if k = Status
;        {
;          aS := v
;        }
;        if k = Need to Revisit
;        {
;          aR := v
;        }
;        if k = Place
;        {
;          aZ := v
;        }
;        if k = Dedication
;        {
;          aZ .= " - " . v
;        }
;      }
;      diff := false
;      if (tT <> aT)
;        diff := true
;      if (tD <> aD)
;        diff := true
;      if (tN <> aN)
;        diff := true
;      if (tS <> aS)
;        diff := true
;      if (tR <> aR)
;        diff := true
;      if (diff)
;      {
;			  Gui, SyncAirtable:Add, Text, x5 y5 w300 h20, Database
;			  Gui, SyncAirtable:Add, Text, x310 y5 w300 h20, Airtable
;			  Gui, SyncAirtable:Add, Edit, x5 y25 w300 h20, %tZ%
;			  Gui, SyncAirtable:Add, Edit, x310 y25 w300 h20, %aZ%
;			  Gui, SyncAirtable:Add, Edit, x5 y45 w300 h20, %tS%
;			  Gui, SyncAirtable:Add, Edit, x310 y45 w300 h20, %aS%
;			  Gui, SyncAirtable:Add, Edit, x5 y65 w300 h20, %tT%
;			  Gui, SyncAirtable:Add, Edit, x310 y65 w300 h20, %aT%
;			  Gui, SyncAirtable:Add, Edit, x5 y85 w300 h100, %tD%
;			  Gui, SyncAirtable:Add, Edit, x310 y85 w300 h100, %aD%
;			  Gui, SyncAirtable:Add, Edit, x5 y185 w300 h100, %tN%
;			  Gui, SyncAirtable:Add, Edit, x310 y185 w300 h100, %aN%
;			  Gui, SyncAirtable:Add, Edit, x5 y285 w300 h20, %tR%
;			  Gui, SyncAirtable:Add, Edit, x310 y285 w300 h20, %aR%
;				Gui, SyncAirtable:Add, Button, xm section x5 w300 h20, Database to Airtable >>
;			  Gui, SyncAirtable:Add, Button, ys x310 w300 h20, << Airtable to Database
;			  Gui, SyncAirtable:Add, Button, xm section x5 w60 h20, Cancel
;			  Gui, SyncAirtable:Show, w620 h365, Sync Database and Airtable
;			  Gui, SyncAirtable:Default
;			  WinWaitClose, Sync Database and Airtable
;				Gui, 1:Default
;      }
;    }
;  } Until RCC < 1
;  RecordSetC.Free()
;  SB_SetText("", 2)
;}

;SyncAirtableButtonDatabasetoAirtable>>:
;  uData := {}
;  uData["Details"] := tD
;  uData["Notes"]   := tN
;  uData["Status"]  := tS
;  uData["Date"]    := tT
;  jData := AirtableAPI.CreateJSONData(uData, tA)
;  AirtableAPI.Update("Churches", jData)
;	Gui, SyncAirtable:Destroy
;  Return

;SyncAirtableButton<<AirtabletoDatabase:
;	SQL := "UPDATE Churches SET Details = """ . aD . """, Notes = """ . aN . """, Status = """ . aS . """, ;Date = """ . aT . """ WHERE Place = """ . tX . """ AND Dedication = '" . tY . "';"
;  DB.Exec(SQL)
;	Gui, SyncAirtable:Destroy
;  Return

;SyncAirtableButtonCancel:
;	Gui, SyncAirtable:Destroy
;  Return

ChurchesGenerateGPXFile() {
	global
	n := GetNextFileID()
  IniRead, mapFile, %A_ScriptDir%\Shropshire Photography.ini, Files, ChurchesMapFile
	mapFileName := StrReplace(mapFile, "XXXX", n)
	mapFileHndl := FileOpen(mapFileName, "w")
	mapFileHndl.WriteLine("<?xml version=""1.0""?>")
  mapFileHndl.WriteLine("<gpx xmlns=""http://www.topografix.com/GPX/1/1"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" xsi:schemaLocation=""http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd"" >")
  mapFileHndl.WriteLine("<metadata>")
  mapFileHndl.WriteLine("<name>Shropshire - Churches v" . n . "</name>")
  mapFileHndl.WriteLine("</metadata>")
  SQL := "SELECT Place, Dedication, Date, Details, Notes, Status, NeedToRevisit, Area, AirtableID, lat, long FROM Churches c, GoogleMap g WHERE c.GoogleName = g.name;"
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0)
    {
    	SB_SetText(row[1], 2)	
      mapFileHndl.WriteLine("<wpt lat=""" . row[10] . """ lon=""" . row[11] . """>")
      mapFileHndl.WriteLine("<name>" . row[1] . " - " . row[2] . "</name>")
      tS := row[6]
      tD := ""
      if StrLen(row[5]) > 0
      {
        tD := row[5]
      }
      if tS = Visited
      {
        if StrLen(tD) > 0
        {
          tD .= "`n======`n"
        }
        tD .= "Date: " . row[3] . "`n"
        tD .= row[4]
      }
      if tD <>
      {
        tD := StrReplace(tD, "`r", "")
        mapFileHndl.WriteLine("<desc>" . tD . "</desc>")
      }
      if tS = Not Yet Visited
      {
        tS := "blue plus"
      }
      if tS = Planned to Visit
      {
        tS := "yellow plus"
      }
      if tS = Planned to Visit - Priority
      {
        tS := "yellow plus ticked"
      }
      if tS = Visited
      {
        tS := "green plus"
      }
      mapFileHndl.WriteLine("<sym>" . tS . "</sym>")
      mapFileHndl.WriteLine("</wpt>")
    }
  }	Until RC < 1
  RecordSet.Free()
 	SB_SetText("", 2)	
  mapFileHndl.WriteLine("</gpx>")
	mapFileHndl.Close()
}

PlacesJoplinImport() {
  global
  SQL := "DELETE FROM Places;"
  DB.Exec(SQL)
  tList := JoplinAPI.ListPlaces()
  for index, element in tList
  {
    tn := element
    tData := JoplinAPI.SelectPlace(tn)
    td := tData["Details"]
    th := tData["HREF"]
    tx := tData["lat"]
    ty := tData["long"]
    tm := 0
    tz := tData["IsonMap"]
    if tz = Yes
      tm := 1
    tt := 0
    tz := tData["IsonTPE"]
    if tz = Yes
      tt := 1
    tv := 0
    tz := tData["Visited"]
    if tz = Yes
      tv := 1
   	SQL := "INSERT INTO Places (Name, Details, HREF, lat, long, IsonMap, IsonTPE, Visited) VALUES (""" . tn . """, """ . td . """, """ . th . """, """ . tx . """, """ . ty . """, " . tm . ", " . tt . ", " . tv . ");"
   	DB.Exec(SQL)
  }
  FormatTime, tDT, , yyyy-MMM-dd HH:mm:ss
  SQL := "UPDATE Config SET LastReload='" . tDT . "' WHERE ID='Places';"
  DB.Exec(SQL)
  GetLastReload()
  MsgBox, Joplin data reloaded
  Reload
}

;PlacesAirtableImport() {
;  global
;  SQL := "DELETE FROM Places;"
;  DB.Exec(SQL)
;  off := ""
;  while (off <> "DONE") {
;    PlacesReloadSubset(off)
;    a := JSONAPI.GetNextItem()
;    if (a = "#EndObject")
;      off := "DONE"
;    else {
;      a := JSONAPI.GetNextItem() ; offset
;      a := JSONAPI.GetNextItem() ; :
;      off := JSONAPI.GetNextItem()
;    }
;  }
;  FormatTime, tDT, , yyyy-MMM-dd HH:mm:ss
;  SQL := "UPDATE Config SET LastReload='" . tDT . "' WHERE ID='Places';"
;  DB.Exec(SQL)
;  GetLastReload()
;  MsgBox, Airtable data reloaded
;  Reload
;}

;PlacesReloadSubset(pOffset) {
;  global
;  theJSON := AirtableAPI.List("Places", pOffset)
;  ti := ""
;  tn := ""
;  td := ""
;  th := ""
;  tx := ""
;  ty := ""
;  tm := 0
;  tt := 0
;  tv := 0
;  JSONAPI.SetJSON(theJSON)
;  a := JSONAPI.GetNextItem() ; {
;  a := JSONAPI.GetNextItem() ; records
;  a := JSONAPI.GetNextItem() ; :
;  a := JSONAPI.GetNextItem() ; [
;  while (a <> "#EndArray")
;  {
;    if a = id
;    {
;      a := JSONAPI.GetNextItem()
;      ti := JSONAPI.GetNextItem()
;    }
;    if a = Name
;    {
;      a := JSONAPI.GetNextItem()
;      tn := JSONAPI.GetNextItem()
;    }
;    if a = Details
;    {
;      a := JSONAPI.GetNextItem()
;      td := JSONAPI.GetNextItem()
;    }
;    if a = HREF
;    {
;      a := JSONAPI.GetNextItem()
;      th := JSONAPI.GetNextItem()
;    }
;    if a = lat
;    {
;      a := JSONAPI.GetNextItem()
;      tx := JSONAPI.GetNextItem()
;    }
;    if a = long
;    {
;      a := JSONAPI.GetNextItem()
;      ty := JSONAPI.GetNextItem()
;    }
;    if a = Is on Map
;    {
;      a := JSONAPI.GetNextItem()
;      a := JSONAPI.GetNextItem()
;      if a = true
;        tm := 1
;    }
;    if a = Is on TPE
;    {
;      a := JSONAPI.GetNextItem()
;      a := JSONAPI.GetNextItem()
;      if a = true
;        tt := 1
;    }
;    if a = Visited
;    {
;      a := JSONAPI.GetNextItem()
;      a := JSONAPI.GetNextItem()
;      if a = true
;        tv := 1
;    }
;    a := JSONAPI.GetNextItem()
;    if a = CreatedTime
;    {
;   		SQL := "INSERT INTO Places (Name, Details, HREF, lat, long, IsonMap, IsonTPE, Visited, AirtableID) VALUES (""" . tn . """, ;""" . td . """, """ . th . """, """ . tx . """, """ . ty . """, " . tm . ", " . tt . ", " . tv . ", """ . ti . """);"
;   		DB.Exec(SQL)
;      ti := ""
;      tn := ""
;      td := ""
;      th := ""
;      tx := ""
;      ty := ""
;      tm := 0
;      tt := 0
;      tv := 0
;    }
;  }
;}

PlacesGenerateGPXFile() {
	global
	n := GetNextFileID()
  IniRead, mapFile, %A_ScriptDir%\Shropshire Photography.ini, Files, PlacesMapFile
	mapFileName := StrReplace(mapFile, "XXXX", n)
	mapFileHndl := FileOpen(mapFileName, "w")
	mapFileHndl.WriteLine("<?xml version=""1.0""?>")
  mapFileHndl.WriteLine("<gpx xmlns=""http://www.topografix.com/GPX/1/1"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" xsi:schemaLocation=""http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd"" >")
  mapFileHndl.WriteLine("<metadata>")
  mapFileHndl.WriteLine("<name>Shropshire - Places v" . n . "</name>")
  mapFileHndl.WriteLine("</metadata>")
	SQL := "SELECT Name, Details, lat, long FROM Places ORDER BY Name;"
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0)
    {
    	SB_SetText(row[1], 2)	
      mapFileHndl.WriteLine("<wpt lat=""" . row[3] . """ lon=""" . row[4] . """>")
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
  mapFileHndl.WriteLine("</gpx>")
	mapFileHndl.Close()
  GetLastReload()
}

HillsJoplinImport() {
  global
  SQL := "DELETE FROM Hills;"
  DB.Exec(SQL)
  tList := JoplinAPI.ListHills()
  for index, element in tList
  {
    tn := element
    tData := JoplinAPI.SelectHill(tn)
    th := tData["Height"]
    td := tData["Details"]
    tx := tData["lat"]
    ty := tData["long"]
    tm := 0
    tv := tData["IsonMap"]
    if tv = Yes
      tm := 1
    tt := 0
    tv := tData["IsonTPE"]
    if tv = Yes
      tt := 1
   	SQL := "INSERT INTO Hills (Name, Height, Details, lat, long, IsonMap, IsonTPE) VALUES (""" . tn . """, """ . th . """, """ . td . """, """ . tx . """, """ . ty . """, " . tm . ", " . tt . ");"
   	DB.Exec(SQL)
  }
  FormatTime, tDT, , yyyy-MMM-dd HH:mm:ss
  SQL := "UPDATE Config SET LastReload='" . tDT . "' WHERE ID='Hills';"
  DB.Exec(SQL)
  GetLastReload()
  MsgBox, Joplin data reloaded
  Reload
}

;HillsAirtableImport() {
;  global
;  SQL := "DELETE FROM Hills;"
;  DB.Exec(SQL)
;  off := ""
;  while (off <> "DONE") {
;    HillsReloadSubset(off)
;    a := JSONAPI.GetNextItem()
;    if (a = "#EndObject")
;      off := "DONE"
;    else {
;      a := JSONAPI.GetNextItem() ; offset
;      a := JSONAPI.GetNextItem() ; :
;      off := JSONAPI.GetNextItem()
;    }
;  }
;  FormatTime, tDT, , yyyy-MMM-dd HH:mm:ss
;  SQL := "UPDATE Config SET LastReload='" . tDT . "' WHERE ID='Hills';"
;  DB.Exec(SQL)
;  GetLastReload()
;  MsgBox, Airtable data reloaded
;  Reload
;}

;HillsReloadSubset(pOffset) {
;  global
;  theJSON := AirtableAPI.List("Hills", pOffset)
;  ti := ""
;  tn := ""
;  th := ""
;  td := ""
;  tx := ""
;  ty := ""
;  tm := 0
;  tt := 0
;  JSONAPI.SetJSON(theJSON)
;  a := JSONAPI.GetNextItem() ; {
;  a := JSONAPI.GetNextItem() ; records
;  a := JSONAPI.GetNextItem() ; :
;  a := JSONAPI.GetNextItem() ; [
;  while (a <> "#EndArray")
;  {
;    if a = id
;    {
;      a := JSONAPI.GetNextItem()
;      ti := JSONAPI.GetNextItem()
;    }
;    if a = Name
;    {
;      a := JSONAPI.GetNextItem()
;      tn := JSONAPI.GetNextItem()
;    }
;    if a = Height
;    {
;      a := JSONAPI.GetNextItem()
;      th := JSONAPI.GetNextItem()
;    }
;    if a = Details
;    {
;      a := JSONAPI.GetNextItem()
;      td := JSONAPI.GetNextItem()
;    }
;    if a = lat
;    {
;      a := JSONAPI.GetNextItem()
;      tx := JSONAPI.GetNextItem()
;    }
;    if a = long
;    {
;      a := JSONAPI.GetNextItem()
;      ty := JSONAPI.GetNextItem()
;    }
;    if a = Is on Map
;    {
;      a := JSONAPI.GetNextItem()
;      a := JSONAPI.GetNextItem()
;      if a = true
;        tm := 1
;    }
;    if a = Is on TPE
;    {
;      a := JSONAPI.GetNextItem()
;      a := JSONAPI.GetNextItem()
;      if a = true
;        tt := 1
;    }
;    a := JSONAPI.GetNextItem()
;    if a = CreatedTime
;    {
;   		SQL := "INSERT INTO Hills (Name, Height, Details, AirtableID, lat, long, IsonMap, IsonTPE) VALUES ;(""" . tn . """, """ . th . """, """ . td . """, """ . ti . """, """ . tx . """, """ . ty . """, " ;. tm . ", " . tt . ");"
;   		DB.Exec(SQL)
;      ti := ""
;      tn := ""
;      th := ""
;      td := ""
;      tx := ""
;      ty := ""
;      tm := 0
;      tt := 0
;    }
;  }
;}

HillsGenerateGPXFile() {
	global
	n := GetNextFileID()
  IniRead, mapFile, %A_ScriptDir%\Shropshire Photography.ini, Files, HillsMapFile
	mapFileName := StrReplace(mapFile, "XXXX", n)
	mapFileHndl := FileOpen(mapFileName, "w")
	mapFileHndl.WriteLine("<?xml version=""1.0""?>")
  mapFileHndl.WriteLine("<gpx xmlns=""http://www.topografix.com/GPX/1/1"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" xsi:schemaLocation=""http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd"" >")
  mapFileHndl.WriteLine("<metadata>")
  mapFileHndl.WriteLine("<name>Shropshire - Hills v" . n . "</name>")
  mapFileHndl.WriteLine("</metadata>")
	SQL := "SELECT Name, Height, Details, lat, long FROM Hills ORDER BY Name;"
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0)
    {
    	SB_SetText(row[1], 2)
      mapFileHndl.WriteLine("<wpt lat=""" . row[4] . """ lon=""" . row[5] . """>")
      mapFileHndl.WriteLine("<name>" . row[1] . "</name>")
      mapFileHndl.WriteLine("<desc>Height = " . row[2] . "`n`n" . row[3] . "</desc>")
      mapFileHndl.WriteLine("<sym>yellow</sym>")
      mapFileHndl.WriteLine("</wpt>")
    }
  }	Until RC < 1
  RecordSet.Free()
  mapFileHndl.WriteLine("</gpx>")
	mapFileHndl.Close()
  GetLastReload()
}

DrawGUI() {
  global
  if currTab = Churches
  {
  	GuiControl, Text, ChurchDetails, % NData["Details"]
	  GuiControl, Text, ChurchNotes, % NData["Notes"]
	  GuiControl, Text, ChurchDates, % NData["Date"]
	  GuiControl, Text, ChurchArea, % NData["Area"]
	  GuiControl, ChooseString, ChurchStatus, % NData["Status"]
	  GuiControl, , CBChurchReVisit, % NData["Need to Revisit"]
    GuiControl, Choose, ShropshireList, 1
    if gShropshireLoaded
	    GuiControl, ChooseString, ShropshireList, % NData["Shropshire"]
  }
  if currTab = Places
  {
    GuiControl, Text, PlaceDetails, % NData["Details"]
    GuiControl, Text, PlaceHREF, % NData["HREF"]
    GuiControl, , CBPlaceIsonMap, % NData["IsonMap"]
    GuiControl, , CBPlaceIsonTPE, % NData["IsonTPE"]
    GuiControl, , CBPlaceVisited, % NData["Visited"]
  }
  if currTab = Hills
  {
    GuiControl, Text, HillDetails, % NData["Details"]
    GuiControl, Text, HillHeight, % NData["Height"]
    GuiControl, , CBHillIsonMap, % NData["IsonMap"]
    GuiControl, , CBHillIsonTPE, % NData["IsonTPE"]
  }
}

GUIValues() {
  global
	NData["Details"] := ChurchDetails
	NData["Notes"]   := ChurchNotes
	NData["Status"]  := ChurchStatus
	NData["Date"]    := ChurchDates
  NData["Need to Revisit"] := CBChurchReVisit
  if gShropshireLoaded
    NData["Shropshire"] := ShropshireList
}

GetLastReload() {
  global
  if currTab <> Churches
  {
    tDT := ""
    SQL := "SELECT LastReload FROM Config WHERE ID = '" . currTab . "';"
    DB.Query(SQL, RecordSet)
    Loop {
      RC := RecordSet.Next(Row)
      if (RC > 0)
      {
    	  tDT := Row[1]
      }
    }	Until RC < 1
    RecordSet.Free()
    SB_SetText("Last Airtable Reload: " . tDT, 2)	
  }
  else
  {
    SB_SetText("", 2)	
  }
}

GetNextFileID() {
	global
	nextID := "0000"
	nxtVer := 0
	SQL := "SELECT NextVersion FROM Config WHERE ID = '" . currTab . "';"
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
  SQL := "UPDATE Config SET NextVersion = " . nxtVer . " WHERE ID = '" . currTab . "';"
  DB.Exec(SQL)
  Return SubStr(nextID, -3)
}

ChurchesBulkLoadJoplin() {
  global
  RecordSet := ""
  SQL := "SELECT Place, Dedication, Date, Details, Notes, Status, NeedToRevisit, Area FROM Churches;"
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0) {
      fn := tmpPath . "\Churches\" . Row[1] . " - " . Row[2] . ".md"
      FileDelete, %fn%
      v := Row[6]
      FileAppend, - Status: %v%`n, %fn%
      v := Row[3]
      FileAppend, - Date: %v%`n, %fn%
      v := Row[7]
      if v = 0
        v := "No"
      else
        v := "Yes"
      FileAppend, - Need to Revisit: %v%`n, %fn%
      v := Row[8]
      FileAppend, - Area: %v%`n, %fn%
      FileAppend, * * *`n, %fn%
      FileAppend, ## Details`n, %fn%
      FileAppend, `n, %fn%
      v := Row[4]
      FileAppend, %v%`n, %fn%
      FileAppend, * * *`n, %fn%
      FileAppend, ## Notes`n, %fn%
      FileAppend, `n, %fn%
      v := Row[5]
      FileAppend, %v%`n, %fn%
    }
  } Until RC < 1
  RecordSet.Free()
}

HillsBulkLoadJoplin() {
  global
  RecordSet := ""
  SQL := "SELECT Name, Height, Details, lat, long, IsonMap, IsonTPE FROM Hills;"
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0) {
      fn := tmpPath . "\Hills\" . Row[1] . ".md"
      FileDelete, %fn%
      v := Row[2]
      FileAppend, - Height: %v%`n, %fn%
      v := Row[4]
      FileAppend, - Latitude: %v%`n, %fn%
      v := Row[5]
      FileAppend, - Longitude: %v%`n, %fn%
      v := Row[6]
      if v = 0
        FileAppend, - Is on Map: No`n, %fn%
      else
        FileAppend, - Is on Map: Yes`n, %fn%
      v := Row[7]
      if v = 0
        FileAppend, - Is on TPE: No`n, %fn%
      else
        FileAppend, - Is on TPE: Yes`n, %fn%
      FileAppend, * * *`n, %fn%
      FileAppend, ## Details`n, %fn%
      FileAppend, `n, %fn%
      v := Row[3]
      FileAppend, %v%`n, %fn%
    }
  } Until RC < 1
  RecordSet.Free()
}

PlacesBulkLoadJoplin() {
  global
  RecordSet := ""
  SQL := "SELECT Name, Visited, HREF, Details, lat, long, IsonMap, IsonTPE FROM Places;"
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0) {
      fn := tmpPath . "\Places\" . Row[1] . ".md"
      FileDelete, %fn%
      v := Row[2]
      if v = 0
        FileAppend, - Visited: No`n, %fn%
      else
        FileAppend, - Visited: Yes`n, %fn%
      v := Row[5]
      FileAppend, - Latitude: %v%`n, %fn%
      v := Row[6]
      FileAppend, - Longitude: %v%`n, %fn%
      v := Row[7]
      if v = 0
        FileAppend, - Is on Map: No`n, %fn%
      else
        FileAppend, - Is on Map: Yes`n, %fn%
      v := Row[8]
      if v = 0
        FileAppend, - Is on TPE: No`n, %fn%
      else
        FileAppend, - Is on TPE: Yes`n, %fn%
      v := Row[3]
      FileAppend, - HREF: %v%`n, %fn%
      FileAppend, * * *`n, %fn%
      FileAppend, ## Details`n, %fn%
      FileAppend, `n, %fn%
      v := Row[4]
      FileAppend, %v%`n, %fn%
    }
  } Until RC < 1
  RecordSet.Free()
}

;ChurchesBulkLoadAirtable() {
;  global
;  RecordSet := ""
;  SQL := "SELECT Place, Dedication, Date, Details, Notes, Status, NeedToRevisit, Area, AirtableID, lat, long FROM Churches c, GoogleMap g WHERE c.GoogleName = g.name;"
;  DB.Query(SQL, RecordSet)
;  Loop {
;    tData := {}
;    RC := RecordSet.Next(Row)
;    if (RC > 0) {
;      tData["Place"]           := Row[1]
;      a := Row[1]
;      tData["Dedication"]      := Row[2]
;      b := Row[2]
;      tData["Date"]            := Row[3]
;      tData["Details"]         := Row[4]
;      tData["Notes"]           := Row[5]
;      tData["Status"]          := Row[6]
;      tData["Need to Revisit"] := Row[7]
;      tData["Area"]            := Row[8]
;      tData["lat"]             := Row[10]
;      tData["long"]            := Row[11]
;      jData := AirtableAPI.CreateJSONData(tData, "")
;      idIdx := AirtableAPI.Insert("Churches", jData)
;	    SQL := "UPDATE Churches SET AirtableID = """ . idIdx . """ WHERE Place = """ . a . """ AND Dedication = """ . b . """;"
;	    DB.Exec(SQL)
;      Sleep, 250
;    }
;  } Until RC < 1
;  RecordSet.Free()
;}

;HillsBulkLoadAirtable() {
;  global
;  RecordSet := ""
;  SQL := "SELECT Name, Height, Details, lat, long FROM Hills;"
;  DB.Query(SQL, RecordSet)
;  Loop {
;    tData := {}
;    RC := RecordSet.Next(Row)
;    if (RC > 0) {
;      tData["Name"]    := Row[1]
;      a := Row[1]
;      tData["Height"]  := Row[2]
;      tData["Details"] := Row[3]
;      tData["lat"]     := Row[4]
;      tData["long"]    := Row[5]
;      jData := AirtableAPI.CreateJSONData(tData, "")
;      idIdx := AirtableAPI.Insert("Hills", jData)
;	    SQL := "UPDATE Hills SET AirtableID = """ . idIdx . """ WHERE Name = """ . a . """;"
;	    DB.Exec(SQL)
;      Sleep, 250
;    }
;  } Until RC < 1
;  RecordSet.Free()
;}

;PlacesBulkLoadAirtable() {
;  global
;  RecordSet := ""
;  SQL := "SELECT Name, Details, HREF, IsonMap, IsonTPE, Visited, lat, long FROM Places;"
;  DB.Query(SQL, RecordSet)
;  Loop {
;    tData := {}
;    RC := RecordSet.Next(Row)
;    if (RC > 0) {
;      tData["Name"]      := Row[1]
;      a := Row[1]
;      tData["Details"]   := Row[2]
;      tData["HREF"]      := Row[3]
;      tData["lat"]       := Row[7]
;      tData["long"]      := Row[8]
;      tData["Is on Map"] := Row[4]
;      tData["Is on TPE"] := Row[5]
;      tData["Visited"]   := Row[6]
;      jData := AirtableAPI.CreateJSONData(tData, "")
;      idIdx := AirtableAPI.Insert("Places", jData)
;	    SQL := "UPDATE Places SET AirtableID = """ . idIdx . """ WHERE Name = """ . a . """;"
;	    DB.Exec(SQL)
;      Sleep, 250
;    }
;  } Until RC < 1
;  RecordSet.Free()
;}
