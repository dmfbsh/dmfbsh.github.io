Option Explicit

Dim StartNumber

StartNumber = -99

'Function OnGetCustomFields(ByRef getFieldData)
'  getFieldData.fields.my_field = ""
'  getFieldData.field_labels("my_field") = "Start Number"
'  getFieldData.field_tips("my_field") = "The first number suffix to use" 
'End Function

Function OnGetNewName(ByRef getNewNameData)
	' Add script code here.
	' 
	' Main inputs (all read-only):
	' 
	' - getNewNameData.item:
	'     Object with information about the item being renamed.
	'     e.g. item.name, item.name_stem, item.ext,
	'          item.is_dir, item.size, item.modify,
	'          item.metadata, etc.
	'     item.path is the path to the parent folder.
	'     item.realpath is the full path to the file, including its name,
	'          and with things like Collections and Libraries resolved to
	'          the real directories that they point to.
	' - getNewNameData.oldname_field:
	' - getNewNameData.newname_field:
	'     Content of the "Old Name" and "New Name" fields in the Rename dialog.
	' - getNewNameData.newname:
	' - getNewNameData.newname_stem and newname_stem_m:
	' - getNewNameData.newname_ext  and newname_ext_m:
	'     The proposed new name for the item, based on the non-script
	'     aspects of the Rename dialog. Scripts should usually work from this
	'     rather than item.name, so that they add to the dialog's changes.
	'     newname_ext is the file extension, or an empty string if none.
	'     newname_stem is everything before the file extension.
	'     The *_m versions handle multi-part extensions like ".part1.rar".
	' - getNewNameData.custom:
	'     Contains any custom field values for additional user input.
	' 
	' Return values:
	' 
	' - OnGetNewName=True:
	'     Prevents rename.
	'     The proposed getNewNameData.newname is not used.
	' - OnGetNewName=False: (Default)
	'     Allows rename.
	'     The proposed getNewNameData.newname is used as-is.
	' - OnGetNewName="string"
	'     Allows rename.
	'     The file's new name is the string the script returns.

	Dim item, meta, name
	Dim fs, fd, fl, fo, hn, ns
	Set item = getNewNameData.item
	Set meta = item.metadata
	If StartNumber = -99 Then
		Set fs = CreateObject("Scripting.FileSystemObject")
		Set fd = fs.GetFolder("C:\Users\David\Documents\OneDrive\Documents\My Documents\5. Stamps\Photos")
		Set fl = fd.Files
		hn = 0
		For Each fo in fl
			ns = CInt(Right(Left(fo.Name, 9), 4))
			If ns > hn Then
				hn = ns
			End If
		Next
'		If Len(getNewNameData.custom.my_field) = 0 Then
'			StartNumber = -1
'		Else
'			StartNumber = CInt(getNewNameData.custom.my_field) - 1
'		End If
		StartNumber = hn
	End If
	StartNumber = StartNumber + 1
	name = "stamp" & Right("0000" & CStr(StartNumber), 4)
	OnGetNewName = name & item.ext
End Function
