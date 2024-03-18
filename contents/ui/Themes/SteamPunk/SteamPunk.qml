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
import org.kde.ksvg as KSvg

Item {
    id: chart
    property string cfg_showlabel: controller.faceConfiguration.showlabel

    Layout.minimumWidth: root.formFactor != Faces.SensorFace.Vertical ? Kirigami.Units.gridUnit * 4 : Kirigami.Units.gridUnit
    Layout.minimumHeight: root.formFactor == Faces.SensorFace.Vertical ? width : Kirigami.Units.gridUnit

    KSvg.Svg {
        id: steamPunkSvg
        imagePath: Qt.resolvedUrl("steamPunk.svg")
    }

    KSvg.SvgItem {
        id: face
        width: Math.min(chart.width, chart.height)
        height: width
        anchors.centerIn: parent
        svg: steamPunkSvg
        elementId: "background"
        readonly property real ratioX: face.width/steamPunkSvg.elementRect("background").width
        readonly property real ratioY: face.height/steamPunkSvg.elementRect("background").height

        function elementPos(element) {
            var rect = steamPunkSvg.elementRect(element);
            return Qt.point(rect.x * ratioX, rect.y * ratioY);
        }

        function elementCenter(element) {
            var rect = steamPunkSvg.elementRect(element);
            return Qt.point(rect.x * ratioX + (rect.width * ratioX)/2, rect.y * ratioY + (rect.height * ratioY)/2);
        }

        function elementSize(element) {
            var rect = steamPunkSvg.elementRect(element);
            return Qt.size(rect.width * ratioX, rect.height * ratioY);
        }

        KSvg.SvgItem {
            svg: steamPunkSvg
            elementId: "pointer-shadow"
            transformOrigin: Item.Center
            x: face.elementCenter("rotatecenter").x - width/2
            y: face.elementCenter("rotatecenter").y - height/2 + 3
            width: face.elementSize("pointer-shadow").width
            height: face.elementSize("pointer-shadow").height
            rotation: pointer.rotation
        }

        KSvg.SvgItem {
            id: pointer
            svg: steamPunkSvg
            elementId: "pointer"
            transformOrigin: Item.Center
            x: face.elementCenter("rotatecenter").x - width/2
            y: face.elementCenter("rotatecenter").y - height/2
            width: face.elementSize("pointer").width
            height: face.elementSize("pointer").height
            rotation: 45 + sensor.sensorRate * 270

            Behavior on rotation {
                RotationAnimation {
                    id: rotationAnim
                    target: pointer
                    duration: Kirigami.Units.longDuration * 8
                    easing.type: Easing.OutElastic
                } 
            }
        }

        FontLoader {
            id: liquidCrystalFontLoader
            source: Qt.resolvedUrl("Spirit's Sword.ttf") // Chemin vers votre fichier de police d'écriture
        }

        Controls.Label {
            visible: root.showlabel
            color: "black"
            horizontalAlignment: Text.AlignRight
            fontSizeMode: Text.Fit
            font.family: "Spirit's Sword" // Nom de votre police d'écriture
            font.pixelSize: face.elementSize("label0").height
            x: face.elementCenter("label0").x - width/2
            y: face.elementCenter("label0").y - height/2
            text: totalSensor.formattedValue
        }
    }

    Sensors.Sensor {
        id: totalSensor
        sensorId: root.controller.totalSensors[0]
    }

    Sensors.Sensor {
        id: sensor
        property real sensorRate: value/Math.max(value, maximum) || 0
        sensorId: root.controller.highPrioritySensorIds[0]
    }
}

