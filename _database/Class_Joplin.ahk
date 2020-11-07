Class Joplin {

__New() {
	
}

__Delete() {
	
}

SelectChurch(pPlace, pDedication) {
  ret := ""
  DBJ := new SQLiteDB
  DBJ.OpenDB("C:\Users\David\Documents\OneDrive\Documents\My Documents\0. Admin\joplin-desktop\database.sqlite")
  SQL := "SELECT body FROM notes WHERE title = """ . pPlace . " - " . pDedication . """;"
  DBJ.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0) {
      val := Row[1]
    }
  } Until RC < 1
  RecordSet.Free()
  DBJ.CloseDB()
  val := StrReplace(val, "`n", "^")
  val := StrReplace(val, "`r", "")
  vas := StrSplit(val, "^")
  ret := {}
  detl := ""
  note := ""
  pics := ""
  maps := ""
  dodetl := false
  donote := false
  dopics := false
  domaps := false
  Loop % vas.MaxIndex()
  {
    var := vas[A_Index]
    if A_Index = 1
        ret["Status"] := Trim(SubStr(var, 10))
    else if A_Index = 2
        ret["Date"] := Trim(SubStr(var, 8))
    else if A_Index = 3
        ret["Revisit"] := Trim(SubStr(var, 19))
    else if A_Index = 4
        ret["Dates Visited"] := Trim(SubStr(var, 17))
    else if A_Index = 5
        ret["Area"] := Trim(SubStr(var, 8))
    else if var = ## Details
      dodetl := true
    else if var = ## Notes
      donote := true
    else if var = ## Pictures
      dopics := true
    else if var = ## Map
      domaps := true
    else if var = * * *
    {
        dodetl := false
        donote := false
        dopics := false
        domaps := false
    }
    else if (dodetl)
      detl .= var . "`n"
    else if (donote)
      note .= var . "`n"
    else if (dopics)
      pics .= var . "`n"
    else if (domaps)
      maps .= var . "`n"
  }
  ret["Details"] := Trim(detl, OmitChars := "`n")
  ret["Notes"] := Trim(note, OmitChars := "`n")
  ret["Pictures"] := Trim(pics, OmitChars := "`n")
  ret["Map"] := Trim(maps, OmitChars := "`n")
  return %ret%
}

SaveChurch(pPlace, pDedication, pValues) {
  DBJ := new SQLiteDB
  DBJ.OpenDB("C:\Users\David\Documents\OneDrive\Documents\My Documents\0. Admin\joplin-desktop\database.sqlite")
  uT := This.GetUNIXEpoch()
  SQL := "UPDATE notes SET updated_time = " . uT . ", user_updated_time = " . uT . ", body = """ . pValues . """ WHERE title = """ . pPlace . " - " . pDedication . """;"
  DBJ.Exec(SQL)
  DBJ.CloseDB()
}

ListHills() {
  idh := ""
  ret := []
  DBJ := new SQLiteDB
  DBJ.OpenDB("C:\Users\David\Documents\OneDrive\Documents\My Documents\0. Admin\joplin-desktop\database.sqlite")
  SQL := "SELECT id FROM folders WHERE title = 'Hills';"
  DBJ.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0) {
      idh := Row[1]
    }
  } Until RC < 1
  RecordSet.Free()
  SQL := "SELECT title FROM notes WHERE parent_id = '" . idh . "';"
  DBJ.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0) {
      ret.Push(Row[1])
    }
  } Until RC < 1
  RecordSet.Free()
  DBJ.CloseDB()
  return ret
}

SelectHill(pHill) {
  ret := ""
  DBJ := new SQLiteDB
  DBJ.OpenDB("C:\Users\David\Documents\OneDrive\Documents\My Documents\0. Admin\joplin-desktop\database.sqlite")
  SQL := "SELECT body FROM notes WHERE title = """ . pHill . """;"
  DBJ.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0) {
      val := Row[1]
    }
  } Until RC < 1
  RecordSet.Free()
  DBJ.CloseDB()
  val := StrReplace(val, "`n", "^")
  val := StrReplace(val, "`r", "")
  vas := StrSplit(val, "^")
  ret := {}
  detl := ""
  dodetl := false
  Loop % vas.MaxIndex()
  {
    var := vas[A_Index]
    if A_Index = 1
        ret["Height"] := Trim(SubStr(var, 10))
    else if A_Index = 2
        ret["lat"] := Trim(SubStr(var, 12))
    else if A_Index = 3
        ret["long"] := Trim(SubStr(var, 13))
    else if A_Index = 4
        ret["IsonMap"] := Trim(SubStr(var, 13))
    else if A_Index = 5
        ret["IsonTPE"] := Trim(SubStr(var, 13))
    else if var = ## Details
      dodetl := true
    else if var = * * *
        dodetl := false
    else if (dodetl)
      detl .= var . "`n"
  }
  ret["Details"] := Trim(detl, OmitChars := "`n")
  return %ret%
}

ListPlaces() {
  idh := ""
  ret := []
  DBJ := new SQLiteDB
  DBJ.OpenDB("C:\Users\David\Documents\OneDrive\Documents\My Documents\0. Admin\joplin-desktop\database.sqlite")
  SQL := "SELECT id FROM folders WHERE title = 'Places';"
  DBJ.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0) {
      idh := Row[1]
    }
  } Until RC < 1
  RecordSet.Free()
  SQL := "SELECT title FROM notes WHERE parent_id = '" . idh . "';"
  DBJ.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0) {
      ret.Push(Row[1])
    }
  } Until RC < 1
  RecordSet.Free()
  DBJ.CloseDB()
  return ret
}

SelectPlace(pPlace) {
  ret := ""
  DBJ := new SQLiteDB
  DBJ.OpenDB("C:\Users\David\Documents\OneDrive\Documents\My Documents\0. Admin\joplin-desktop\database.sqlite")
  SQL := "SELECT body FROM notes WHERE title = """ . pPlace . """;"
  DBJ.Query(SQL, RecordSet)
  Loop {
    RC := RecordSet.Next(Row)
    if (RC > 0) {
      val := Row[1]
    }
  } Until RC < 1
  RecordSet.Free()
  DBJ.CloseDB()
  val := StrReplace(val, "`n", "^")
  val := StrReplace(val, "`r", "")
  vas := StrSplit(val, "^")
  ret := {}
  detl := ""
  dodetl := false
  Loop % vas.MaxIndex()
  {
    var := vas[A_Index]
    if A_Index = 1
        ret["Visited"] := Trim(SubStr(var, 11))
    else if A_Index = 2
        ret["lat"] := Trim(SubStr(var, 12))
    else if A_Index = 3
        ret["long"] := Trim(SubStr(var, 13))
    else if A_Index = 4
        ret["IsonMap"] := Trim(SubStr(var, 13))
    else if A_Index = 5
        ret["IsonTPE"] := Trim(SubStr(var, 13))
    else if A_Index = 6
        ret["HREF"] := Trim(SubStr(var, 8))
    else if var = ## Details
      dodetl := true
    else if var = * * *
        dodetl := false
    else if (dodetl)
      detl .= var . "`n"
  }
  ret["Details"] := Trim(detl, OmitChars := "`n")
  return %ret%
}

GetUNIXEpoch() {
  T = %A_Now%
  FormatTime Y, T, yyyy
  FormatTime D, T, YDay
  FormatTime H, T, H
  FormatTime M, T, m
  FormatTime S, T, s
  L := Floor((Y-1972)/4)+1 ; Leap days
  if This.IsLeapYear(Y)
    L -= 1 ; Avoid double counting the leap day as will be counted in D for current year
  D -= 1 ; Days are counted from 1 so deduct 1 else will count today as whole day plus time
  E := (31536000*(Y-1970) + (D+Floor((Y-1972)/4))*86400 + H*3600 + M*60 + S) * 1000
  return E
}

IsLeapYear(pYear) {
  if (Mod(pYear, 100) = 0)
    return (Mod(pYear, 400) = 0)
  return (Mod(pYear, 4) = 0)
}

}
