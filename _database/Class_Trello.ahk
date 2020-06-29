Class Trello {

__New() {
	
}

__Delete() {
	
}

_outputJSON := ""

_curl  := """C:\Program Files\cURL\bin\curl.exe"""
_key   := "key=9ffaa9fbca828239fcb4034ee4e524b7"
_token := "token=905e27f47d66cac8ffc9bb046924bf8e52c5f7c0780224fe466633d02e91bdf7"
_url   := "https://api.trello.com/1/"

SetTmpJSONFile(pFile) {
	This._outputJSON := pFile
}

CreateCard(pListID, pCardName) {
	tCardName := StrReplace(pCardName, " ", "%20")
	tCardName := StrReplace(tCardName, "'", "%27")
	tCardName := StrReplace(tCardName, """", "%22")
  cmd := This._curl . " --request POST "
  cmd := cmd . """" . This._url . "cards" . "?" . This._key . "&" . This._token . "&idList=" . pListID . "&name=" . tCardName . """ -o """ . This._outputJSON . """"
  RunWait, %cmd%, , Hide
  tmpJSON := This._outputJSON
  FileRead, retJSON, %tmpJSON%
  return SubStr(retJSON, 8, 24)
}

DeleteCard(pCardID) {
  cmd := This._curl . " --request DELETE "
  cmd := cmd . """" . This._url . "cards/" . pCardID . "?" . This._key . "&" . This._token . """"
  RunWait, %cmd%, , Hide
}

UpdateCard(pCardID, pWhat) {
	tWhat := StrReplace(pWhat, " ", "%20")
	tWhat := StrReplace(tWhat, "'", "%27")
	tWhat := StrReplace(tWhat, """", "%22")
	tWhat := StrReplace(tWhat, "`r", "%0D")
	tWhat := StrReplace(tWhat, "`n", "%0A")
  cmd := This._curl . " --request PUT "
  cmd := cmd . """" . This._url . "cards/" . pCardID . "?" . This._key . "&" . This._token . "&" . tWhat . """"
  RunWait, %cmd%, , Hide
}

GetField(pCommand) {
	global
	cmd := This._curl
	cmd := cmd . " """ . This._url . pCommand . "?" . This._key . "&" . This._token . """ -o """ . This._outputJSON . """"
  RunWait, %cmd%, , Hide
  tmpJSON := This._outputJSON
  FileRead, retJSON, %tmpJSON%
  retJSON := SubStr(retJSON, 12, StrLen(retJSON)-14)
  retJSON := StrReplace(retJSON, "\""", """")
  retJSON := StrReplace(retJSON, "\n", "`n")
  Return retJSON
}

AddURLAttachmentToCard(pCardID, pHREF) {
  cmd := This._curl . " --request POST "
  cmd := cmd . """" . This._url . "cards/" . pCardID . "/attachments" . "?" . This._key . "&" . This._token . "&url=" . pHREF . """ -o """ . This._outputJSON . """"
  RunWait, %cmd%, , Hide
  tmpJSON := This._outputJSON
  FileRead, retJSON, %tmpJSON%
  return SubStr(retJSON, 8, 24)
}

DeleteURLAttachmentFromCard(pCardID, pAttID) {
	cmd := This._curl . " --request DELETE "
	cmd := cmd . """" . This._url . "cards/" . pCardID . "/attachments/" . pAttID . "?" . This._key . "&" . This._token . """"
  RunWait, %cmd%, , Hide
}

AddLabelToCard(pCardID, pLabelID) {
  cmd := This._curl . " --request POST "
  cmd := cmd . """" . This._url . "cards/" . pCardID . "/idLabels" . "?" . This._key . "&" . This._token . "&value=" . pLabelID . """"
  RunWait, %cmd%, , Hide
}

RemoveLabelFromCard(pCardID, pLabelID) {
	cmd := This._curl . " --request DELETE "
	cmd := cmd . """" . This._url . "cards/" . pCardID . "/idLabels/" . pLabelID . "?" . This._key . "&" . This._token . """"
  RunWait, %cmd%, , Hide
}

RunCommand(pCommand) {
  cmd := This._curl . " """ . This._url . pCommand . "&" . This._key . "&" . This._token . """ -o """ . This._outputJSON . """"
  RunWait, %cmd%, , Hide
}

ConvertJSONToCSV(pName) {
  cmd := "powershell ""(Get-Content -Path '" . This._outputJSON . "' | ConvertFrom-Json) | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1 | Set-Content '" . pName . "'"""
  RunWait, %cmd%, , Hide
}

GetBoardID(pName, pCSV) {
  This.RunCommand("members/me/boards?fields=name")
  This.ConvertJSONToCSV(pCSV)

  FoundIt := false
  BoardID := ""

  Loop, read, %pCSV%
  {
    Loop, parse, A_LoopReadLine, CSV
    {
      if FoundIt
      {
      	BoardID := A_LoopField
      	FoundIt := false
      }
    	if A_LoopField = %pName%
    	{
    		FoundIt := true
    	}
    }
  }
  Return BoardID
}

}
