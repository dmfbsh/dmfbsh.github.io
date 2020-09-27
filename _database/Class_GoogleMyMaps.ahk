Class GoogleMyMaps {

_curl := """C:\Program Files\cURL\bin\curl.exe"""
_url  := "https://www.google.co.uk/maps/d/"

_output := "C:\Users\David\Documents\OneDrive\Documents\My Documents\GitHub\dmfbsh.github.io\_maps\"

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

Downloadlaces() {
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
