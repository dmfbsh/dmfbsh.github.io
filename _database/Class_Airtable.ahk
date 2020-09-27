Class Airtable {

__New() {
	
}

__Delete() {
	
}

_outputJSON := ""

_curl := """C:\Program Files\cURL\bin\curl.exe"""
_url  := "https://api.airtable.com/v0/"
_base := "appgZEbIUl9Qek5Qu"
_key  := "Bearer key9hVEwGXLr71fSf"

SetTmpJSONFile(pFile) {
	This._outputJSON := pFile
}

List(pTable, pOffset) {
  cmd := This._curl . " "
  cmd .= This._url . This._base . "/" . pTable . "?pageSize=20&view=Grid%20view"
  if pOffset <>
  {
    cmd .= "&offset=" . pOffset
  }
  cmd .= " -H ""Authorization: " . This._key . """"
  cmd .= " -o """ . This._outputJSON . """"
  RunWait, %cmd%, , Hide
  f := This._outputJSON
  FileRead, retJSON, %f%
  retJSON := StrReplace(retJSON, "\n", "`n")
  retJSON := StrReplace(retJSON, "\r", "`r")
  return %retJSON%
}

Insert(pTable, pData) {
  cmd := This._curl . " -v -X POST "
  cmd .= This._url . This._base . "/" . pTable
  cmd .= " -H ""Authorization: " . This._key . """"
  cmd .= " -H ""Content-Type: application/json"""
  cmd .= " --data """ . pData . """"
  cmd .= " -o """ . This._outputJSON . """"
  RunWait, %cmd%, , Hide
  return This.GetIDFromJSON()
}

Update(pTable, pData) {
  cmd := This._curl . " -v -X PATCH "
  cmd .= This._url . This._base . "/" . pTable
  cmd .= " -H ""Authorization: " . This._key . """"
  cmd .= " -H ""Content-Type: application/json"""
  cmd .= " --data """ . pData . """"
  cmd .= " -o """ . This._outputJSON . """"
  RunWait, %cmd%, , Hide
}

Delete(pTable, pData) {
}

Select(pTable, pRec) {
  cmd := This._curl . " "
  cmd .= This._url . This._base . "/" . pTable . "/" . pRec
  cmd .= " -H ""Authorization: " . This._key . """"
  cmd .= " -o """ . This._outputJSON . """"
  RunWait, %cmd%, , Hide
  f := This._outputJSON
  FileRead, retJSON, %f%
  retJSON := StrReplace(retJSON, "\n", "`n")
  retJSON := StrReplace(retJSON, "\r", "`r")
  return %retJSON%
}

CreateJSONData(pData, pID) {
  retJSON := ""
  for k, v in pData {
    if retJSON <>
    {
        retJSON .= ", "
    }
    retJSON .= "\"""
    retJSON .= k
    retJSON .= "\"""
    retJSON .= ": "
    if k = Need to Revisit
      if v = 0
        retJSON .= "false"
      else
        retJSON .= "true"
    else if k = Is on Map
      if v = 0
        retJSON .= "false"
      else
        retJSON .= "true"
    else if k = Is on TPE
      if v = 0
        retJSON .= "false"
      else
        retJSON .= "true"
    else if k = Visited
      if v = 0
        retJSON .= "false"
      else
        retJSON .= "true"
    else
    {
      retJSON .= "\"""
      retJSON .= v
      retJSON .= "\"""
    }
  }
  if pID <>
  {
    retJSON := "{\""records\"": [{\""id\"": \""" . pID . "\"", \""fields\"": {" . retJSON . "}}]}"
  }
  else
  {
    retJSON := "{\""records\"": [{\""fields\"": {" . retJSON . "}}]}"
  }
  retJSON := StrReplace(retJSON, "`r", "\r")
  retJSON := StrReplace(retJSON, "`n", "\n")
  return retJSON
}

GetIDFromJSON() {
  tmpJSON := This._outputJSON
  FileRead, retJSON, %tmpJSON%
  retJSON := StrReplace(retJSON, " ", "")
  idIdx := InStr(retJSON, """id""")
  retJSON := SubStr(retJSON, idIdx + 6)
  idIdx := InStr(retJSON, """")
  return SubStr(retJSON, 1, idIdx - 1)
}

}