# AHKv2_Self-Updating-Application-Lib
AHKv2 Self Updating Application Library
This  library is off the back of my github.ahk update, and dive into ahkv2. 
credit to Json Native.ahk creator https://www.autohotkey.com/boards/viewtopic.php?t=100602


This solution does the following:
- Takes settings for an app (likely for public release) that needs remote updates, ill use "github.ahk" as an example. 
- Github's API returns release Tag (version), download url, and release updates
- Library connects to the github API and stores version data in a local json temp file
- Everytime the function calls are made in the example the json files is imported and github API redownloads the latest version data
- If version doesn't match local version, a download prompt is offered (customizable)
- 7zip command line utility invokes extraction of the release and overwrites the existing application path set by the user
- Version data is stored for future use

 keep in mind this works but may have an error or two upon various use cases and if reported, I will fix asap. 
 !Important for now, releases must be in the zip's main directory. I dont have a function to handle zips with the main app in a folder. 

Try, Catch need to be implemented as a code feature (I dont self-referentially update for you so make sure to check the github  for updates ;) 

```autohotkey
myApp := defineApp("samfisherirl", "Github.ahk")
; this example refers to my repo http://github.com/samfisherirl/github.ahk

path_of_app := A_ScriptDir "\github.ahk"
; set where my application is stored on the local computer

myApp.setPath(path_of_app)

myApp.connectGithubAPI()

update := myApp.checkforUpdate()

if (update) {
    ;update stores all json data, you can see some details below. Look at "defineApp" class for more details
    msg := update["repo"] . " version number " . update["version"] . " needs an update. Release notes include:`n" . update["releaseNotes"]
    Msgbox(msg)

    myApp.update()
    ;gets file from repo, if zip/7zip, extract
    ;then overwrite existing app
    ;updates log
}
else {
    msgbox("You're up to date!")
}
```

full code does not include native.ahk and github.ahk, both needed. find the full code here:

 
