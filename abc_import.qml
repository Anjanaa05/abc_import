

import QtQuick 2.1
import QtQuick.Dialogs 1.0
import QtQuick.Controls 1.0
import QtQuick.Window 2.2
import MuseScore 3.0
import FileIO 3.0

MuseScore {
    menuPath: "Plugins.ABC Import"
    title: "ABC Import"
    version: "4.0.0"
    description: qsTr("This plugin imports ABC text from a file or the clipboard. Internet connection is required.")
    thumbnailName: "abc-import.png"
    categoryCode: "import"
    requiresScore: false
    pluginType: "dialog"

    id: pluginDialog
    width: 800; height: 500;

    onRun: {}

    FileIO {
        id: myFileAbc
        onError: console.log(msg + "  Filename = " + myFileAbc.source)
        }

    FileIO {
        id: myFile
        source: tempPath() + "/my_file.xml"
        onError: console.log(msg)
        }

    FileDialog {
        id: fileDialog
        title: qsTr("Please choose a file")
        onAccepted: {
            var filename = fileDialog.fileUrl
            //console.log("You chose: " + filename)

            if(filename){
                myFileAbc.source = filename
                //read abc file and put it in the TextArea
                abcText.text = myFileAbc.read()
                }
            }
        }

    Label {
        id: textLabel
        wrapMode: Text.WordWrap
        text: qsTr("Paste your ABC tune here (or click button to load a file)\nYou need to be connected to internet for this plugin to work")
        font.pointSize:12
        anchors.left: pluginDialog.left
        anchors.top: pluginDialog.top
        anchors.leftMargin: 10
        anchors.topMargin: 10
        }

    // Where people can paste their ABC tune or where an ABC file is put when opened
    TextArea {
        id:abcText
        anchors.top: textLabel.bottom
        anchors.left: pluginDialog.left
        anchors.right: pluginDialog.right
        anchors.bottom: convertedStorageLocationLabel.top
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        width:parent.width
        height:400
        wrapMode: TextEdit.WrapAnywhere
        textFormat: TextEdit.PlainText
        }

    TextField {
        id: convertedStorageLocationLabel
        text: ""
        //font.pointSize:12
        anchors.top: abcText.bottom
        anchors.left: pluginDialog.left
        anchors.right: pluginDialog.right
        anchors.bottom: buttonOpenFile.top
        anchors.topMargin: 10
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.bottomMargin: 10
        readOnly: true
        //selectByKeyboard: true
        //selectByMouse: true
        }

    Button {
        id : buttonOpenFile
        text: qsTr("Open file")
        anchors.bottom: pluginDialog.bottom
        anchors.left: abcText.left
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        anchors.leftMargin: 10
        onClicked: {
            fileDialog.open();
            }
        }

    Button {
        id : buttonConvert
        text: qsTr("Import")
        anchors.bottom: pluginDialog.bottom
        anchors.right: abcText.right
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        anchors.rightMargin: 10
        onClicked: {
            var content = "content=" + encodeURIComponent(abcText.text)
            //console.log("content : " + content)

            var request = new XMLHttpRequest()
            request.onreadystatechange = function() {
                if (request.readyState == XMLHttpRequest.DONE) {
                    var response = request.responseText
                    //console.log("responseText : " + response)
                    myFile.source = myFile.tempPath() + "/" + (Date.now()) + ".xml";
                    myFile.write(response);
                    //readScore(myFile.source) // Not yet supported in 4.0.0
                    convertedStorageLocationLabel.text = myFile.source;
                    convertedStorageLocationLabel.selectAll();
                    convertedStorageLocationLabel.copy();
                    convertedStorageLocationLabel.deselect();
                    cmd("file-open");
                    pluginDialog.parent.Window.window.close();
                    }
                }
            request.open("POST", "https://musescore.jeetee.net/abc/abc2xml.py", true)
            request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
            request.send(content)
            }
        }

    Button {
        id : buttonCancel
        text: qsTr("Cancel")
        anchors.bottom: pluginDialog.bottom
        anchors.right: buttonConvert.left
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        anchors.rightMargin: 10
        onClicked: {
                pluginDialog.parent.Window.window.close();
            }
        }
    }
