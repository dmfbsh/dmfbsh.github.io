#SingleInstance force

if A_Args.Length() = 0
{
  MsgBox, At least one image must be selected
}
else
{
  cb := ""
  for index, value in A_Args
  {
    ix := InStr(value, "\", false, -1, 1)
    fn := SubStr(value, ix + 1)
    cb .= "- Sub-Image: " . fn . "`n"
  }
  Clipboard := cb
  MsgBox, The list of sub-images is in the clipboard
}
