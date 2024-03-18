/*
 *   Copyright 2019 Marco Martin <mart@kde.org>
 *   Copyright 2019 David Edmundson <davidedmundson@kde.org>
 *   Copyright 2019 Arjen Hiemstra <ahiemstra@heimr.nl>
 *   Copyright 2019 Kai Uwe Broulik <kde@broulik.de>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.faces as Faces
import org.kde.quickcharts as Charts
import org.kde.quickcharts.controls as ChartControls





Faces.SensorFace {
    id: root
    property string typeFace: controller.faceConfiguration.typeFace
    readonly property bool showlabel: controller.faceConfiguration.showlabel
    onTypeFaceChanged: {
        loader.height = loader.height - 1
        timer.start()
    }
    Timer {
        //fix for reload SVG
        id: timer
        running: false
        repeat: false
        interval: 5
        onTriggered: {
            loader.height = loader.height + 1
        }
    }

    contentItem: ColumnLayout {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 3

        Loader {
            id: loader
            source: "./Themes/" + typeFace + "/" + typeFace + ".qml"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumHeight: Math.max(root.width, Layout.minimumHeight)
        }
    }
}

