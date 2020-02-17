;=====================================================================
; Script to manage the status of the Shropshire Photography project
;
; Language: AutoHotKey
;
; Author: David Banham
;
; Version: 2.0
;
; Date: 24th January 2019
;
; Version History:
; 1.0 - initial release
; 2.0 - changed to use SQLite
;
;=====================================================================

; Ensure that only a single instance of the script will be running,
; this is necessary because the script will restart itself in a
; different mode in one usage scenario.

#SingleInstance force

#Include %A_ScriptDir%\Class_SQLiteDB.ahk

;=====================================================================
; Initialise the key variables
;=====================================================================

; The base path for the project folders - in this base folder is a
; set of folders, one for each 'place'

; BasePath := "C:\Users\David\Documents\Google Drive\3. Shropshire\Photography"
IniRead, BasePath, %A_ScriptDir%\Shropshire Photography.ini, Paths, BasePath

; The lists of presets for the dropdown lists

gDxOPresets := ""
gSilverEfexPresets := ""

; Open the database

IniRead, DBFile, %A_ScriptDir%\Shropshire Photography.ini, Database, DBFile
DB := new SQLiteDB
DB.OpenDB(DBFile)
LoadDxOPresets()
LoadSilverEfexPresets()

;

ListOfPlaces := ""

;

argPlace := ""
argOriginal := ""
argPlacePos := -1
argPlaceNum := 0

;
	
mode := -1

BuildListOfPlaces("")

;=====================================================================
; Process the arguments.
;=====================================================================

If A_args.Length() = 0
{
	mode := 0
}

If A_args.Length() = 1
{
	if InStr(A_args[1], "E:\My Pictures\Originals") = 1
	{
    argOriginal := A_args[1]
    mode := 1
	}
  else {
	  argPlace := A_args[1]
	  tpos := InStr(argPlace, "\", false, -1)
	  argPlace := SubStr(argPlace, 1, tpos - 1)
	  tpos := InStr(argPlace, "\", false, -1)
	  argPlace := SubStr(argPlace, tpos + 1)
	  mode := 0
  }
}

If A_args.Length() = 2
{
	if A_args[1] = "-status"
	{
	  argPlace := A_args[2]
	  mode := 0
	}
}

if mode = -1
{
	MsgBox, 48, Error, Incorrect parameters - exiting`nParameters are:`n1. No parameters - status mode, defaulting to first Place`n2. Single parameter - taken as the full path and file name of an image, allows a Place to be chosen, then goes into status mode for that Place`n3. -status <place> - status mode, with specified Place
	DB.CloseDB()
	ExitApp
}

;=====================================================================
; Load the status notes for the selected Place.
;=====================================================================

LoadPlace()
if mode = 1
{
	NOrigName := argOriginal
}

;=====================================================================
; Build the GUI, which varies depending on which mode the script
; is operating in.
;=====================================================================

if mode = 0
{

  Menu, FileMenu, Add, Save, MenuSave
  Menu, FileMenu, Add
  Menu, FileMenu, Add, Exit, MenuExit
  Menu, ImageMenu, Add, Select, MenuImageSelect
  Menu, ImageMenu, Add, View, MenuImageView
  Menu, ImageMenu, Add
  Menu, ImageMenu, Add, Move, MenuImageMove
  Menu, PlaceMenu, Add, Create Folder, MenuCreateFolder
  Menu, PlaceMenu, Add, Edit Notes, MenuEditNotes
  Menu, PlaceMenu, Add
  Menu, PlaceMenu, Add, Goto Published in ACDSee, MenuGotoPublished
  Menu, PlaceMenu, Add
  Menu, PlaceMenu, Add, Generate Report, MenuGenerateReport
  Menu, PlaceMenu, Add, View Report, MenuViewReport
  Menu, ProjectMenu, Add, Status, MenuStatus
  Menu, ProjectMenu, Add
  Menu, ProjectMenu, Add, Compare Folders, MenuCompareFolders
  Menu, ProjectMenu, Add, Compare ACDSee, MenuCompareACDSee
  Menu, ProjectMenu, Add
  Menu, ProjectMenu, Add, Unused Images, MenuUnusedImages
  Menu, HelpMenu, Add, Test, MenuTest
  Menu, HelpMenu, Add, About, MenuAbout
  Menu, MyMenuBar, Add, File, :FileMenu
  Menu, MyMenuBar, Add, Image, :ImageMenu
  Menu, MyMenuBar, Add, Place, :PlaceMenu
  Menu, MyMenuBar, Add, Project, :ProjectMenu
  Menu, MyMenuBar, Add, Help, :HelpMenu
  Gui, Menu, MyMenuBar

	Gui +Resize +MinSize450x410
	Gui, Add, Text, xm section w120 h20, Places:
	Gui, Add, DropDownList, ys vPlace gPlace w300 h180, Empty|Null
	GuiControl, , Place, %ListOfPlaces%
	GuiControl, Choose, Place, 1
	Gui, Add, Button, ys w20 h20 gButtonFirst, <<
	Gui, Add, Button, ys w20 h20 gButtonPrev, <
	Gui, Add, Button, ys w20 h20 gButtonNext, >
	Gui, Add, Button, ys w20 h20 gButtonLast, >>

	Gui, Add, Text, xm section w120 h20, Category:
	Gui, Add, DropDownList, ys vCategory1 gCategory1 w200 h180, History|Church|Landscape|Miscellaneous|Place|Garden|Information
;	Gui, Add, Text, ys w90 h20, Sub Category:
	Gui, Add, DropDownList, ys vCategory2 w200 h180, N/A
	Gui, Add, DropDownList, ys vFilterPlaces gFilterPlaces w90 h160, Clear Filter|History|Castle|Church|House|People|Landscape|Place|Folklore|Miscellaneous|Information

	Gui, Add, Text, xm section w120 h20, Original Photograph:
	Gui, Add, Edit, ys vOrigName w500 h20,
;	Gui, Add, Button, ys w50 h20, Select
;	Gui, Add, Button, ys w50 h20, View

	Gui, Add, Text, xm section w120 h20, DxO PhotoLab Preset:
	Gui, Add, DropDownList, ys vDxOPLPreset w300 h180, %gDxOPresets%
;	Gui, Add, Text, ys w190 h20,
;	Gui, Add, Button, ys w50 h20, Move
;	Gui, Add, Button, xs+640 ys w50 h20, Workflow

	Gui, Add, Text, xm section w120 h20, DxO PhotoLab Notes:
	Gui, Add, Edit, ys vDxOPLNotes +Wrap w500 h50,

	Gui, Add, Text, xm section w120 h20, Other Edits Notes:
	Gui, Add, Edit, ys vAffinityNotes +Wrap w500 h50,

;	Gui, Add, Text, xm section w120 h20, PerfectlyClear Notes:
;	Gui, Add, Edit, ys vPClearNotes +Wrap w500 h50,

	Gui, Add, Text, xm section w120 h20, DxO Silver Efex Preset:
	Gui, Add, DropDownList, ys vDxOSEPreset w300 h180, %gSilverEfexPresets%

	Gui, Add, Text, xm section w120 h20, DxO Silver Efex Notes:
	Gui, Add, Edit, ys vSilverEfexNotes +Wrap w500 h50,

;	Gui, Add, Text, xm section w120 h20, Subject Notes:
;	Gui, Add, CheckBox, ys vSubjectNotes,

;	Gui, Add, Text, xm section w120 h20, Notes for Web:
;	Gui, Add, CheckBox, ys vWebNotes,

;	Gui, Add, Text, xm section w120 h20, Complete:
;	Gui, Add, CheckBox, ys vComplete,
;	Gui, Add, Text, xm section vHasFile w200 h20, No Database Record

	Gui, Add, Text, xm section w120 h20, Notepad:
	Gui, Add, Edit, ys vOverview +Wrap w500 h80,

;	Gui, Add, Button, xm section Default w50 h20 Section, Save
;	Gui, Add, Button, ys w50 h20, Status
;	Gui, Add, Button, ys w50 h20, Compare Folders
;	Gui, Add, Button, ys w50 h20, Compare Trello
;	Gui, Add, Button, ys w50 h20, Compare ACDSee
;	Gui, Add, Button, ys w50 h20, Exit

  Gui, Add, StatusBar, ,

	Gui, Show, w750 h410, Shropshire Photography

	GuiControl, ChooseString, Place, %argPlace%
	SB_SetParts(200)
	SB_SetText("Number of Places: " . argPlaceNum, 1)

}

if mode = 1
{

	Gui, Add, Text, xm section w120 h20, Places:
	Gui, Add, DropDownList, ys vPlace gPlace w390 h180, %ListOfPlaces%
	Gui, Add, Button, ys w100 h20 Section, Create Folder

	Gui, Add, Text, xm section w120 h20, Original Photograph:
	Gui, Add, Edit, ys vOrigName w500 h20,

	Gui, Add, Button, xm section Default w50 h20 Section, Save
	Gui, Add, Button, ys w50 h20, Cancel

	Gui, Show, w650 h90, Shropshire Photography
	
	GuiControl, ChooseString, Place, %argPlace%

}

DrawGUI()

Return

GuiSize:
  GuiControl, Move, Category1, % "w" .  250 + ((A_GuiWidth - 750) / 2)
  GuiControl, Move, Category2, % "w" .  250 + ((A_GuiWidth - 750) / 2) "X" .  395 + ((A_GuiWidth - 750) / 2)
  GuiControl, Move, FilterPlaces, % "X" .  650 + (A_GuiWidth - 750)
  GuiControl, Move, OrigName, % "w" .  A_GuiWidth - 150
  GuiControl, Move, DxOPLPreset, % "w" .  A_GuiWidth - 150
  GuiControl, Move, DxOPLNotes, % "w" .  A_GuiWidth - 150
  GuiControl, Move, DxOSEPreset, % "w" .  A_GuiWidth - 150
  GuiControl, Move, AffinityNotes, % "w" .  A_GuiWidth - 150
;  GuiControl, Move, PClearNotes, % "w" .  A_GuiWidth - 150
  GuiControl, Move, SilverEfexNotes, % "w" .  A_GuiWidth - 150
  GuiControl, Move, Overview, % "w" .  A_GuiWidth - 150 "h" . A_GuiHeight - 330
  Return

MenuSave:
	Gui, Submit, NoHide
	GuiValues()
	SavePlace()
	if mode = 1
	{
		Run, "%A_ScriptDir%\Shropshire Photography.exe" -status "%argPlace%"
	}
  Return

MenuExit:
	DB.CloseDB()
	ExitApp

MenuImageSelect:
	FileSelectFile, sOrigName, 3, E:\My Pictures\Originals, Select Original File, Photographs (*.nef; *.jpg)
	if StrLen(sOrigName) <> 0
	{
		NOrigName := sOrigName
		GuiControl, Text, OrigName, %NOrigName%
	}
  Return

MenuImageView:
	IniRead, ViewerEXE, %A_ScriptDir%\Shropshire Photography.ini, Programs, ImageViewer
	Run, "%ViewerEXE%" /view "%NOrigName%"
  Return

MenuImageMove:
;	FileSelectFile, tMoveName, 3, E:\My Pictures\Published\Shropshire, Select File for Item, Photographs (*.jpg)
;	if StrLen(tMoveName) <> 0
;	{
;		tDstFolder := BasePath . "\" . argPlace . "\"
;    FileMove, %tMoveName%, %tDstFolder%, 1
;    MsgBox, 0, Information, File for Item Moved
;	}
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

MenuEditNotes:
	Gui, Submit, NoHide
  IniRead, TempPath, %A_ScriptDir%\Shropshire Photography.ini, Paths, TempFolder
  TempPath := TempPath . "\temp.md"
  tmpFile := FileOpen(TempPath, "w", "UTF-8")
  tmpFile.Write(Overview)
  tmpFile.Close()
  IniRead, TxtEditor, %A_ScriptDir%\Shropshire Photography.ini, Programs, TextEditor
  RunWait, "%TxtEditor%" "%TempPath%" /fni
  FileRead, NOverview, %TempPath%
  GuiControl, Text, Overview, %NOverview%
	Gui, Submit, NoHide
	GuiValues()
	SavePlace()
  Return

MenuGotoPublished:
	IniRead, ImageBrowser, %A_ScriptDir%\Shropshire Photography.ini, Programs, ImageBrowser
  TemPath := BasePath . "\" . argPlace
  Run, "%ImageBrowser%" "%TemPath%"
  Return

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

MenuCreateFolder:
	InputBox, newPlace, Create Folder for Item, Enter name for the item's folder:
	If not ErrorLevel
	{
		newFolder := BasePath . "\" . newPlace
		FileCreateDir, %newFolder%
		if ErrorLevel
		{
  		MsgBox, 48, Error, Failed to create folder %newFolder%
		}
  	else
	  {
;  		MsgBox, 0, Information, Created folder %newFolder%
  		Gui, Destroy
	  	Run, "%A_ScriptDir%\Shropshire Photography.exe" -status %newPlace%
  	}
  }
  Return

MenuStatus:
	DisplayStatus()
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

MenuTest:
  Return

MenuAbout:
  Return

;=====================================================================
; GUI event handler
;=====================================================================

GuiClose:
	DB.CloseDB()
	ExitApp

;=====================================================================
; GUI event handler
;=====================================================================

Place:
	Gui, Submit, NoHide
	argPlace := Place
	GuiControl, +AltSubmit, Place
	Gui, Submit, NoHide
	argPlacePos :=	Place
	GuiControl, -AltSubmit, Place
	LoadPlace()
	DrawGUI()
	Return

;=====================================================================
; GUI event handler
;=====================================================================

ButtonFirst:
	argPlacePos := 1
	GuiControl, Choose, Place, %argPlacePos%
	Gui, Submit, NoHide
	argPlace := Place
	LoadPlace()
	DrawGUI()
  Return

;=====================================================================
; GUI event handler
;=====================================================================

ButtonPrev:
	argPlacePos := argPlacePos - 1
	if argPlacePos < 1
	{
		argPlacePos := 1
	}
	GuiControl, Choose, Place, %argPlacePos%
	Gui, Submit, NoHide
	argPlace := Place
	LoadPlace()
	DrawGUI()
	Return

;=====================================================================
; GUI event handler
;=====================================================================

ButtonNext:
	argPlacePos := argPlacePos + 1
	if (argPlacePos > argPlaceNum)
	{
		argPlacePos := argPlaceNum
	}
	GuiControl, Choose, Place, %argPlacePos%
	Gui, Submit, NoHide
	argPlace := Place
	LoadPlace()
	DrawGUI()
	Return

;=====================================================================
; GUI event handler
;=====================================================================

ButtonLast:
	argPlacePos := argPlaceNum
	GuiControl, Choose, Place, %argPlacePos%
	Gui, Submit, NoHide
	argPlace := Place
	LoadPlace()
	DrawGUI()
  Return

;=====================================================================
; GUI event handler
;=====================================================================

FilterPlaces:
	Gui, Submit, NoHide
	if ("" . FilterPlaces = "Clear Filter")
	{
		BuildListOfPlaces("")
	}
	else {
		BuildListOfPlaces(FilterPlaces)
	}
	GuiControl, , Place, %ListOfPlaces%
	GuiControl, Choose, Place, 1
	Gui, Submit, NoHide
	argPlace := Place
	LoadPlace()
	DrawGUI()
	Return

;=====================================================================
; GUI event handler
;=====================================================================

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
; GUI event handler
;=====================================================================

;ButtonSelect:
;	FileSelectFile, sOrigName, 3, E:\My Pictures\Originals, Select Original File, Photographs (*.nef; *.jpg)
;	if StrLen(sOrigName) <> 0
;	{
;		NOrigName := sOrigName
;		GuiControl, Text, OrigName, %NOrigName%
;	}
;	Return

;=====================================================================
; GUI event handler
;=====================================================================

;ButtonView:
;	IniRead, ViewerEXE, %A_ScriptDir%\Shropshire Photography.ini, Programs, ImageViewer
;	Run, "%ViewerEXE%" /view "%NOrigName%"
;	Return

;=====================================================================
; GUI event handler
;=====================================================================

;ButtonMove:
;	FileSelectFile, tMoveName, 3, E:\My Pictures\Published\Shropshire, Select File for Item, Photographs (*.jpg)
;	if StrLen(tMoveName) <> 0
;	{
;		tDstFolder := BasePath . "\" . argPlace . "\"
;    FileMove, %tMoveName%, %tDstFolder%, 1
;    MsgBox, 0, Information, File for Item Moved
;	}
;  Return

;=====================================================================
; GUI event handler
;=====================================================================

;ButtonWorkflow:
;	Run, "C:\Program Files\GPSoftware\Directory Opus\dopusrt.exe" /CMD Prefs LAYOUT="Prj - Shropshire"
;	TmpPath := BasePath . "\" . argPlace
;	Sleep, 3000
;	Run, "C:\Program Files\GPSoftware\Directory Opus\dopusrt.exe" /CMD Go "%TmpPath%"
;	Return

;=====================================================================
; GUI event handler
;=====================================================================

ButtonCreateFolder:
	InputBox, newFolder, Create Folder for Item, Enter name for the item's folder:
	If not ErrorLevel
	{
		newFolder := BasePath . "\" . newFolder
		FileCreateDir, %newFolder%
		if ErrorLevel
		{
  		MsgBox, 48, Error, Failed to create folder %newFolder%
		}
  	else
	  {
  		MsgBox, 0, Information, Created folder %newFolder%
	  	Run, "%A_ScriptDir%\Shropshire Photography.exe" "%argOriginal%"
  	}
  }
  Return

;=====================================================================
; GUI event handler
;=====================================================================

ButtonSave:
	Gui, Submit, NoHide
	GuiValues()
	SavePlace()
	if mode = 1
	{
		Run, "%A_ScriptDir%\Shropshire Photography.exe" -status "%argPlace%"
	}
	Return

;=====================================================================
; GUI event handler
;=====================================================================

DisplayStatus() {
	global
	AllPlaces := []
	TmpPath := BasePath . "\*"
	Loop, Files, %TmpPath%, D
	{
		statusOP := """" . A_LoopFileName . """"
	  RecordSet := ""
  	SQL := "SELECT Category1, Category2, Original, DxOPLPreset, DxOPLNotes, AffinityNotes, SilverEfexPreset, SilverEfexNotes, GeneralNotes FROM Place WHERE Name=""" . A_LoopFileName . """;"
	  DB.Query(SQL, RecordSet)
	  placeFound := false
  	Loop {
    	RC := RecordSet.Next(Row)
    	if (RC > 0)
    	{
    		statusOP := statusOP . "," . Row[1]
    		placeFound := true
;    		if (Row[12])
;    		{
;    			statusOP := statusOP . ",Complete"
;    		} else {
;    			statusOP := statusOP . ",In Progress"
;    		}
				statusOP := statusOP . "," . Row[2]
    		statusOP := statusOP . "," . SubStr(Row[3], InStr(Row[3], "\", , -1)+1)
;				TmpNotes := BasePath . "\" . A_LoopFileName . "\*.pdf"
;				if FileExist(TmpNotes)
;				{
;					statusOP := statusOP . ",Has subject notes"
;				} else {
;					statusOP := statusOP . ",None"
;				}
;    		if (Row[11])
;    		{
;    			statusOP := statusOP . ",Has Web Notes"
;    		} else {
;    			statusOP := statusOP . ",None"
;    		}
;    		TmpStrR1 := Row[1]
;    		StringLower, TmpStrR1, TmpStrR1
;    		statusOP := statusOP . "," . CheckThumbnail(TmpStrR1, SubStr(Row[3], InStr(Row[3], "\", , -1)+1))
	    }
  	} Until RC < 1
  	RecordSet.Free()
  	if (!placeFound)
  	{
  		statusOP := statusOP . ",None,Not yet started,"
			TmpNotes := BasePath . "\" . A_LoopFileName . "\*.pdf"
			if FileExist(TmpNotes)
			{
				statusOP := statusOP . ",Has subject notes,None"
			} else {
				statusOP := statusOP . ",None,None"
			}
  	}
		AllPlaces.Push(statusOP)
	}
	Gui, StatusView:Add, ListView, r23 w820, Place|Primary Category|Secondary Category|Original
	Gui, StatusView:Default
	cntH := 0
	cntC := 0
	cntL := 0
	cntO := 0
	cntP := 0
	cntG := 0
	cntI := 0
	cntWH := 0
	cntWL := 0
	cntWO := 0
	cntWI := 0
	cntTH := 0
	cntTL := 0
	cntTO := 0
	cntTI := 0
	for index, element in AllPlaces
	{
		col1 := ""
		col2 := ""
		col3 := ""
		col4 := ""
;		col5 := ""
;		col6 := ""
;		col7 := ""
		Loop, parse, element, CSV
		{
			if A_Index = 1
			{
				col1 := A_LoopField
			}
			if A_Index = 2
			{
				col2 := A_LoopField
			}
			if A_Index = 3
			{
				col3 := A_LoopField
			}
			if A_Index = 4
			{
				col4 := A_LoopField
			}
;			if A_Index = 5
;			{
;				col5 := A_LoopField
;			}
;			if A_Index = 6
;			{
;				col6 := A_LoopField
;			}
;			if A_Index = 7
;			{
;				col7 := A_LoopField
;			}
		}
		if (col2 = "History")
		{
			cntH := cntH + 1
;			if (col5 = "Has Web Notes")
;			{
;				cntWH := cntWH + 1
;			}
;			if (col6 = "Has Thumbnail")
;			{
;				cntTH := cntTH + 1
;			}
		}
		if (col2 = "Church")
		{
			cntC := cntC + 1
		}
		if (col2 = "Landscape")
		{
			cntL := cntL + 1
;			if (col5 = "Has Web Notes")
;			{
;				cntWL := cntWL + 1
;			}
;			if (col6 = "Has Thumbnail")
;			{
;				cntTL := cntTL + 1
;			}
		}
		if (col2 = "Miscellaneous")
		{
			cntO := cntO + 1
;			if (col5 = "Has Web Notes")
;			{
;				cntWO := cntWO + 1
;			}
;			if (col6 = "Has Thumbnail")
;			{
;				cntTO := cntTO + 1
;			}
		}
		if (col2 = "Place")
		{
			cntP := cntP + 1
		}
		if (col2 = "Garden")
		{
			cntG := cntG + 1
		}
		if (col2 = "Information")
		{
			cntI := cntI + 1
;			if (col5 = "Has Web Notes")
;			{
;				cntWI := cntWI + 1
;			}
;			if (col6 = "Has Thumbnail")
;			{
;				cntTI := cntTI + 1
;			}
		}
		LV_Add("", col1, col2, col3, col4)
	}
	LV_ModifyCol()
	Gui, StatusView:Add, Text, xm section w120 h16, History:
	Gui, StatusView:Add, Text, ys vCountH w100 h16,
	Gui, StatusView:Add, Text, ys vWebSiteSH w400 h16,
	GuiControl, StatusView:Text, CountH, %cntH%
;	GuiControl, StatusView:Text, WebSiteSH, Web Site - Web Notes: %cntWH%, Thumbnails: %cntTH%

	Gui, StatusView:Add, Text, xm section w120 h16, Church:
	Gui, StatusView:Add, Text, ys vCountC w100 h16,
	Gui, StatusView:Add, Text, ys vWebSiteSC w400 h16,
	GuiControl, StatusView:Text, CountC, %cntC%

	Gui, StatusView:Add, Text, xm section w120 h16, Landscape:
	Gui, StatusView:Add, Text, ys vCountL w100 h16,
	Gui, StatusView:Add, Text, ys vWebSiteSL w400 h16,
	GuiControl, StatusView:Text, CountL, %cntL%
;	GuiControl, StatusView:Text, WebSiteSL, Web Site - Web Notes: %cntWL%, Thumbnails: %cntTL%

	Gui, StatusView:Add, Text, xm section w120 h16, Miscellaneous:
	Gui, StatusView:Add, Text, ys vCountO w100 h16,
	Gui, StatusView:Add, Text, ys vWebSiteSO w400 h16,
	GuiControl, StatusView:Text, CountO, %cntO%
;	GuiControl, StatusView:Text, WebSiteSO, Web Site - Web Notes: %cntWO%, Thumbnails: %cntTO%

	Gui, StatusView:Add, Text, xm section w120 h16, Place:
	Gui, StatusView:Add, Text, ys vCountP w100 h16,
	Gui, StatusView:Add, Text, ys vWebSiteSP w400 h16,
	GuiControl, StatusView:Text, CountP, %cntP%

	Gui, StatusView:Add, Text, xm section w120 h16, Garden:
	Gui, StatusView:Add, Text, ys vCountG w100 h16,
	Gui, StatusView:Add, Text, ys vWebSiteSG w400 h16,
	GuiControl, StatusView:Text, CountG, %cntG%

	Gui, StatusView:Add, Text, xm section w120 h16, Information:
	Gui, StatusView:Add, Text, ys vCountI w100 h16,
	Gui, StatusView:Add, Text, ys vWebSiteSI w400 h16,
	GuiControl, StatusView:Text, CountI, %cntI%
;	GuiControl, StatusView:Text, WebSiteSI, Web Site - Web Notes: %cntWI%, Thumbnails: %cntTI%

	Gui, StatusView:Add, Button, xm section w50 h20, Close
	Gui, StatusView:Show, w840 h550, Shropshire Photography

	Gui, 1:Default
	Return
}

;---------------------------------------------------------------------
; GUI event handler
;---------------------------------------------------------------------

StatusViewButtonClose:
	Gui, StatusView:Destroy
	Return

;=====================================================================
; GUI event handler
;=====================================================================

;ButtonCompareFolders:
;	CompareListsFolders()
;  Return

;---------------------------------------------------------------------
; Compare list of names in file system with list in database.
;---------------------------------------------------------------------

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

;---------------------------------------------------------------------
; Import folder list into the database
;---------------------------------------------------------------------

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
; GUI event handler
;=====================================================================

;ButtonCompareACDSee:
;	ImportACDSee()
;  Return

;---------------------------------------------------------------------
; 
;---------------------------------------------------------------------

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

;	IniRead, DBFViewerEXE, %A_ScriptDir%\Shropshire Photography.ini, Programs, DatabaseViewer
;	IniRead, SQLite3EXE, %A_ScriptDir%\Shropshire Photography.ini, Programs, SQLite3
;	IniRead, ACDSeeDBPath, %A_ScriptDir%\Shropshire Photography.ini, Paths, ACDSeeDB
;	IniRead, TempPath, %A_ScriptDir%\Shropshire Photography.ini, Paths, TempFolder

;	Progress, R0-9, , Importing ACDSee Data, Database Update

;	RunWait, "%DBFViewerEXE%" "%ACDSeeDBPath%\Category.dbf" /EXPORT:"%TempPath%\ACDSee_Category.csv" /HDR /SKIPD
;  Progress, 1

;	RunWait, "%DBFViewerEXE%" "%ACDSeeDBPath%\JoinCategoryAsset.dbf" /EXPORT:"%TempPath%\ACDSee_JoinCategoryAsset.csv" /HDR /SKIPD
;  Progress, 2

;	RunWait, "%DBFViewerEXE%" "%ACDSeeDBPath%\Asset.dbf" /EXPORT:"%TempPath%\ACDSee_Asset.csv" /HDR /SKIPD
;  Progress, 3

;	RunWait, "%SQLite3EXE%" "%DBFile%" "DROP TABLE IF EXISTS ACDSee_Category;"
;  Progress, 4

;	RunWait, "%SQLite3EXE%" "%DBFile%" "DROP TABLE IF EXISTS ACDSee_JoinCategoryAsset;"
;  Progress, 5

;	RunWait, "%SQLite3EXE%" "%DBFile%" "DROP TABLE IF EXISTS ACDSee_Asset;"
;  Progress, 6

;	RunWait, "%SQLite3EXE%" "%DBFile%" -cmd ".mode csv" ".import '%TempPath%\ACDSee_Category.csv' ACDSee_Category"
;  Progress, 7

;	RunWait, "%SQLite3EXE%" "%DBFile%" -cmd ".mode csv" ".import '%TempPath%\ACDSee_JoinCategoryAsset.csv' ACDSee_JoinCategoryAsset"
;  Progress, 8

;	RunWait, "%SQLite3EXE%" "%DBFile%" -cmd ".mode csv" ".import '%TempPath%\ACDSee_Asset.csv' ACDSee_Asset"
;  Progress, 9

;	Progress, Off

}

;---------------------------------------------------------------------
; GUI event handler
;---------------------------------------------------------------------

DeltaViewButtonClose:
	Gui, DeltaView:Destroy
	Return

;=====================================================================
; GUI event handler
;=====================================================================

ButtonCancel:
	DB.CloseDB()
	ExitApp

;=====================================================================
; Build the list of Places from the folders in the project folder.
;=====================================================================

BuildListOfPlaces(pFilter)
{
	global
	TmpPath := BasePath . "\*"
	ListOfPlaces := "|"
	argPlaceNum := 0
	Loop, Files, %TmpPath%, D
	{
		if StrLen(argPlace) = 0
		{
			argPlace := A_LoopFileName
		}
		PlaceExists := False
		if StrLen(pFilter) > 0
		{
			RecordSet := ""
  		SQL := "SELECT COUNT(*) FROM Place WHERE Name=""" . A_LoopFileName . """ AND (Category1=""" . pFilter . """ OR Category2=""" . pFilter . """);"
  		DB.Query(SQL, RecordSet)
		  Loop {
    		RC := RecordSet.Next(Row)
    		if (RC > 0) {
      		if (Row[1] = "1") {
        		PlaceExists := True
      		}
		    }
		  } Until RC < 1
  		RecordSet.Free()
		}
		else
		{
	 		PlaceExists := True
		}
		if PlaceExists
		{
			if StrLen(ListOfPlaces) > 1
			{
				ListOfPlaces := ListOfPlaces . "|"
			}
			ListOfPlaces := ListOfPlaces . A_LoopFileName
			argPlaceNum := argPlaceNum + 1
		}
	}
	SB_SetText("Number of Places: " . argPlaceNum)
}

;=====================================================================
; Draw the GUI, which varies depending on which mode the script
; is operating in.
;=====================================================================

DrawGUI()
{
	global
	if mode = 0
	{
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
		GuiControl, Text, AffinityNotes, %NAffinityNotes%
;		GuiControl, Text, PClearNotes, %NPClearNotes%
		GuiControl, ChooseString, DxOSEPreset, %NDxOSEPreset%
		GuiControl, Text, SilverEfexNotes, %NSilverEfexNotes%
;		GuiControl, , SubjectNotes, %NSubjectNotes%
;		GuiControl, , WebNotes, %NWebNotes%
;		GuiControl, , Complete, %NComplete%
		if NHasFile
		{
;			GuiControl, Text, HasFile, Has Database Record
			SB_SetText("Has Database Record", 2)
		} else {
;			GuiControl, Text, HasFile, No Database Record
			SB_SetText("No Database Record", 2)
		}
		GuiControl, Text, Overview, %NOverview%
	}
	if mode = 1
	{
		NOrigName := argOriginal
		GuiControl, Text, OrigName, %NOrigName%
	}
}

;=====================================================================
; Retrieve the latest values from the GUI.
;=====================================================================

GUIValues()
{
	global
	if mode = 0
	{
		NCategory1 := Category1
		NCategory2 := Category2
		NDxOPLPreset := DxOPLPreset
		NDxOPLNotes := DxOPLNotes
		NAffinityNotes := AffinityNotes
;		NPClearNotes := PClearNotes
		NDxOSEPreset := DxOSEPreset
		NSilverEfexNotes := SilverEfexNotes
;		NSubjectNotes := SubjectNotes
;		NWebNotes := WebNotes
;		NComplete := Complete
		NOverview := Overview
	}
}

;=====================================================================
; 
;=====================================================================

CheckThumbnail(pFolder, pName) {
	global
	sThumb := "None"
	sName := SubStr(pName, 1, StrLen(pName)-4)
	sName := sName . "*.jpg"
	sName := "C:\Users\David\Documents\Google Drive\GitHub\dmfbsh.github.io\assets\images\" . pFolder . "\" . sName
	if FileExist(sName)
	{
		sThumb := "Has Thumbnail"
	}
	return sThumb
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

;=====================================================================
; Save a place to the database.
;=====================================================================

SavePlace() {
  global
  RecordSet := ""
  PlaceExists := False
  SQL := "SELECT Count(*) FROM Place WHERE Name=""" . argPlace . """;"
  DB.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0) {
      if (Row[1] = "1") {
        PlaceExists := True
      }
    }
  } Until RC < 1
  RecordSet.Free()
  if (PlaceExists) {
    SQL := "UPDATE Place SET "
    SQL := SQL . "Category1=""" . NCategory1 . """, "
    SQL := SQL . "Category2=""" . NCategory2 . """, "
    SQL := SQL . "Original=""" . NOrigName . """, "
    SQL := SQL . "OrigName=""" . SubStr(NOrigName, InStr(NOrigName, "\", false, -1)+1) . """, "
    SQL := SQL . "DxOPLPreset=""" . NDxOPLPreset . """, "
    SQL := SQL . "DxOPLNotes=""" . StringToDB(NDxOPLNotes) . """, "
    SQL := SQL . "AffinityNotes=""" . StringToDB(NAffinityNotes) . """, "
;    SQL := SQL . "PerfectlyClearNotes=""" . StringToDB(NPClearNotes) . """, "
    SQL := SQL . "SilverEfexPreset=""" . NDxOSEPreset . """, "
    SQL := SQL . "SilverEfexNotes=""" . StringToDB(NSilverEfexNotes) . """, "
    SQL := SQL . "GeneralNotes=""" . StringToDB(NOverview) . """ "
;    SQL := SQL . "TickSubjectNotes=" . NSubjectNotes . ", "
;    SQL := SQL . "TickWebNotes=" . NWebNotes . ", "
;    SQL := SQL . "TickComplete=" . NComplete . " "
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
    SQL := SQL . """" . StringToDB(NAffinityNotes) . """, "
;    SQL := SQL . """" . StringToDB(NPClearNotes) . """, "
    SQL := SQL . """" . NDxOSEPreset . """, "
    SQL := SQL . """" . StringToDB(NSilverEfexNotes) . """, "
    SQL := SQL . """" . StringToDB(NOverview) . """ "
;    SQL := SQL . NSubjectNotes . ", "
;    SQL := SQL . NWebNotes . ", "
;    SQL := SQL . NComplete . " "
    SQL := SQL . ");"
  }
  DB.Exec(SQL)
}

;=====================================================================
; Load a place from the database.
;=====================================================================

LoadPlace() {
  global
	NCategory1 := "History"
	NCategory2 := "N/A"
	NOrigName := "Not yet defined"
	NDxOPLPreset := "1 - DxO Standard"
	NDxOPLNotes := ""
	NAffinityNotes := ""
;	NPClearNotes := ""
	NDxOSEPreset := "DxO Silver Efex Not Used"
	NSilverEfexNotes := ""
;	if FileExist(BasePath . "\" . argPlace . "\*.pdf")
;	{
;		NSubjectNotes := true
;	} else {
;		NSubjectNotes := false
;	}
	NOverview := ""
;	NWebNotes := false
;	NComplete := false
	NHasFile := false
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
			NAffinityNotes := StringFromDB(Row[6])
;			NPClearNotes := StringFromDB(Row[7])
			NDxOSEPreset := Row[7]
			NSilverEfexNotes := StringFromDB(Row[8])
			NOverview := StringFromDB(Row[9])
;			NWebNotes := Row[11]
;			NComplete := Row[12]
			NHasFile := true
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
; GUI event handler
;=====================================================================

;ButtonCompareTrello:
;	CompareListsTrello()
;  Return

;=====================================================================
; 
;=====================================================================

;ImportTrello() {
;	global
;  ; WshShell object: http://msdn.microsoft.com/en-us/library/aew9yb99
;  shell := ComObjCreate("WScript.Shell")
;  ; Execute a single command via cmd.exe
;  cmd := """""C:\Program Files\cURL\bin\curl.exe"" ""https://api.trello.com/1/lists/5d14780cfd0f3e534aa1df68/cards?fields=name&key=9ffaa9fbca828239fcb4034ee4e524b7&token=905e27f47d66cac8ffc9bb046924bf8e52c5f7c0780224fe466633d02e91bdf7"""""
;  exec := shell.Exec("cmd.exe" " /C " cmd)
;  ; Read and return the command's output
;  oup := exec.StdOut.ReadAll()
;  MsgBox %oup%
;	SQL := "DELETE FROM Trello_Places;"
;  DB.Exec(SQL)
;  jsonend := false
;  nextpos := 1
;  arrylvl := 0
;  Loop {
;  	token := SubStr(oup, nextpos, 1)
;  	if (token = "[")
;  	{
;  		arrylvl := arrylvl + 1
;  		nextpos := nextpos + 1
;  	}
;    else if (token = "{")
;    {
;  		nextpos := nextpos + 1
;    }
;    else if (token = """")
;    {
;    	strend := InStr(oup, """", false, nextpos + 1)
;    	stritm := SubStr(oup, nextpos + 1, strend - (nextpos + 1))
;    	nextpos := strend + 1
;    }
;    else if (token = ":")
;    {
;  		nextpos := nextpos + 1
;    }
;    else if (token = ",")
;    {
;  		nextpos := nextpos + 1
;    }
;    else if (token = "}")
;    {
;  		nextpos := nextpos + 1
;    }
;    else if (token = "]")
;    {
;    	arrylvl := arrylvl - 1
;    	if (arrylvl = 0)
;    	{
;    		jsonend := true
;    	}
;  		nextpos := nextpos + 1
;    }
;  } Until jsonend
;}

;=====================================================================
; 
;=====================================================================

;CompareListsTrello() {
;	global
;	SQL := "DELETE FROM Trello_Places;"
;  DB.Exec(SQL)
;	cmd := """C:\Program Files\cURL\bin\curl.exe"" ""https://api.trello.com/1/lists/5d14780cfd0f3e534aa1df68/cards?fields=name&key=9ffaa9fbca828239fcb4034ee4e524b7&token=905e27f47d66cac8ffc9bb046924bf8e52c5f7c0780224fe466633d02e91bdf7"" -o ""C:\Users\David\Documents\Google Drive\3. Shropshire\Temp\Trello-Places.json"""
;  RunWait, %cmd%
;  cmd := "powershell ""(Get-Content -Path 'C:\Users\David\Documents\Google Drive\3. Shropshire\Temp\Trello-Places.json' | ConvertFrom-Json) | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1 | Set-Content 'C:\Users\David\Documents\Google Drive\3. Shropshire\Temp\Trello-Places.csv'"""
;  RunWait, %cmd%
;  FileDelete, C:\Users\David\Documents\Google Drive\3. Shropshire\Temp\Trello-Places.txt
;	TmpCnt := 0
;  Loop, read, C:\Users\David\Documents\Google Drive\3. Shropshire\Temp\Trello-Places.csv, C:\Users\David\Documents\Google Drive\3. Shropshire\Temp\Trello-Places.txt
;  {
;  	TmpCnt := TmpCnt + 1
;  }
;	Progress, R0-%TmpCnt%, , Listing cards in Trello, Compare Database and Trello
;	TmpCnt := 0
;  Loop, read, C:\Users\David\Documents\Google Drive\3. Shropshire\Temp\Trello-Places.csv, C:\Users\David\Documents\Google Drive\3. Shropshire\Temp\Trello-Places.txt
;  {
;  	Loop, parse, A_LoopReadLine, CSV
;  	{
;  		if A_Index = 2
;  		{
;				SQL := "INSERT INTO Trello_Places (Name) VALUES (""" . A_LoopField . """);"
;	  		DB.Exec(SQL)
;  		}
;  	}
;		TmpCnt := TmpCnt + 1
;	  Progress, %TmpCnt%
;  }
;	Progress, Off
;	NotInDB := ""
;	NotInFS := "" 
;  RecordSet := ""
;	SQL := "SELECT Name FROM Trello_Places WHERE Name NOT IN (SELECT Name FROM Place);"
;  DB.Query(SQL, RecordSet)
;  Loop {
;    RC := RecordSet.Next(Row)
;    if (RC > 0) {
;    	if (StrLen(NotInDB) <> 0) {
;    		NotInDB := NotInDB . ", "
;    	}
;    	NotInDB := NotInDB . Row[1]
;    }
;  } Until RC < 1
;  RecordSet.Free()
;  RecordSet := ""
;	SQL := "SELECT Name FROM Place WHERE Name NOT IN (SELECT Name FROM Trello_Places);"
;  DB.Query(SQL, RecordSet)
;  Loop {
;    RC := RecordSet.Next(Row)
;    if (RC > 0) {
;    	if (StrLen(NotInFS) <> 0) {
;    		NotInFS := NotInFS . ", "
;    	}
;    	NotInFS := NotInFS . Row[1]
;    }
;  } Until RC < 1
;  RecordSet.Free()
;  if (StrLen(NotInDB) <> 0) {
;  	MsgBox The following are not in the database: %NotInDB%
;  }
;  if (StrLen(NotInFS) <> 0) {
;  	MsgBox The following are not in Trello: %NotInFS%
;  }
;  if (StrLen(NotInDB) == 0 and StrLen(NotInFS) == 0) {
;  	MsgBox The database and Trello are in sync.
;  }
;}

;=====================================================================
; 
;=====================================================================

;TrelloBulkLoadPlaces() {
;	global
;	TmpPath := BasePath . "\*"
;	cnt := 0
;	Loop, Files, %TmpPath%, D
;	{
;		cnt := cnt + 1
;		cmd := """C:\Program Files\cURL\bin\curl.exe"" --request POST --url ""https://api.trello.com/1/cards?idList=5d14780cfd0f3e534aa1df68&keepFromSource=all&name=" . StrReplace(StrReplace(A_LoopFileName, " ", "%20"), "'", "%27") . "&key=9ffaa9fbca828239fcb4034ee4e524b7&token=905e27f47d66cac8ffc9bb046924bf8e52c5f7c0780224fe466633d02e91bdf7"""
;    RunWait, %cmd%
;	}
;}
