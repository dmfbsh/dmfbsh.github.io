Class KMLFile {

__New() {
	
}

__Delete() {
	
}

_fileName := ""
_fileHndl := ""

OpenKMLFile(pKMLFile) {
	This._fileName := pKMLFile
	This._fileHndl := FileOpen(pKMLFile, "r")
;	foundPlacemark := false
;	nextLine := Trim(This._fileHndl.ReadLine(), OmitChars := " `t`n`r")
;	while (!This._fileHndl.AtEOF and !foundPlacemark)
;	{
;	  if (nextLine == "<Placemark>")
;	  {
;	  	foundPlacemark := true
;	  }
;	  else
;	  {
;	    nextLine := Trim(This._fileHndl.ReadLine(), OmitChars := " `t`n`r")
;	  }
;	}
}

CloseKMLFile() {
	This._fileHndl.Close()
}

GetNextPlacemarkName() {
	foundPlacemark := false
	foundName := false
	retName := "END_OF_FILE"
  nextLine := Trim(This._fileHndl.ReadLine(), OmitChars := " `t`n`r")
	while (!This._fileHndl.AtEOF and !foundName)
	{
		if (InStr(nextLine, "<placemark>"))
		{
			foundPlacemark := true
	    nextLine := Trim(This._fileHndl.ReadLine(), OmitChars := " `t`n`r")
		}
	  else if (InStr(nextLine, "<name>") and foundPlacemark)
	  {
	  	foundName := true
	  	retName := nextLine
	  	retName := StrReplace(retName, "<name>", "")
	  	retName := StrReplace(retName, "</name>", "")
	  	retName := StrReplace(retName, "<![CDATA[", "")
	  	retName := StrReplace(retName, "]]>", "")
	  }
	  else
  	{
	    nextLine := Trim(This._fileHndl.ReadLine(), OmitChars := " `t`n`r")
	  }
	}
  Return retName
}

GetNextPlacemarkCoords() {
	foundPlacemark := false
	retName := "END_OF_FILE"
  nextLine := Trim(This._fileHndl.ReadLine(), OmitChars := " `t`n`r")
	while (!This._fileHndl.AtEOF and !foundPlacemark)
	{
	  if (InStr(nextLine, "<coordinates>"))
	  {
	  	foundPlacemark := true
	    nextLine := Trim(This._fileHndl.ReadLine(), OmitChars := " `t`n`r")
	    gNewPos  := StrSplit(nextLine, [","])
	    gNewLat  := Trim(gNewPos[2])
	    gNewLong := Trim(gNewPos[1])
	    retName  := gNewLat . "," . gNewLong
	  }
	  else
  	{
	    nextLine := Trim(This._fileHndl.ReadLine(), OmitChars := " `t`n`r")
	  }
	}
  Return retName
}

}