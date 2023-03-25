﻿; Include the JSON library
#Include %A_ScriptDir%\lib\Native.ahk
#Include %A_ScriptDir%\lib\github.ahk

; Example usage
; Create a new instance of the appDictionary class

myApp := defineApp("samfisherirl", "Github.ahk")


path_of_app := A_ScriptDir "\github.ahk"
; Call the defineApp method to add a dictionary to the array
myApp.setPath(path_of_app)

myApp.connectGithubAPI()

update := myApp.checkforUpdate()



if (update) {
    msg := update["repo"] . " needs an update. Release notes include:`n" . update["releaseNotes"]
    Msgbox(msg)



    myApp.update()
    ;gets file from repo, if zip, extract
    ;then overwrite existing app
    ;updates log
}
else {
    msgbox("You're up to date!")
}
; Serialize the array of dictionaries as JSON and print the result
;//////////json := myApp.SerializeToJson()
;dic := myApp.setDic(myApp)


; Define a class for building dictionaries of 3 strings
class defineApp {
    __New(username, repo) {
        ; Create a new dictionary with the given strings
        this.username := username,
        this.repo := repo,
        this.downloadUrl := "",
        this.version := "",
        this.releaseNotes := "",
        this.appPath := "",
        this.extension := "",
        this.downloadPath := A_MyDocuments "\temp"
        this.logpath := A_MyDocuments "\log_updater_ahk.json"
    }
    ; Define a method for adding a dictionary of 3 strings to the array

    setPath(appPath) {
        this.appPath := appPath
    }

    connectGithubAPI() {
        ; retieve from github library latest releaseUrl, notes, and version
        git := Github(this.username, this.repo)
        this.downloadUrl := git.releaseUrl()
        this.version := git.version()
        this.releaseNotes := git.details()
        this.extension := "." git.zipORexe()
    }

    checkforUpdate() {
        jdata := this.loadLog()
        if (jdata) {
            if (this.version != jdata["version"]) {
                return jdata
            }
        }
    }
    LoadLog() {
        if FileExist(this.logpath) {
            json_raw := FileRead(this.logpath)
            jdata := JSON.parse(json_raw)
            ;MsgBox(jdata["version"])
            return jdata
        } else {
            this.writeJSON()
            return False
        }

    }

    printDic() {
        for key, value in this.OwnProps() {
            msg .= key . ": " . value . "`n"
        }
        return msg
    }

    writeJSON() {
        dic := {}
        list_of_kv := []
        x := 0
        try {
            FileDelete(this.logpath)
        } catch {
        }
        for key, value in this.OwnProps() {
            if (key != "__Item") {
                dic.%key% := value
            }
            list_of_kv.Push(dic)
        }
        val := JSON.stringify(dic)
        FileAppend(val . "`n`n", this.logpath)
        val := ""
    }

    Update() {
        ;gets file from repo, if zip, extract
        ;then overwrite existing app
        ;updates log
        git := Github(this.username, this.repo)
        git.download(this.downloadpath)
        extension := this.extension
        source := this.downloadpath . extension
        if (InStr(extension, "zip")) or (InStr(extension, "7z")) or (InStr(extension, "rar")) {
            this.zip()
        }
        else {
            FileMove(source, this.appPath)
        }
        this.version := git.version()
        this.writeJSON()

    }

    zip() {
        zipperPath := A_MyDocuments . "\7za"
        ziplog := A_MyDocuments . "\templog.txt"
        temp := this.downloadpath . this.extension
        SplitPath(this.appPath, ,&app)
        zipobj := Github("samfisherirl", "7za")
        if not (FileExist(zipperPath ".exe")) {
            zipobj.download(zipperPath)
        }
        zipperPath := zipperPath . ".exe"
        this.filechecker(zipperPath)
        this.selfReferentialLog()
        ;msgbox(command)
        try {
            FileMove(ziplog, ziplog ".old")
        } catch {
        }
        command := A_ComSpec " `"" zipperPath "`" x `"" temp "`" -y -o`"" app "`" >`"" ziplog "`""
        msgbox(command)
        fileappend(command, A_ScriptDir "\temp.txt")
        Run(command)
        if this.filechecker(ziplog) {
            msgbox(FileRead(ziplog))
        }
        else {
            msgbox("ERROR in exporting zip/rar/7z from local path in Documents")
        }

    }

    filechecker(thefile) {
        loop (20) {
            if fileexist(thefile) {
                sleep(400)
                return True
            } else {
                sleep(200)
            }
        }
        return False

    }
    selfReferentialLog(){
        for key, val in this.OwnProps() {
        msg .= key . val . "`n`n"
        }
        FileAppend(msg, A_ScriptDir "\errlog.txt")
    }
    ; setDic() {
    ;     dictionary := {}
    ;     for key, value in this.OwnProps() {
    ;         dictionary[key] := value
    ;     }
    ;     return dictionary
    ; }
    ; Add the new dictionary to the array
    ; this.dictionaries.push(defineApp)
    /*
        ; Define a method for serializing the array of dictionaries as JSON
        SerializeToJson() {
    ; Serialize the array of dictionaries as JSON
    jdata := JSON.stringify(this.dictionaries)
    ; Return the serialized JSON string
    return jdata
        }
    ; retreive github library data including url to download and version data
    */
}