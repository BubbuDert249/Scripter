-- Scripter: AppleScript & Shell to App converter

display dialog "Choose conversion type:" buttons {"AppleScript to App", "Shell to App"} default button 1
set conversionType to button returned of result

-- Ask for input script
if conversionType is "AppleScript to App" then
    set scriptFile to choose file with prompt "Pick an AppleScript file:" of type {"applescript"}
else
    set scriptFile to choose file with prompt "Pick a Shell script:" of type {"sh", "command", "bash", "zsh", "txt"}
end if

-- Ask for Developer & App Name
set devName to text returned of (display dialog "Enter Developer Name:" default answer "")
set appName to text returned of (display dialog "Enter App Name:" default answer "")

-- Short name (lowercase, no spaces)
set shortName to do shell script "echo " & quoted form of appName & " | tr '[:upper:]' '[:lower:]' | tr -d ' '"

-- Ask for optional icon
set iconChoice to button returned of (display dialog "Do you want to choose a custom icon?" buttons {"No", "Yes"} default button "No")
if iconChoice is "Yes" then
    set iconFile to choose file with prompt "Pick an ICNS file:" of type {"icns"}
else
    set iconFile to ""
end if

-- Ask for save location
set saveFolder to choose folder with prompt "Pick folder to save the .app:"
set appBundle to (POSIX path of saveFolder) & shortName & ".app"

-- Create bundle structure
do shell script "mkdir -p " & quoted form of (appBundle & "/Contents/MacOS")
do shell script "mkdir -p " & quoted form of (appBundle & "/Contents/Resources")

-- Create Info.plist
set packageID to "com." & devName & "." & shortName
set plistContent to "<?xml version=\"1.0\" encoding=\"UTF-8\"?> 
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>CFBundleName</key><string>" & appName & "</string>
    <key>CFBundleIdentifier</key><string>" & packageID & "</string>
    <key>CFBundleVersion</key><string>1.0.0</string>
    <key>CFBundleExecutable</key><string>main.sh</string>
    <key>LSMinimumSystemVersion</key><string>10.4</string>
</dict></plist>"

set plistFile to appBundle & "/Contents/Info.plist"
do shell script "echo " & quoted form of plistContent & " > " & quoted form of plistFile

-- Handle script files
if conversionType is "Shell to App" then
    do shell script "cp " & quoted form of POSIX path of scriptFile & " " & quoted form of (appBundle & "/Contents/MacOS/main.sh")
    do shell script "chmod +x " & quoted form of (appBundle & "/Contents/MacOS/main.sh")
else
    -- AppleScript mode
    set runSh to "#!/bin/bash
osascript \"$(dirname \"$0\")/../Resources/main.applescript\""
    do shell script "echo " & quoted form of runSh & " > " & quoted form of (appBundle & "/Contents/MacOS/run.sh")
    do shell script "chmod +x " & quoted form of (appBundle & "/Contents/MacOS/run.sh")
    do shell script "cp " & quoted form of POSIX path of scriptFile & " " & quoted form of (appBundle & "/Contents/Resources/main.applescript")
end if

-- If icon chosen, copy to Resources
if iconFile is not "" then
    do shell script "cp " & quoted form of POSIX path of iconFile & " " & quoted form of (appBundle & "/Contents/Resources/icon.icns")
    do shell script "plutil -replace CFBundleIconFile -string icon.icns " & quoted form of plistFile
end if

display dialog "App created successfully at: " & appBundle buttons {"OK"} default button "OK"
