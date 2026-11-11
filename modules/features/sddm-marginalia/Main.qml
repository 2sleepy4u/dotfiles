import QtQuick
import QtQuick.Controls
import Qt.labs.folderlistmodel

// Marginalia: notes on the left, the wallpaper on the right.
// Laid out on a 1440x900 grid (the mockup) and scaled by `s`.
Rectangle {
    id: root
    width: 1440
    height: 900
    color: ui.bg

    readonly property real s: Math.min(width / 1440, height / 900)
    readonly property var loc: Qt.locale(config.locale || "it_IT")

    readonly property string serif: "Source Serif 4"
    readonly property string sans: "Inter"

    QtObject {
        id: ui
        readonly property color bg: "#141413"
        readonly property color text: "#faf9f5"
        readonly property color muted: "#b0aea5"
        readonly property color soft: "#d9d6cc"
        readonly property color line: "#62625e"
        readonly property color error: "#f47d6b"
    }

    // --- user -------------------------------------------------------------
    property string userName: userModel.lastUser
    property string realName: userName

    // No last user (first boot): take the first one in the model.
    Repeater {
        model: userModel
        delegate: Item {
            Component.onCompleted: {
                if (!root.userName && index === 0)
                    root.userName = model.name
                if (model.name === root.userName)
                    root.realName = model.realName || model.name
            }
        }
    }

    function doLogin() {
        errorHint.visible = false
        sddm.login(root.userName, password.text, sessionModel.lastIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            password.text = ""
            errorHint.visible = true
            password.forceActiveFocus()
        }
    }

    // --- time -------------------------------------------------------------
    property date now: new Date()
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    function quoteFor(h) {
        if (h >= 5 && h < 12) return config.quoteMorning
        if (h >= 12 && h < 18) return config.quoteAfternoon
        if (h >= 18 && h < 23) return config.quoteEvening
        return config.quoteNight
    }

    // --- wallpaper (single file dropped by noctalia's hook) ---------------
    FolderListModel {
        id: wallpapers
        folder: "file://" + config.wallpaperDir
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.JPG", "*.PNG"]
        showDirs: false
    }

    readonly property string wallpaperName: wallpapers.count > 0 ? wallpapers.get(0, "fileBaseName") : ""

    // "Title — Author" / "Title - Author" → [title, author]
    function caption(name) {
        if (!name) return ["", ""]
        var sep = name.indexOf(" — ") >= 0 ? " — " : (name.indexOf(" - ") >= 0 ? " - " : "")
        if (sep) {
            var i = name.indexOf(sep)
            return [name.slice(0, i), name.slice(i + sep.length)]
        }
        return [name.replace(/[_-]+/g, " "), ""]
    }
    readonly property var cap: caption(wallpaperName)

    // --- right: wallpaper ---------------------------------------------------
    Image {
        id: wallpaper
        x: panel.width
        width: root.width - panel.width
        height: root.height
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        source: wallpapers.count > 0 ? wallpapers.get(0, "fileUrl") : config.fallbackBackground
        onStatusChanged: if (status === Image.Error && source != config.fallbackBackground)
                             source = config.fallbackBackground
    }

    Rectangle {
        visible: root.cap[0] !== ""
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 40 * s
        width: captionCol.implicitWidth + 36 * s
        height: captionCol.implicitHeight + 32 * s
        color: Qt.rgba(0.078, 0.078, 0.075, 0.92)

        Column {
            id: captionCol
            anchors.centerIn: parent
            spacing: 6 * s
            Text {
                text: root.cap[0]
                color: ui.text
                font.family: root.serif
                font.italic: true
                font.pixelSize: 19 * s
            }
            Text {
                visible: text !== ""
                text: root.cap[1]
                color: ui.muted
                font.family: root.sans
                font.pixelSize: 12 * s
            }
        }
    }

    // --- left: panel -------------------------------------------------------
    Rectangle {
        id: panel
        width: Math.round(root.width * 0.388)
        height: root.height
        color: ui.bg

        Item {
            id: content
            x: 72 * s
            width: 415 * s
            height: parent.height

            Text {
                y: 56 * s
                text: config.brand
                color: ui.text
                font.family: root.sans
                font.weight: Font.Bold
                font.pixelSize: 12 * s
                font.letterSpacing: 1.8 * s
            }

            Text {
                y: 183 * s
                text: (root.loc.dayName(root.now.getDay(), Locale.LongFormat) + " · "
                       + root.now.getDate() + " "
                       + root.loc.standaloneMonthName(root.now.getMonth(), Locale.LongFormat) + " "
                       + root.now.getFullYear()).toUpperCase()
                color: ui.muted
                font.family: root.sans
                font.weight: Font.DemiBold
                font.pixelSize: 12.5 * s
                font.letterSpacing: 1.2 * s
            }

            Text {
                y: 205 * s
                x: -4 * s
                text: Qt.formatTime(root.now, "HH:mm")
                color: ui.text
                font.family: root.serif
                font.pixelSize: 150 * s
                font.letterSpacing: -3 * s
            }

            Text {
                y: 390 * s
                width: parent.width
                wrapMode: Text.WordWrap
                text: root.quoteFor(root.now.getHours())
                color: ui.soft
                font.family: root.serif
                font.italic: true
                font.pixelSize: 21 * s
                lineHeight: 1.05
            }

            // user tile
            Rectangle {
                id: avatar
                y: 497 * s
                width: 46 * s
                height: 46 * s
                color: "transparent"
                border.color: ui.line
                border.width: 1
                Text {
                    anchors.centerIn: parent
                    text: root.realName.charAt(0).toUpperCase()
                    color: ui.text
                    font.family: root.serif
                    font.pixelSize: 20 * s
                }
            }
            Column {
                anchors.left: avatar.right
                anchors.leftMargin: 14 * s
                anchors.verticalCenter: avatar.verticalCenter
                spacing: 2 * s
                Text {
                    text: root.realName
                    color: ui.text
                    font.family: root.sans
                    font.weight: Font.DemiBold
                    font.pixelSize: 15 * s
                }
                Text {
                    visible: root.userName !== ""
                    text: root.userName + "@" + sddm.hostName
                    color: ui.muted
                    font.family: root.sans
                    font.pixelSize: 12 * s
                }
            }

            Text {
                y: 557 * s
                text: "Parola d’accesso"
                color: ui.muted
                font.family: root.sans
                font.pixelSize: 12 * s
            }

            TextField {
                id: password
                y: 578 * s
                width: parent.width
                height: 50 * s
                focus: true
                echoMode: TextInput.Password
                passwordCharacter: "•"
                color: ui.text
                selectionColor: ui.line
                font.family: root.sans
                font.pixelSize: 18 * s
                font.letterSpacing: 2 * s
                leftPadding: 18 * s
                verticalAlignment: TextInput.AlignVCenter
                background: Rectangle {
                    radius: 8 * s
                    color: "transparent"
                    border.width: 1
                    border.color: password.activeFocus ? ui.muted : ui.line
                }
                Keys.onReturnPressed: root.doLogin()
                Keys.onEnterPressed: root.doLogin()
                Component.onCompleted: forceActiveFocus()
            }

            Rectangle {
                id: unlock
                y: 643 * s
                width: 120 * s
                height: 43 * s
                radius: 4 * s
                color: unlockArea.pressed ? ui.soft : ui.text
                Text {
                    anchors.centerIn: parent
                    text: "Sblocca"
                    color: ui.bg
                    font.family: root.sans
                    font.weight: Font.DemiBold
                    font.pixelSize: 15 * s
                }
                MouseArea {
                    id: unlockArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.doLogin()
                }
            }

            Text {
                id: errorHint
                visible: false
                anchors.left: unlock.right
                anchors.leftMargin: 18 * s
                anchors.verticalCenter: unlock.verticalCenter
                text: "Parola d’accesso errata"
                color: ui.error
                font.family: root.sans
                font.pixelSize: 13 * s
            }

            Row {
                y: 826 * s
                spacing: 8 * s

                component Pill: Rectangle {
                    id: pill
                    property alias label: pillText.text
                    signal clicked
                    width: pillText.implicitWidth + 34 * s
                    height: 34 * s
                    radius: 10 * s
                    color: pillArea.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : "transparent"
                    border.width: 1
                    border.color: ui.line
                    Text {
                        id: pillText
                        anchors.centerIn: parent
                        color: ui.text
                        font.family: root.sans
                        font.pixelSize: 13 * s
                    }
                    MouseArea {
                        id: pillArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: pill.clicked()
                    }
                }

                Pill {
                    visible: sddm.canSuspend
                    label: "Sospendi"
                    onClicked: sddm.suspend()
                }
                Pill {
                    visible: sddm.canPowerOff
                    label: "Spegni"
                    onClicked: sddm.powerOff()
                }
            }
        }
    }
}
