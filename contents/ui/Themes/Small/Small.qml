/*
 *   Copyright 2013 Michael Kersey <michael.kersey@gmail.com>
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
    Layout.minimumHeight: 6 * Kirigami.Units.gridUnit
    Layout.maximumHeight: width / gaugeSvg.ratio

    KSvg.Svg {
        id: gaugeSvg
        imagePath: Qt.resolvedUrl("small" + cfg_themeFace + ".svg")
    }

    KSvg.SvgItem {
        id: face
        width: height
        height: Math.min(chart.width, chart.height)
        anchors.centerIn: parent
        svg: gaugeSvg
        elementId: "background"
        antialiasing: true
        readonly property real ratioX: face.width / gaugeSvg.elementRect(
                                           "background").width
        readonly property real ratioY: face.height / gaugeSvg.elementRect(
                                           "background").height

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
            rotation: -(18 + sensor.sensorRate * 140)

            Behavior on rotation {
                RotationAnimation {
                    id: rotationAnim
                    target: pointer
                    duration: Kirigami.Units.longDuration * 4
                    easing.type: Easing.Linear
                }
            }
        }

        Controls.Label {
            visible: root.showlabel
            color: cfg_themeFace == "Dark" ? "#000000" : "#ffffff"
            horizontalAlignment: Text.AlignRight
            fontSizeMode: Text.Fit
            font.pixelSize: face.elementSize("label0").height
            x: face.elementCenter("label0").x - width / 2
            y: face.elementCenter("label0").y - height / 2
            text: totalSensor.formattedValue
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
