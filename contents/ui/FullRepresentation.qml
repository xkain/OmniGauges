/*
 *   Copyright 2019 Marco Martin <mart@kde.org>
 *   Copyright 2019 David Edmundson <davidedmundson@kde.org>
 *   Copyright 2019 Arjen Hiemstra <ahiemstra@heimr.nl>
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
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.faces as Faces
import org.kde.quickcharts as Charts
import org.kde.quickcharts.controls as ChartsControls
import org.kde.plasma.core as PlasmaCore

Faces.SensorFace {
    id: root
    readonly property bool showLegend: controller.faceConfiguration.showLegend
    readonly property bool showlabel: controller.faceConfiguration.showlabel
    property string typeFace: controller.faceConfiguration.typeFace
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

        Kirigami.Heading {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            text: root.controller.title
            visible: root.controller.showTitle && text.length > 0
            level: 2
        }

        Loader {
            id: loader
            source: "./Themes/" + typeFace + "/" + typeFace + ".qml"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 5 * Kirigami.Units.gridUnit
            Layout.preferredHeight: 8 * Kirigami.Units.gridUnit
            Layout.minimumWidth: Kirigami.Units.gridUnit * 8

        }

        ColumnLayout {
            visible: root.showLegend

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            Repeater {
                model: root.controller.highPrioritySensorIds.concat(
                           root.controller.lowPrioritySensorIds)

                ChartsControls.LegendDelegate {
                    readonly property bool isTextOnly: index >= root.controller.highPrioritySensorIds.length

                    Layout.fillWidth: true
                    Layout.minimumHeight: isTextOnly ? 0 : implicitHeight

                    name: sensor.shortName
                    value: sensor.formattedValue
                    // Contrôler la visibilité de la couleur en fonction de isTextOnly
                    visible: !isTextOnly
                    color: root.colorSource.map[modelData]

                    Sensors.Sensor {
                        id: sensor
                        sensorId: modelData
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
