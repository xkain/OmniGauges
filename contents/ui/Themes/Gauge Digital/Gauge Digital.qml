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
import QtQuick.Controls as Controls
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.faces as Faces
import org.kde.quickcharts as Charts
import org.kde.quickcharts.controls as ChartControls
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
        imagePath: Qt.resolvedUrl("gauge.svg")
        property real ratio
        onRepaintNeeded: {
            ratio = gaugeSvg.elementSize("hint-boundingrect").width / gaugeSvg.elementSize("hint-boundingrect").height
        }
    }

    KSvg.SvgItem {
        id: background
        width: foreground.width
        height: foreground.height

        anchors.horizontalCenter: parent.horizontalCenter
        svg: gaugeSvg
        elementId: "background"
    }

    Item {
        id: renderParent
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
        }
        height:  parent.height * gaugeSvg.ratio
        //layer.enabled: true

        KSvg.SvgItem {
            id: foreground
            visible: false
            width: Math.min(parent.width, parent.height)
            height: width

            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }
            svg: gaugeSvg
            elementId: "foreground"
            readonly property real ratioX: foreground.width/gaugeSvg.elementRect("foreground").width
            readonly property real ratioY: foreground.height/gaugeSvg.elementRect("foreground").height

            function elementPos(element) {
                var rect = gaugeSvg.elementRect(element);
                return Qt.point(rect.x * ratioX, rect.y * ratioY);
            }

            function elementCenter(element) {
                var rect = gaugeSvg.elementRect(element);
                return Qt.point(rect.x * ratioX + (rect.width * ratioX)/2, rect.y * ratioY + (rect.height * ratioY)/2);
            }

            function elementSize(element) {
                var rect = gaugeSvg.elementRect(element);
                return Qt.size(rect.width * ratioX, rect.height * ratioY);
            }
        }

        ChartControls.PieChartControl {
            id: pie
            visible: false
            anchors.fill: foreground
            property alias sensors: sensorsModel.sensors
            property alias sensorsModel: sensorsModel

            Layout.minimumWidth: root.formFactor != Faces.SensorFace.Vertical ? Kirigami.Units.gridUnit * 4 : Kirigami.Units.gridUnit
            Layout.minimumHeight: root.formFactor == Faces.SensorFace.Vertical ? width : Kirigami.Units.gridUnit

            leftPadding: 0
            rightPadding: 0
            topPadding: 0
            bottomPadding: 0
            chart.smoothEnds: false
            chart.fromAngle: -110
            chart.toAngle: 110
            //chart.thickness: 80
            chart.filled: true

            range {
                from: root.controller.faceConfiguration.rangeFrom
                to: root.controller.faceConfiguration.rangeTo
                automatic: root.controller.faceConfiguration.rangeAuto
            }

            text: root.controller.totalSensors.length == 1 ? sensor.formattedValue : ""

            valueSources: Charts.ModelSource {
                model: Sensors.SensorDataModel {
                    id: sensorsModel
                    sensors: root.controller.highPrioritySensorIds
                }
                roleName: "Value"
                indexColumns: true
            }
            chart.nameSource: Charts.ModelSource {
                roleName: "Name";
                model: valueSources[0].model;
                indexColumns: true
            }
            chart.shortNameSource: Charts.ModelSource {
                roleName: "ShortName";
                model: valueSources[0].model;
                indexColumns: true
            }
            chart.colorSource: root.colorSource
        }

        OpacityMask {
            cached: true
            anchors.fill: foreground
            source: pie
            maskSource: foreground
        }

        Item {
            id: pointersContainer
            anchors.fill: foreground
            Repeater {
                id: handleRepeater
                model: root.controller.highPrioritySensorIds


                Item {
                    x: foreground.elementCenter("rotatecenter").x - width/2
                    y: foreground.elementCenter("rotatecenter").y //- height/2
                    width: foreground.elementSize("pointer").width
                    height: foreground.elementSize("pointer").height
                    transformOrigin: Item.Top
                    // only 7.5 degrees increments
                    rotation: index === 0
                        ? Math.round((75 + sensor.sensorRate * 210) / 7.5) * 7.5
                        : Math.round((sensor.sensorRate * 210 + pointersContainer.children[index-1].rotation) / 7.5) * 7.5
                    Sensors.Sensor {
                        id: sensor
                        property real sensorRate: value/Math.max(value, maximum) || 0
                        sensorId: modelData
                    }

                    KSvg.SvgItem {
                        id: pointerSvg
                        visible: false
                        anchors.fill: parent
                        svg: gaugeSvg
                        elementId: "pointer"
                    }
                    Rectangle {
                        id: handColor
                        visible: false
                        anchors.fill: parent
                        color: root.colorSource.map[modelData]
                    }
                    OpacityMask {
                        cached: true
                        anchors.fill: parent
                        source: handColor
                        maskSource: pointerSvg
                    }
                }
            }

            FontLoader {
                id: liquidCrystalFontLoader
                source: Qt.resolvedUrl("Minecart LCD.ttf") // Chemin vers votre fichier de police d'écriture
            }

            Controls.Label {
                visible: root.showlabel
                color: root.controller.highPrioritySensorIds.length > 0 ? root.colorSource.map[root.controller.highPrioritySensorIds[0]] : Kirigami.Theme.highlightColor
                font.family: "Minecart LCD" // Nom de votre police d'écriture
                font.pixelSize: foreground.elementSize("label0").height
                x: foreground.elementCenter("label0").x - width/2
                y: foreground.elementCenter("label0").y - height/2
                text: totalSensor.formattedValue

            }
        }
    }

    FastBlur {
        z: -1
        visible: controller.faceConfiguration.glow
        anchors.fill: renderParent
        source: renderParent
        radius: Kirigami.Units.gridUnit/2
    }

    Sensors.Sensor {
        id: totalSensor
        sensorId: root.controller.totalSensors[0]
    }


}

