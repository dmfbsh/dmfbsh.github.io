;=====================================================================
; Script to manage the status of the Shropshire Photography project
;
; Language: AutoHotKey
;
; Author: David Banham
;
; Version: 3.0
;
; Date: 5th May 2020
;
; Version History:
; 1.0 - initial release
; 2.0 - changed to use SQLite
; 3.0 - redesigned the GUI and closer coupled the database and the
;       file system
;
;=====================================================================

; Ensure that only a single instance of the script will be running

#SingleInstance force

; Include the SQLite database class

#Include %A_ScriptDir%\Class_SQLiteDB.ahk

;=====================================================================
; Initialise the key variables
;=====================================================================

gPlaces     := ""
gNumPlaces  := 0
argPlace    := ""
argPlacePos := 0
filterCat1  := "%"
filterCat2  := "%"

IniRead, BasePath, %A_ScriptDir%\Shropshire Photography.ini, Paths, BasePath

gDxOPresets        := ""
gSilverEfexPresets := ""

;=====================================================================
; Open the database and read reference data
;=====================================================================

IniRead, DBFile, %A_ScriptDir%\Shropshire Photography.ini, Database, DBFile
DB := new SQLiteDB
DB.OpenDB(DBFile)

LoadDxOPresets()
LoadSilverEfexPresets()

LoadPlaces()

;=====================================================================
; Build the GUI
;=====================================================================

Menu, FileMenu, Add, Save, MenuSave
Menu, FileMenu, Add
Menu, FileMenu, Add, New, MenuNew
Menu, FileMenu, Add, Rename, MenuRename
Menu, FileMenu, Add, Delete, MenuDelete
Menu, FileMenu, Add
Menu, FileMenu, Add, Exit, MenuExit
Menu, ImageMenu, Add, Select, MenuImageSelect
Menu, ImageMenu, Add, View, MenuImageView
Menu, ImageMenu, Add
Menu, ImageMenu, Add, Move, MenuImageMove
Menu, PlaceMenu, Add, Edit Notes, MenuEditNotes
Menu, PlaceMenu, Add
Menu, PlaceMenu, Add, Goto Published in ACDSee, MenuGotoPublished
Menu, PlaceMenu, Add
Menu, PlaceMenu, Add, Create Template, MenuCreateTemplate
Menu, FilterMenu, Add, Clear Filter, MenuClearFilter
Menu, FilterMenu, Add
Menu, FilterMenu, Add, History, MenuFilterHistory
Menu, FilterMenu, Add, Castle, MenuFilterCastle
Menu, FilterMenu, Add, Church, MenuFilterChurch
Menu, FilterMenu, Add, House, MenuFilterHouse
Menu, FilterMenu, Add, People, MenuFilterPeople
Menu, FilterMenu, Add, Landscape, MenuFilterLandscape
Menu, FilterMenu, Add, Garden, MenuFilterGarden
Menu, FilterMenu, Add, Place, MenuFilterPlace
Menu, FilterMenu, Add, Folklore, MenuFilterFolklore
Menu, FilterMenu, Add, Miscellaneous, MenuFilterMiscellaneous
Menu, FilterMenu, Add, Information, MenuFilterInformation
Menu, ProjectMenu, Add, Compare Folders, MenuCompareFolders
Menu, ProjectMenu, Add, Compare ACDSee, MenuCompareACDSee
Menu, ProjectMenu, Add
Menu, ProjectMenu, Add, Unused Images, MenuUnusedImages
Menu, ProjectMenu, Add
Menu, ProjectMenu, Add, Generate Report, MenuGenerateReport
Menu, ProjectMenu, Add, View Report, MenuViewReport
Menu, HelpMenu, Add, About, MenuAbout
Menu, MyMenuBar, Add, File, :FileMenu
Menu, MyMenuBar, Add, Image, :ImageMenu
Menu, MyMenuBar, Add, Place, :PlaceMenu
Menu, MyMenuBar, Add, Filter, :FilterMenu
Menu, MyMenuBar, Add, Project, :ProjectMenu
Menu, MyMenuBar, Add, Help, :HelpMenu
Gui, Menu, MyMenuBar

Gui +Resize +MinSize450x410

Gui, Add, ListBox, vPlaceList gPlaceList w200 h385, Empty|Null
GuiControl, , PlaceList, %gPlaces%

Gui, Add, Text, x215 y5 section w120 h20, Original Photograph:
Gui, Add, Edit, ys vOrigName w400 h20,

Gui, Add, Text, x215 y30 section w120 h20, Category:
Gui, Add, DropDownList, ys vCategory1 gCategory1 w196 h180, History|Church|Landscape|Miscellaneous|Place|Garden|Information
Gui, Add, DropDownList, ys vCategory2 w196 h180, N/A

Gui, Add, Text, x215 y55 section w120 h20, DxO PhotoLab Preset:
Gui, Add, DropDownList, ys vDxOPLPreset w400 h180, %gDxOPresets%

Gui, Add, Text, x215 y80 section w120 h20, DxO PhotoLab Notes:
Gui, Add, Edit, ys vDxOPLNotes +Wrap w400 h50,

Gui, Add, Text, x215 y135 section w120 h20, Other Edits Notes:
Gui, Add, Edit, ys vOtherEditsNotes +Wrap w400 h50,

Gui, Add, Text, x215 y190 section w120 h20, DxO Silver Efex Preset:
Gui, Add, DropDownList, ys vDxOSEPreset w400 h180, %gSilverEfexPresets%

Gui, Add, Text, x215 y215 section w120 h20, DxO Silver Efex Notes:
Gui, Add, Edit, ys vSilverEfexNotes +Wrap w400 h50,

Gui, Add, Text, x215 y270 section w120 h20, Notepad:
Gui, Add, Edit, ys vOverview +Wrap w400 h80,

Gui, Add, StatusBar, ,

Gui, Show, w750 h410, Shropshire Photography

SB_SetParts(200)
SB_SetText("Number of Places: " . gNumPlaces, 1)

Return

;=====================================================================
; Handle GUI re-sizing
;=====================================================================

GuiSize:
  GuiControl, Move, Category1, % "w" .  196 + ((A_GuiWidth - 750) / 2)
  GuiControl, Move, Category2, % "w" .  196 + ((A_GuiWidth - 750) / 2) "X" .  548 + ((A_GuiWidth - 750) / 2)
  GuiControl, Move, PlaceList, % "h" . A_GuiHeight - 25
  GuiControl, Move, OrigName, % "w" .  A_GuiWidth - 350
  GuiControl, Move, DxOPLPreset, % "w" .  A_GuiWidth - 350
  GuiControl, Move, DxOPLNotes, % "w" .  A_GuiWidth - 350
  GuiControl, Move, OtherEditsNotes, % "w" .  A_GuiWidth - 350
  GuiControl, Move, DxOSEPreset, % "w" .  A_GuiWidth - 350
  GuiControl, Move, SilverEfexNotes, % "w" .  A_GuiWidth - 350
  GuiControl, Move, Overview, % "w" .  A_GuiWidth - 350 "h" . A_GuiHeight - 330
  Return

;=====================================================================
; Handle GUI close event
;=====================================================================

GuiClose:
	DB.CloseDB()
	ExitApp

;=====================================================================
; File menu events
;=====================================================================

MenuSave:
	Gui, Submit, NoHide
	if StrLen(argPlace) <> 0
	{
		GuiValues()
		SavePlace()
	}
	else 
	{
    MsgBox, 48, Error, No Place is Selected
	}
  Return

MenuNew:
	InputBox, newPlace, New Place, Enter the name of the place:
	If ErrorLevel
		Return
	if (CheckExists(newPlace))
	{
    MsgBox, 48, Error, The place name already exists: %newPlace%
		Return
	}
	ClearFilter()
	DefaultPlace()
	argPlace := newPlace
	SavePlace()
	newFolder := BasePath . "\" . newPlace
	FileCreateDir, %newFolder%
	if ErrorLevel
	{
 		MsgBox, 48, Error, Failed to create folder %newFolder%
	}
	LoadPlaces()
	GuiControl, , PlaceList, %gPlaces%
	DrawGUI()
	SB_SetText("Number of Places: " . gNumPlaces, 1)
	GuiControl, ChooseString, PlaceList, %argPlace%
	Return

MenuRename:
	if StrLen(argPlace) <> 0
	{
		InputBox, newPlace, Rename Place, Enter the name of the place:, , , , , , , , %argPlace%
		If ErrorLevel
			Return
		if (CheckExists(newPlace))
		{
    	MsgBox, 48, Error, The place name already exists: %newPlace%
			Return
		}
		SQL := "UPDATE Place SET Name=""" . newPlace . """ WHERE Name=""" . argPlace . """"
		DB.Exec(SQL)
		newFolder := BasePath . "\" . newPlace
		oldFolder := BasePath . "\" . argPlace
		FileMoveDir, %oldFolder%, %newFolder%
		if ErrorLevel
		{
 			MsgBox, 48, Error, Failed to rename folder %oldFolder%
		}
		ClearFilter()
		argPlace := newPlace
		LoadPlaces()
		GuiControl, , PlaceList, %gPlaces%
		DrawGUI()
		SB_SetText("Number of Places: " . gNumPlaces, 1)
		GuiControl, ChooseString, PlaceList, %argPlace%
	}
	else 
	{
    MsgBox, 48, Error, No Place is Selected
	}
	Return

MenuDelete:
	if StrLen(argPlace) <> 0
	{
		MsgBox, 4, Delete Place, Really delete %argPlace%?
		IfMsgBox, Yes
		{
			SQL := "DELETE FROM Place WHERE Name=""" . argPlace . """"
			DB.Exec(SQL)
			oldFolder := BasePath . "\" . argPlace
			FileRemoveDir, %oldFolder%, 1
			if ErrorLevel
			{
 				MsgBox, 48, Error, Failed to delete folder %oldFolder%
			}
			ClearFilter()
			LoadPlaces()
			GuiControl, , PlaceList, %gPlaces%
			DefaultPlace()
			argPlace := ""
			DrawGUI()
			SB_SetText("Number of Places: " . gNumPlaces, 1)
		}
	}
	else 
	{
    MsgBox, 48, Error, No Place is Selected
	}
	Return

MenuExit:
	DB.CloseDB()
	ExitApp

;=====================================================================
; Image menu events
;=====================================================================

MenuImageSelect:
	if StrLen(argPlace) = 0
	{
    MsgBox, 48, Error, No Place is Selected
	  Return
	}
	FileSelectFile, sOrigName, 3, E:\My Pictures\Originals, Select Original File, Photographs (*.nef; *.jpg)
	if StrLen(sOrigName) <> 0
	{
		NOrigName := sOrigName
		GuiControl, Text, OrigName, %NOrigName%
		Gui, Submit, NoHide
		GuiValues()
		SavePlace()
	}
  Return

MenuImageView:
	if StrLen(argPlace) = 0
	{
    MsgBox, 48, Error, No Place is Selected
	  Return
	}
	IniRead, ViewerEXE, %A_ScriptDir%\Shropshire Photography.ini, Programs, ImageViewer
	Run, "%ViewerEXE%" /view "%NOrigName%"
  Return

MenuImageMove:
	if StrLen(argPlace) = 0
	{
    MsgBox, 48, Error, No Place is Selected
	  Return
	}
	TmpPath := BasePath . "\*"
	ListOfImages := ""
	FirstPlace := True
	Loop, Files, %TmpPath%, F
  {
		ListOfImages := ListOfImages . A_LoopFileName
		if FirstPlace
		{
			FirstPlace := False
			ListOfImages := ListOfImages . "||"
		}
		else {
			ListOfImages := ListOfImages . "|"
		}
  }
  if StrLen(ListOfImages) > 1
  {
  	Gui, ImageChooser:Add, Text, xm section w200 h20, Select Image File for Place:
  	Gui, ImageChooser:Add, DropDownList, xm section vImageChosen w400 h60, %ListOfImages%
  	Gui, ImageChooser:Add, Button, xm section w50 h20, OK
  	Gui, ImageChooser:Add, Button, ys w50 h20, Cancel
  	Gui, ImageChooser:Show, w440 h100, Image Chooser
  	Gui, 1:Default
  }
  else
  {
  	MsgBox, 48, Error, There are no image files to select
  }
  Return

ImageChooserButtonOK:
	Gui, ImageChooser:Submit, NoHide
	tDstFolder := BasePath . "\" . argPlace . "\"
	tMoveName := BasePath . "\" . ImageChosen
  FileMove, %tMoveName%, %tDstFolder%, 1
  Gui, ImageChooser:Destroy
  MsgBox, 0, Information, File for Item Moved
  Return

ImageChooserButtonCancel:
  Gui, ImageChooser:Destroy
  Return

;=====================================================================
; Place menu events
;=====================================================================

MenuEditNotes:
	if StrLen(argPlace) = 0
	{
    MsgBox, 48, Error, No Place is Selected
	  Return
	}
	Gui, Submit, NoHide
  IniRead, TempPath, %A_ScriptDir%\Shropshire Photography.ini, Paths, TempFolder
  TempPath := TempPath . "\temp.md"
  tmpFile := FileOpen(TempPath, "w", "UTF-8")
  tmpFile.Write(Overview)
  tmpFile.Close()
  IniRead, TxtEditor, %A_ScriptDir%\Shropshire Photography.ini, Programs, MarkdownEditor
  RunWait, "%TxtEditor%" "%TempPath%"
  FileRead, NOverview, %TempPath%
  GuiControl, Text, Overview, %NOverview%
	Gui, Submit, NoHide
	GuiValues()
	SavePlace()
  Return

MenuGotoPublished:
	if StrLen(argPlace) = 0
	{
    MsgBox, 48, Error, No Place is Selected
	  Return
	}
	IniRead, ImageBrowser, %A_ScriptDir%\Shropshire Photography.ini, Programs, ImageBrowser
  TemPath := BasePath . "\" . argPlace
  Run, "%ImageBrowser%" "%TemPath%"
  Return

MenuCreateTemplate:
	if StrLen(argPlace) = 0
	{
    MsgBox, 48, Error, No Place is Selected
	  Return
	}
	Gui, Submit, NoHide
  tmpOrig := "<image>"
	ImgPath := BasePath . "\" . argPlace . "\*.jpg"
	ListOfImages := ""
	FirstPlace := True
	Loop, Files, %ImgPath%, F
  {
		ListOfImages := ListOfImages . A_LoopFileName
		if FirstPlace
		{
			FirstPlace := False
			ListOfImages := ListOfImages . "||"
		}
		else {
			ListOfImages := ListOfImages . "|"
		}
  }
  if StrLen(ListOfImages) > 1
  {
  	if SubStr(ListOfImages, -1) = "||"
  	{
  		tmpOrig := SubStr(ListOfImages, 1, StrLen(ListOfImages)-2)
  		WriteTemplate(tmpOrig)
  	}
    else {
  	  Gui, ImageChooser2:Add, Text, xm section w200 h20, Select Image File for Place:
  	  Gui, ImageChooser2:Add, DropDownList, xm section vImageChosen w400 h60, %ListOfImages%
  	  Gui, ImageChooser2:Add, Button, xm section w50 h20, OK
  	  Gui, ImageChooser2:Show, w440 h100, Image Chooser
  	  Gui, 1:Default
    }
  }
  else {
    WriteTemplate(tmpOrig)
  }
;  tmpOrig := SubStr(OrigName, InStr(OrigName, "\", , -1)+1)
;  tmpOrig := SubStr(tmpOrig, 1, StrLen(tmpOrig)-4)
  Return

ImageChooser2ButtonOK:
	Gui, ImageChooser2:Submit, NoHide
	WriteTemplate(ImageChosen)
  Gui, ImageChooser2:Destroy
  Return

WriteTemplate(pImgFile) {
	global
  IniRead, TempPath, %A_ScriptDir%\Shropshire Photography.ini, Paths, TempFolder
  TempPath := TempPath . "\temp.txt"
  tmpFile := FileOpen(TempPath, "w", "UTF-8")
  Switch Category1
  {
  	Case "History":
  		tmpFile.WriteLine("<!--Type: Item-->")
      tmpFile.WriteLine("# Date: ")
      tmpFile.WriteLine("# Name: ")
      tmpFile.WriteLine("")
      tmpFile.WriteLine("<notes>")
      tmpFile.WriteLine("![](../1shropshire/assets/images/history/" . pImgFile)
      Switch Category2
      {
      	Case "Castle":
          tmpFile.WriteLine("")
  		    tmpFile.WriteLine("<!--Type: Item-->")
          tmpFile.WriteLine("# Date: ")
          tmpFile.WriteLine("# Name: ")
          tmpFile.WriteLine("")
          tmpFile.WriteLine("<notes>")
          tmpFile.WriteLine("![](../1shropshire/assets/images/castles/" . pImgFile)
      	Case "House":
          tmpFile.WriteLine("")
  		    tmpFile.WriteLine("<!--Type: Item-->")
          tmpFile.WriteLine("# Date: ")
          tmpFile.WriteLine("# Name: ")
          tmpFile.WriteLine("")
          tmpFile.WriteLine("<notes>")
          tmpFile.WriteLine("![](../1shropshire/assets/images/houses/" . pImgFile)
      	Case "Folklore":
          tmpFile.WriteLine("")
  		    tmpFile.WriteLine("<!--Type: Item-->")
          tmpFile.WriteLine("# Date: ")
          tmpFile.WriteLine("# Name: ")
          tmpFile.WriteLine("")
          tmpFile.WriteLine("<notes>")
          tmpFile.WriteLine("![](../1shropshire/assets/images/folklore/" . pImgFile)
      	Case "People":
          tmpFile.WriteLine("")
  		    tmpFile.WriteLine("<!--Type: Item-->")
          tmpFile.WriteLine("# Date: ")
          tmpFile.WriteLine("# Name: ")
          tmpFile.WriteLine("")
          tmpFile.WriteLine("<notes>")
          tmpFile.WriteLine("![](../1shropshire/assets/images/people/" . pImgFile)
      }
  	Case "Church":
  		tmpFile.WriteLine("<!--Type: Item-->")
      tmpFile.WriteLine("## Date: ")
      tmpFile.WriteLine("# Name: ")
      tmpFile.WriteLine("")
      tmpFile.WriteLine("<notes>")
      tmpFile.WriteLine("![](../1shropshire/assets/images/churches/" . pImgFile)
      tmpFile.WriteLine("- Sub-Image: ")
  	Case "Miscellaneous":
  		tmpFile.WriteLine("<!--Type: Item-->")
      tmpFile.WriteLine("# Name: ")
      tmpFile.WriteLine("")
      tmpFile.WriteLine("<notes>")
      tmpFile.WriteLine("![](../1shropshire/assets/images/miscellaneous/" . pImgFile)
  	Case "Landscape":
  		tmpFile.WriteLine("<!--Type: Item-->")
      tmpFile.WriteLine("# Name: ")
      tmpFile.WriteLine("")
      tmpFile.WriteLine("<notes>")
      tmpFile.WriteLine("![](../1shropshire/assets/images/landscape/" . pImgFile)
  	Case "Place":
  		tmpFile.WriteLine("<!--Type: Item-->")
      tmpFile.WriteLine("# Name: ")
      tmpFile.WriteLine("")
      tmpFile.WriteLine("<notes>")
      tmpFile.WriteLine("![](../1shropshire/assets/images/places/" . pImgFile)
  	Case "Garden":
  		tmpFile.WriteLine("<!--Type: Item-->")
      tmpFile.WriteLine("# Name: ")
      tmpFile.WriteLine("")
      tmpFile.WriteLine("<notes>")
      tmpFile.WriteLine("![](../1shropshire/assets/images/gardens/" . pImgFile)
  }
  tmpFile.Close()
  IniRead, TxtEditor, %A_ScriptDir%\Shropshire Photography.ini, Programs, TextEditor
  Run, "%TxtEditor%" "%TempPath%"
}

;=====================================================================
; Filter menu events
;=====================================================================

MenuClearFilter:
	ClearFilter()
	ApplyFilter()
	Return

MenuFilterHistory:
	ClearFilter()
	Menu, FilterMenu, Check, History
	SB_SetText("Filter: History", 2)
	filterCat1 := "History"
	ApplyFilter()
	Return

MenuFilterCastle:
	ClearFilter()
	Menu, FilterMenu, Check, Castle
	SB_SetText("Filter: Castle", 2)
	filterCat2 := "Castle"
	ApplyFilter()
	Return

MenuFilterChurch:
	ClearFilter()
	Menu, FilterMenu, Check, Church
	SB_SetText("Filter: History", 2)
	filterCat1 := "Church"
	ApplyFilter()
	Return

MenuFilterHouse:
	ClearFilter()
	Menu, FilterMenu, Check, House
	SB_SetText("Filter: House", 2)
	filterCat2 := "House"
	ApplyFilter()
	Return

MenuFilterPeople:
	ClearFilter()
	Menu, FilterMenu, Check, People
	SB_SetText("Filter: People", 2)
	filterCat2 := "People"
	ApplyFilter()
	Return

MenuFilterLandscape:
	ClearFilter()
	Menu, FilterMenu, Check, Landscape
	SB_SetText("Filter: Landscape", 2)
	filterCat1 := "Landscape"
	ApplyFilter()
	Return

MenuFilterGarden:
	ClearFilter()
	Menu, FilterMenu, Check, Garden
	SB_SetText("Filter: Garden", 2)
	filterCat1 := "Garden"
	ApplyFilter()
	Return

MenuFilterPlace:
	ClearFilter()
	Menu, FilterMenu, Check, Place
	SB_SetText("Filter: Place", 2)
	filterCat1 := "Place"
	ApplyFilter()
	Return

MenuFilterFolklore:
	ClearFilter()
	Menu, FilterMenu, Check, Folklore
	SB_SetText("Filter: Folklore", 2)
	filterCat2 := "Folklore"
	ApplyFilter()
	Return

MenuFilterMiscellaneous:
	ClearFilter()
	Menu, FilterMenu, Check, Miscellaneous
	SB_SetText("Filter: Miscellaneous", 2)
	filterCat1 := "Miscellaneous"
	ApplyFilter()
	Return

MenuFilterInformation:
	ClearFilter()
	Menu, FilterMenu, Check, Information
	SB_SetText("Filter: Information", 2)
	filterCat1 := "Information"
	ApplyFilter()
	Return

ClearFilter() {
	global
	Menu, FilterMenu, Uncheck, History
	Menu, FilterMenu, Uncheck, Castle
	Menu, FilterMenu, Uncheck, Church
	Menu, FilterMenu, Uncheck, House
	Menu, FilterMenu, Uncheck, People
	Menu, FilterMenu, Uncheck, Landscape
	Menu, FilterMenu, Uncheck, Garden
	Menu, FilterMenu, Uncheck, Place
	Menu, FilterMenu, Uncheck, Folklore
	Menu, FilterMenu, Uncheck, Miscellaneous
	Menu, FilterMenu, Uncheck, Information
	SB_SetText("", 2)
	filterCat1  := "%"
	filterCat2  := "%"
}

ApplyFilter() {
	global
	LoadPlaces()
	GuiControl, , PlaceList, %gPlaces%
	DefaultPlace()
	argPlace := ""
	DrawGUI()
	SB_SetText("Number of Places: " . gNumPlaces, 1)
}

;=====================================================================
; Project menu events
;=====================================================================

MenuGenerateReport:
	repName := A_ScriptDir . "\Notes.md"
  repFile := FileOpen(repName, "w", "UTF-8")
	SQL := "SELECT Name, GeneralNotes FROM Place ORDER BY Name;"
  DB.Query(SQL, RecordSet)
	Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0)
    {
    	repFile.WriteLine("# " . Row[1])
    	repFile.WriteLine("")
    	repFile.WriteLine(Row[2])
    	repFile.WriteLine("")
    }
	}	Until RC < 1
  RecordSet.Free()
  repFile.Close()
  MsgBox, 0, Information, Report Created
  Return

MenuViewReport:
  IniRead, WebBrowser, %A_ScriptDir%\Shropshire Photography.ini, Programs, WebBrowser
	repName := A_ScriptDir . "\Notes.md"
  Run, "%WebBrowser%" "%repName%"
  Return

MenuCompareFolders:
	CompareListsFolders()
  Return

MenuCompareACDSee:
	ImportACDSee()
  Return

MenuUnusedImages:
	SQL := "DELETE FROM Compare_Temp;"
  DB.Exec(SQL)
	Progress, R0-25, , Importing Asset and MD Lists, Database Update
  UnusedImagesLoadAssets("Castle", "castles")
  Progress, 1
  UnusedImagesLoadAssets("Church", "churches")
  Progress, 2
  UnusedImagesLoadAssets("Folklore", "folklore")
  Progress, 3
  UnusedImagesLoadAssets("Garden", "gardens")
  Progress, 4
  UnusedImagesLoadAssets("History", "history")
  Progress, 5
  UnusedImagesLoadAssets("House", "houses")
  Progress, 6
  UnusedImagesLoadAssets("Landscape", "landscape")
  Progress, 7
  UnusedImagesLoadAssets("Miscellaneous", "miscellaneous")
  Progress, 8
  UnusedImagesLoadAssets("People", "people")
  Progress, 9
  UnusedImagesLoadAssets("Place", "places")
  Progress, 10
  UnusedImagesLoadMD("Castle", "Shropshire_Notebook-Castles.md")
  Progress, 11
  UnusedImagesLoadMD("Church", "Shropshire_Notebook-Churches.md")
  Progress, 12
  UnusedImagesLoadMD("Folklore", "Shropshire_Notebook-Folklore.md")
  Progress, 13
  UnusedImagesLoadMD("Garden", "Shropshire_Notebook-Gardens.md")
  Progress, 14
  UnusedImagesLoadMD("History", "Shropshire_Notebook-History.md")
  Progress, 15
  UnusedImagesLoadMD("House", "Shropshire_Notebook-Houses.md")
  Progress, 16
  UnusedImagesLoadMD("Landscape", "Shropshire_Notebook-Landscape.md")
  Progress, 17
  UnusedImagesLoadMD("Miscellaneous", "Shropshire_Notebook-Miscellaneous.md")
  Progress, 18
  UnusedImagesLoadMD("People", "Shropshire_Notebook-People.md")
  Progress, 19
  UnusedImagesLoadMD("Place", "Shropshire_Notebook-Bridgnorth.md")
  Progress, 20
  UnusedImagesLoadMD("Place", "Shropshire_Notebook-Ludlow.md")
  Progress, 21
  UnusedImagesLoadMD("Place", "Shropshire_Notebook-Oswestry.md")
  Progress, 22
  UnusedImagesLoadMD("Place", "Shropshire_Notebook-Shrewsbury.md")
  Progress, 23
  UnusedImagesLoadMD("Place", "Shropshire_Notebook-Telford.md")
  Progress, 24
  UnusedImagesLoadMD("Place", "Shropshire_Notebook-Whtchurch.md")
	Progress, Off

  Gui, UnusedView:Add, ListView, r25 w820, What|Status|FileName
  Gui, UnusedView:Default

  RecordSet := ""
  SQL := "SELECT What, FileName FROM Compare_Temp WHERE What = 'Church' AND Type = 'Asset' AND FileName NOT IN (SELECT FileName FROM Compare_Temp WHERE What = 'Church' AND Type = 'MD');"
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0)
    {
      LV_Add("", Row[1], "In Asset but not used in MD", Row[2])
    }
  } Until RC < 1
  RecordSet.Free()
  RecordSet := ""
  SQL := "SELECT What, FileName FROM Compare_Temp WHERE What = 'Church' AND Type = 'MD' AND FileName NOT IN (SELECT FileName FROM Compare_Temp WHERE What = 'Church' AND Type = 'Asset');"
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0)
    {
      LV_Add("", Row[1], "In MD but has no Asset", Row[2])
    }
  } Until RC < 1
  RecordSet.Free()

  LV_ModifyCol()

  Gui, UnusedView:Add, Button, xm section w50 h20, Close
  Gui, UnusedView:Show, w840 h530, Shropshire Photography
  Gui, 1:Default

  Return

UnusedViewButtonClose:
	Gui, UnusedView:Destroy
	Return

UnusedImagesLoadAssets(pWhat, pAsset) {
	global
	TmpPath := A_ScriptDir . "\..\assets\images\" . pAsset . "\*.jpg"
	Loop, Files, %TmpPath%, F
	{
		if A_LoopFileName <> photo-needed.jpg
		{
			SQL := "INSERT INTO Compare_Temp (What, Type, FileName) VALUES ('" . pWhat . "', 'Asset', '" . A_LoopFileName . "');"
			DB.Exec(SQL)
		}
  }
}

UnusedImagesLoadMD(pWhat, pFilename) {
	global
	TmpPath := A_ScriptDir . "\..\_data_source\" . pFilename
  Loop, Read, %TmpPath%
  {
  	if InStr(A_LoopReadLine, "![](") == 1
  	{
  		si := InStr(A_LoopReadLine, "/", False, -1)
  		ei := InStr(A_LoopReadLine, ".jpg", False, -1)
  		TmpName := SubStr(A_LoopReadLine, si + 1, (ei - si) + 3)
			SQL := "INSERT INTO Compare_Temp (What, Type, FileName) VALUES ('" . pWhat . "', 'MD', '" . TmpName . "');"
			DB.Exec(SQL)
  	}
  }
}

;=====================================================================
; Help menu events
;=====================================================================

MenuAbout:
  Return

;=====================================================================
; GUI control events
;=====================================================================

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

Category1:
	Gui, Submit, NoHide
	if ("" . Category1 = "History")
	{
		GuiControl, , Category2, |N/A||Castle|Folklore|House|People
		GuiControl, Enable, Category2
	}
	else if ("" . Category1 = "Landscape")
	{
		GuiControl, , Category2, |N/A||Folklore
		GuiControl, Enable, Category2
	}
	else 
	{
		GuiControl, , Category2, |N/A||
		GuiControl, Disable, Category2
	}
	Return

;=====================================================================
; Compare list of names in file system with list in database.
;=====================================================================

CompareListsFolders() {
	global
	ImportFolders()
	NotInDB := ""
	NotInFS := "" 
  RecordSet := ""
	SQL := "SELECT Name FROM Folder_Places WHERE Name NOT IN (SELECT Name FROM Place);"
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0) {
    	if (StrLen(NotInDB) <> 0) {
    		NotInDB := NotInDB . ", "
    	}
    	NotInDB := NotInDB . Row[1]
    }
  } Until RC < 1
  RecordSet.Free()
  RecordSet := ""
	SQL := "SELECT Name FROM Place WHERE Name NOT IN (SELECT Name FROM Folder_Places);"
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0) {
    	if (StrLen(NotInFS) <> 0) {
    		NotInFS := NotInFS . ", "
    	}
    	NotInFS := NotInFS . Row[1]
    }
  } Until RC < 1
  RecordSet.Free()
  if (StrLen(NotInDB) <> 0) {
  	MsgBox 0, Information, The following are not in the database: %NotInDB%
  }
  if (StrLen(NotInFS) <> 0) {
  	MsgBox 0, Information, The following are not in the file system: %NotInFS%
  }
  if (StrLen(NotInDB) == 0 and StrLen(NotInFS) == 0) {
  	MsgBox 0, Information, The database and file system are in sync.
  }
}

;=====================================================================
; Import folder list into the database.
;=====================================================================

ImportFolders() {
	global
	SQL := "DELETE FROM Folder_Places;"
  DB.Exec(SQL)
	TmpCnt := 0
	TmpPath := BasePath . "\*"
	Loop, Files, %TmpPath%, D
	{
		TmpCnt := TmpCnt + 1
	}
	Progress, R0-%TmpCnt%, , Importing Folder List, Database Update
	TmpCnt := 0
	TmpPath := BasePath . "\*"
	Loop, Files, %TmpPath%, D
	{
		SQL := "INSERT INTO Folder_Places (Name) VALUES (""" . A_LoopFileName . """);"
	  DB.Exec(SQL)
		TmpCnt := TmpCnt + 1
	  Progress, %TmpCnt%
	}
	Progress, Off
}

;=====================================================================
; Compare the ACDSee data with the database.
;=====================================================================

ImportACDSee() {

  global
  RunWait, %A_ScriptDir%\Load ACDSeeDB.cmd

  Gui, DeltaView:Add, ListView, r25 w820, Status|FileName|Name
  Gui, DeltaView:Default

  RecordSet := ""
  SQL := "SELECT Status, FileName, Name FROM ACDSee_Delta;"
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0)
    {
      LV_Add("", Row[1], Row[2], Row[3])
    }
  } Until RC < 1
  RecordSet.Free()

  LV_ModifyCol()

  Gui, DeltaView:Add, Button, xm section w50 h20, Close
  Gui, DeltaView:Show, w840 h530, Shropshire Photography
  Gui, 1:Default

}

DeltaViewButtonClose:
	Gui, DeltaView:Destroy
	Return

;=====================================================================
; Draw the GUI.
;=====================================================================

DrawGUI()
{
	global
	GuiControl, Text, OrigName, %NOrigName%
	GuiControl, ChooseString, Category1, %NCategory1%
	if ("" . NCategory1 = "History")
	{
		GuiControl, , Category2, |N/A||Castle|Folklore|House|People
		GuiControl, Enable, Category2
	}
	else if ("" . NCategory1 = "Landscape")
	{
		GuiControl, , Category2, |N/A||Folklore
		GuiControl, Enable, Category2
	}
	else 
	{
		GuiControl, , Category2, |N/A||
		GuiControl, Disable, Category2
	}
	GuiControl, ChooseString, Category2, %NCategory2%
	GuiControl, ChooseString, DxOPLPreset, %NDxOPLPreset%
	GuiControl, Text, DxOPLNotes, %NDxOPLNotes%
	GuiControl, Text, OtherEditsNotes, %NOtherEditsNotes%
	GuiControl, ChooseString, DxOSEPreset, %NDxOSEPreset%
	GuiControl, Text, SilverEfexNotes, %NSilverEfexNotes%
	GuiControl, Text, Overview, %NOverview%
}

;=====================================================================
; Retrieve the latest values from the GUI.
;=====================================================================

GUIValues()
{
	global
	NCategory1 := Category1
	NCategory2 := Category2
	NOrigName := OrigName
	NDxOPLPreset := DxOPLPreset
	NDxOPLNotes := DxOPLNotes
	NOtherEditsNotes := OtherEditsNotes
	NDxOSEPreset := DxOSEPreset
	NSilverEfexNotes := SilverEfexNotes
	NOverview := Overview
}

;=====================================================================
; Set the place to the default values.
;=====================================================================

DefaultPlace() {
	global
	NCategory1 := "History"
	NCategory2 := "N/A"
	NOrigName := "Not yet defined"
	NDxOPLPreset := "1 - DxO Standard"
	NDxOPLNotes := ""
	NOtherEditsNotes := ""
	NDxOSEPreset := "DxO Silver Efex Not Used"
	NSilverEfexNotes := ""
	NOverview := ""
}

;=====================================================================
; Check if the place already exists.
;=====================================================================

CheckExists(pPlace) {
	global
  retExists := False
  SQL := "SELECT Count(*) FROM Place WHERE Name=""" . pPlace . """;"
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0) {
      if (Row[1] = "1") {
        retExists := True
      }
    }
  } Until RC < 1
  RecordSet.Free()
	Return retExists
}

;=====================================================================
; Load the list of places.
;=====================================================================

LoadPlaces() {
; Note that the list of places needs a pipe as the first character so
; that it replaces the existing list otherwise it will append
  global
  gPlaces := ""
  gNumPlaces := 0
  RecordSet := ""
  whereClause := "Category1 LIKE '" . filterCat1 . "' AND Category2 LIKE '" . filterCat2 . "'"
  SQL := "SELECT ID, Name FROM Place WHERE " . whereClause . " ORDER BY Name;"
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0) {
    	gNumPlaces := gNumPlaces + 1
      gPlaces := gPlaces . "|" . row[2]
    }
  } Until RC < 1
  RecordSet.Free()
}

;=====================================================================
; Save a place to the database.
;=====================================================================

SavePlace() {
  global
  if (CheckExists(argPlace)) {
    SQL := "UPDATE Place SET "
    SQL := SQL . "Category1=""" . NCategory1 . """, "
    SQL := SQL . "Category2=""" . NCategory2 . """, "
    SQL := SQL . "Original=""" . NOrigName . """, "
    SQL := SQL . "OrigName=""" . SubStr(NOrigName, InStr(NOrigName, "\", false, -1)+1) . """, "
    SQL := SQL . "DxOPLPreset=""" . NDxOPLPreset . """, "
    SQL := SQL . "DxOPLNotes=""" . StringToDB(NDxOPLNotes) . """, "
    SQL := SQL . "AffinityNotes=""" . StringToDB(NOtherEditsNotes) . """, "
    SQL := SQL . "SilverEfexPreset=""" . NDxOSEPreset . """, "
    SQL := SQL . "SilverEfexNotes=""" . StringToDB(NSilverEfexNotes) . """, "
    SQL := SQL . "GeneralNotes=""" . StringToDB(NOverview) . """ "
    SQL := SQL . "WHERE Name=""" . argPlace . """;"
  } else {
    SQL := "INSERT INTO Place (Name, Category1, Category2, Original, OrigName, DxOPLPreset, DxOPLNotes, AffinityNotes, SilverEfexPreset, SilverEfexNotes, GeneralNotes) VALUES ("
    SQL := SQL . """" . argPlace . """, "
    SQL := SQL . """" . NCategory1 . """, "
    SQL := SQL . """" . NCategory2 . """, "
    SQL := SQL . """" . NOrigName . """, "
    SQL := SQL . """" . SubStr(NOrigName, InStr(NOrigName, "\", false, -1)+1) . """, "
    SQL := SQL . """" . NDxOPLPreset . """, "
    SQL := SQL . """" . StringToDB(NDxOPLNotes) . """, "
    SQL := SQL . """" . StringToDB(NOtherEditsNotes) . """, "
    SQL := SQL . """" . NDxOSEPreset . """, "
    SQL := SQL . """" . StringToDB(NSilverEfexNotes) . """, "
    SQL := SQL . """" . StringToDB(NOverview) . """ "
    SQL := SQL . ");"
  }
  DB.Exec(SQL)
}

;=====================================================================
; Load a place from the database.
;=====================================================================

LoadPlace() {
  global
	DefaultPlace()
  RecordSet := ""
  SQL := "SELECT Category1, Category2, Original, DxOPLPreset, DxOPLNotes, AffinityNotes, SilverEfexPreset, SilverEfexNotes, GeneralNotes FROM Place WHERE Name=""" . argPlace . """;"
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0) {
    	NCategory1 := Row[1]
    	NCategory2 := Row[2]
    	NOrigName := Row[3]
    	NDxOPLPreset := Row[4]
			NDxOPLNotes := StringFromDB(Row[5])
			NOtherEditsNotes := StringFromDB(Row[6])
			NDxOSEPreset := Row[7]
			NSilverEfexNotes := StringFromDB(Row[8])
			NOverview := StringFromDB(Row[9])
    }
  } Until RC < 1
  RecordSet.Free()
}

;=====================================================================
; Conversion functions to deal with double quotes in the strings.
;=====================================================================

StringToDB(pString) {
  return StrReplace(pString, """", "&quote;")
}

StringFromDB(pString) {
  return StrReplace(pString, "&quote;", """")
}

;=====================================================================
; Read the list of DxO Presets from the database.
;=====================================================================

LoadDxOPresets() {
  global
  gDxOPresets := ""
  RecordSet := ""
  SQL := "SELECT ID, Name FROM DxOPresets ORDER BY ID;"
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0) {
      if (StrLen(gDxOPresets) <> 0) {
        gDxOPresets := gDxOPresets . "|"
      }
      gDxOPresets := gDxOPresets . row[2]
    }
  } Until RC < 1
  RecordSet.Free()
}

;=====================================================================
; Read the list of Silver Efex Presets from the database.
;=====================================================================

LoadSilverEfexPresets() {
  global
  gSilverEfexPresets := ""
  RecordSet := ""
  SQL := "SELECT ID, Name FROM SilverEfexPresets ORDER BY ID;"
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0) {
      if (StrLen(gSilverEfexPresets) <> 0) {
        gSilverEfexPresets := gSilverEfexPresets . "|"
      }
      gSilverEfexPresets := gSilverEfexPresets . row[2]
    }
  } Until RC < 1
  RecordSet.Free()
}
