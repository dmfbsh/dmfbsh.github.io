Class JSON {

__New() {
	
}

__Delete() {
	
}

_sourceJSON    := ""
_remainingJSON := ""


SetJSON(pJSON) {
  This._sourceJSON    := pJSON
  This._remainingJSON := pJSON
}

GetNextItem() {
  a := 0
  b := ""
  if (SubStr(This._remainingJSON, 1, 1) == "[")
  {
    b := "#StartArray"
    This._remainingJSON := SubStr(This._remainingJSON, 2)
  }
  else if (SubStr(This._remainingJSON, 1, 1) == "{")
  {
    b := "#StartObject"
    This._remainingJSON := SubStr(This._remainingJSON, 2)
  }
  else if (SubStr(This._remainingJSON, 1, 1) == ":")
  {
    b := "#KeyValue"
    This._remainingJSON := SubStr(This._remainingJSON, 2)
  }
  else if (SubStr(This._remainingJSON, 1, 1) == ",")
  {
    b := "#NextPair"
    This._remainingJSON := SubStr(This._remainingJSON, 2)
  }
  else if (SubStr(This._remainingJSON, 1, 1) == "}")
  {
    b := "#EndObject"
    This._remainingJSON := SubStr(This._remainingJSON, 2)
  }
  else if (SubStr(This._remainingJSON, 1, 1) == "]")
  {
    b := "#EndArray"
    This._remainingJSON := SubStr(This._remainingJSON, 2)
  }
  else if InStr(This._remainingJSON, """") == 1
  {
  	This._remainingJSON := SubStr(This._remainingJSON, 2)
    a := RegExMatch(This._remainingJSON, "((?<![\\])[""])")
    b := SubStr(This._remainingJSON, 1, a-1)
  	This._remainingJSON := SubStr(This._remainingJSON, a+1)
  }
  else
  {
    a := RegExMatch(This._remainingJSON, "[,}]")
    b := SubStr(This._remainingJSON, 1, a-1)
  	This._remainingJSON := SubStr(This._remainingJSON, a)
  }
  b := StrReplace(b, "\n", "`n")
  b := StrReplace(b, "\r", "`r")
  b := StrReplace(b, "\\", "\")
  b := StrReplace(b, "\""", """")
  Return b
}

GetNextObjectValue() {
	k := This.GetNextItem()
	if k = #EndObject
	{
	  return "#EndObject"
	}
	if k = #StartObject
	{
		k := This.GetNextItem()
	}
	if k = #NextPair
	{
		k := This.GetNextItem()
	}
  s := This.GetNextItem()
  v := This.GetNextItem()
  return v
}

}
