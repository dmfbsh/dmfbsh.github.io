Class GoogleMyMaps {

_curl := """C:\Program Files\cURL\bin\curl.exe"""
_url  := "https://www.google.co.uk/maps/d/"

_output := "C:\Users\David\Documents\OneDrive\Documents\My Documents\GitHub\dmfbsh.github.io\_maps\"

; The edit link is the URL from the browser when the map is being edited
; the URL is the download link (. . . menu in the downloads bar for the item)

_hillsEdit := "edit?mid=1zqg1D_aaTgOnFeaBK8vTfcQiwa52LGdK&ll=52.53616149173001%2C-2.7138529111293703&z=9"
_hillsURL  := "kml?mid=1zqg1D_aaTgOnFeaBK8vTfcQiwa52LGdK&forcekml=1&cid=mp&cv=j24ckcMxwag.en_GB."
_hillsDown := "Hills-Download.kml"
_hillsConv := "Shropshire - Hills.kml"

_placesEdit := "edit?mid=1SfcLMvl0UasOPW3m0_hx7D8Cdll1mNrt&ll=52.72552409553642%2C-2.9713259323237695&z=9"
_placesURL  := "kml?mid=1SfcLMvl0UasOPW3m0_hx7D8Cdll1mNrt&forcekml=1&cid=mp&cv=j24ckcMxwag.en_GB."
_placesDown := "Places-Download.kml"
_placesConv := "Shropshire - Places.kml"

_churchesNEdit := "edit?mid=129Y_cZQyAUwAwyFNFb-jWPcMyX8aBOPZ&ll=52.785663408194466%2C-2.8309019273461833&z=10"
_churchesNURL  := "kml?mid=129Y_cZQyAUwAwyFNFb-jWPcMyX8aBOPZ&forcekml=1&cid=mp&cv=j24ckcMxwag.en_GB."
_churchesNDown := "North-Download.kml"
_churchesNConv := "Shropshire - Churches - North.kml"

_churchesSEdit := "edit?mid=1UBGi054_OErBBCFvxLHzmffegbrRhGFx&ll=52.52317377704205%2C-2.8415294943172187&z=10"
_churchesSURL  := "kml?mid=1UBGi054_OErBBCFvxLHzmffegbrRhGFx&forcekml=1&cid=mp&cv=j24ckcMxwag.en_GB."
_churchesSDown := "South-Download.kml"
_churchesSConv := "Shropshire - Churches - South.kml"

_castlesEdit := "edit?mid=1Z-t4uPsodgBWqsR6SZCLVMP1tgJzqqxA&ll=52.63293715988746%2C-2.844756253910181&z=9"
_castleURL := "kml?mid=1Z-t4uPsodgBWqsR6SZCLVMP1tgJzqqxA&forcekml=1&cid=mp&cv=foVtPLVBE9w.en_GB."

_townsEdit := "edit?mid=1hhRXp1O-DsQmCZnQFLZLihmtDXU6PAoS&ll=52.61264471250733%2C-2.7860685109244594&z=9"
_townsURL := "kml?mid=1hhRXp1O-DsQmCZnQFLZLihmtDXU6PAoS&forcekml=1&cid=mp&cv=foVtPLVBE9w.en_GB."

__New() {
	
}

__Delete() {
	
}

OpenHills() {
  cmd := """" . This._url . This._hillsEdit . """"
  Run, %cmd%, Hide
}

OpenPlaces() {
  cmd := """" . This._url . This._placesEdit . """"
  Run, %cmd%, Hide
}

OpenChurches() {
  cmd := """" . This._url . This._churchesNEdit . """"
  Run, %cmd%, Hide
  cmd := """" . This._url . This._churchesSEdit . """"
  Run, %cmd%, Hide
}

DownloadHills() {
  cmd := This._curl . " "
  cmd .= This._url . This._hillsURL . " "
  cmd .= "-o """ . This._output . This._hillsDown . """"
  RunWait, %cmd%, , Hide
  This.__ConvertCRLF(This._hillsDown, This._hillsConv)
}

DownloadPlaces() {
  cmd := This._curl . " "
  cmd .= This._url . This._placesURL . " "
  cmd .= "-o """ . This._output . This._placesDown . """"
  RunWait, %cmd%, , Hide
  This.__ConvertCRLF(This._placesDown, This._placesConv)
}

DownloadChurches() {
  cmd := This._curl . " "
  cmd .= This._url . This._churchesNURL . " "
  cmd .= "-o """ . This._output . This._churchesNDown . """"
  RunWait, %cmd%, , Hide
  This.__ConvertCRLF(This._churchesNDown, This._churchesNConv)
  cmd := This._curl . " "
  cmd .= This._url . This._churchesSURL . " "
  cmd .= "-o """ . This._output . This._churchesSDown . """"
  RunWait, %cmd%, , Hide
  This.__ConvertCRLF(This._churchesSDown, This._churchesSConv)
}

__ConvertCRLF(pDown, pConv) {
  down := This._output . pDown
  conv := This._output . pConv
  FileRead, xmlData, %down%
  xmlData := StrReplace(xmlData, "`n", "`r`n")
  FileDelete, %conv%
  FileAppend, %xmlData%, %conv%
  FileDelete, %down%
}

}
