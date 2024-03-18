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
import QtQuick.Particles
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.faces as Faces
import org.kde.quickcharts as Charts
import org.kde.plasma.core as PlasmaCore
import Qt5Compat.GraphicalEffects
import org.kde.ksvg as KSvg

Item {
    id: chart
    property string cfg_themeFace: controller.faceConfiguration.themeFace
    property string cfg_showlabel: controller.faceConfiguration.showlabel

    Layout.minimumWidth: Kirigami.Units.gridUnit * 9
    Layout.minimumHeight: 9 * Kirigami.Units.gridUnit

    KSvg.Svg {
        id: gaugeSvg
        imagePath: Qt.resolvedUrl("modern.svg")
    }
    KSvg.SvgItem {
        id: face
        width: height
        height: Math.min(chart.width, chart.height)
        anchors.centerIn: parent
        svg: gaugeSvg
        elementId: "background"
        antialiasing: true
        readonly property real ratioX: face.width / gaugeSvg.elementRect("background").width
        readonly property real ratioY: face.height / gaugeSvg.elementRect("background").height

        function elementPos(element) {
            var rect = gaugeSvg.elementRect(element)
            return Qt.point(rect.x * ratioX, rect.y * ratioY)
        }

        function elementCenter(element) {
            var rect = gaugeSvg.elementRect(element)
            return Qt.point(rect.x * ratioX + (rect.width * ratioX) / 2,
                            rect.y * ratioY + (rect.height * ratioY) / 2)
        }

        function elementSize(element) {
            var rect = gaugeSvg.elementRect(element)
            return Qt.size(rect.width * ratioX, rect.height * ratioY)
        }

        KSvg.SvgItem {
            id: pointer
            svg: gaugeSvg
            elementId: "pointer"
            transformOrigin: Item.Center
            x: face.elementCenter("rotatecenter").x - width / 2
            y: face.elementCenter("rotatecenter").y - height / 2
            width: face.elementSize("pointer").width
            height: face.elementSize("pointer").height
            rotation: 45 + sensor.sensorRate * 270

            Behavior on rotation {
                RotationAnimation {
                    id: rotationAnim
                    target: pointer
                    duration: Kirigami.Units.longDuration * 2
                    easing.type: Easing.Linear
                }
            }
        }

         FontLoader {
            id: liquidCrystalFontLoader
            source: Qt.resolvedUrl("E1234.ttf")
        }

        Controls.Label {
            visible: root.showlabel
            color: root.controller.highPrioritySensorIds.length > 0 ? root.colorSource.map[root.controller.highPrioritySensorIds[0]] : Kirigami.Theme.highlightColor
            horizontalAlignment: Text.AlignCenter
            verticalAlignment: Text.AlignVCenter
            fontSizeMode: Text.Fit
            font.pixelSize: face.elementSize("label0").height
            font.family: "E1234"
            x: face.elementCenter("label0").x - width / 1.8
            y: face.elementCenter("label0").y - height / 1.8 + face.elementSize("label0").height * 0.2
            text: {
                // Récupérer la valeur avec symboles
                var valueWithSymbols = totalSensor.formattedValue;

                // Extraire uniquement la partie entière du nombre
                var intValue = parseInt(valueWithSymbols);

                // Retourner la partie entière du nombre
                return intValue.toString();
                }
        }
    }

    Sensors.Sensor {
        id: totalSensor
        sensorId: root.controller.totalSensors[0]
    }

    Sensors.Sensor {
        id: sensor
        property real sensorRate: value / Math.max(value, maximum) || 0
        sensorId: root.controller.highPrioritySensorIds[0]
    }
}
