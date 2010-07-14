(*
Updates Dates from MOD to mp4 Script
April 11, 2010

Replace function by Bruce Phillips via MacScripter
	[http://macscripter.net/viewtopic.php?id=18551]

Folder scan, creation and modification dates retrieval and update by Nicolas Meier
	[http://www.ragnrale.com/2010/04/mod-to-mp4-without-loosing-timestamps/]

Growl support by Shawn Blanc, "Safari to Yojimbo Bookmark Script"
	[http://shawnblanc.net/2009/10/safari-yojimbo]

The script will get the creation and modification dates from the .MOD files
and apply them to the .mp4 files in the same folder. It assumes that you
have installed the developer tools as the GetFileInfo and SetFile
are called to get and set creation/modification dates on files.
A Growl notification will appear for each successfully updated file.

*)

-- find : Text to be found
-- replace : Text to replace with
-- someText : Text to be searched
on replaceText(find, replace, someText)
	set prevTIDs to text item delimiters of AppleScript
	set text item delimiters of AppleScript to find
	set someText to text items of someText
	set text item delimiters of AppleScript to replace
	set someText to "" & someText
	set text item delimiters of AppleScript to prevTIDs
	return someText
end replaceText

try
	(* Get the current folder from the frontmost Finder window	 *)
	tell application "Finder" to set thePath to (folder of the front window) as alias
	
	(* If you prefer to browse to a specific folder *)
	--set thePath to choose folder with prompt "Choose a folder:"
	
	set unixPath to POSIX path of thePath
on error
	return
end try

tell application "Finder"
	set filelist to every document file of the thePath whose name contains ".MOD"
	repeat with currentFile in filelist
		set currentFileName to (the name of currentFile)
		
		set createdAttributes to do shell script "/Developer/Tools/GetFileInfo " & quoted form of unixPath & currentFileName & "| grep created"
		set modifiedAttributes to do shell script "/Developer/Tools/GetFileInfo " & quoted form of unixPath & currentFileName & "| grep modified"
		
		set createdDate to text from character 10 to end of createdAttributes
		set modifiedDate to text from character 11 to end of modifiedAttributes
		
		set targetName to my replaceText(".MOD", ".mp4", currentFileName)
		
		do shell script "/Developer/Tools/SetFile -d \"" & createdDate ¬
			& "\" -m \"" & modifiedDate ¬
			& "\" " & quoted form of unixPath & targetName
		
		tell application "GrowlHelperApp"
			set the allNotificationsList to {"Success Notification", "Failure Notification"}
			set the enabledNotificationsList to {"Success Notification", "Failure Notification"}
			
			register as application ¬
				"Updates Dates from MOD to mp4 Script" all notifications allNotificationsList ¬
				default notifications enabledNotificationsList ¬
				icon of application "Finder"
			
			notify with name ¬
				"Success Notification" title ¬
				"Creation and modification date updated to" description ¬
				createdDate & " and
				" & modifiedDate & " on " & targetName ¬
				& "" application name "Updates Dates from MOD to mp4 Script"
		end tell
	end repeat
end tell