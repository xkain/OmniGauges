/*
 *   Copyright 2019 Marco Martin <mart@kde.org>
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
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

 Kirigami.FormLayout {
    id: root

    property alias cfg_showLegend: showSensorsLegendCheckbox.checked
    property alias cfg_showlabel: showSensorslabelCheckbox.checked

    property string cfg_typeFace: controller.faceConfiguration.typeFace
    property string cfg_themeFace: controller.faceConfiguration.themeFace
    property alias cfg_glow: glowCheckbox.checked

    Controls.Label {
        text: i18n("Theme Selection :")
        font.pointSize: Kirigami.Units.largeSpacing * 1.5// Augmenter la taille du titre
    }

        Kirigami.FormLayout {
            id: themeLayout

        Controls.RadioButton {
            text: "Modern"
            checked: cfg_typeFace === this.text
            onClicked: { if (checked) cfg_typeFace = this.text }
        }

        Controls.RadioButton {
            text: "SteamPunk"
            checked: cfg_typeFace === this.text
            onClicked: { if (checked) cfg_typeFace = this.text }
        }

        Controls.RadioButton {
            text: "Gauge Digital"
            checked: cfg_typeFace === this.text
            onClicked: { if (checked) cfg_typeFace = this.text }
        }

            RowLayout {
                spacing: Kirigami.Units.smallSpacing
                Controls.Label {
                text: i18n("     Option :")
                font.italic: true
                }

                Controls.CheckBox {
                    id: glowCheckbox
                    text: i18n("Glow")
                    }
                }

        Controls.Label {
            font.italic: true
            text: i18n("The next themes have a dark and light mode :")

        }

        Kirigami.FormLayout {

                Controls.RadioButton {
                    text: "Speedometer"
                    checked: cfg_typeFace === this.text
                    onClicked: { if (checked) cfg_typeFace = this.text }
                    Controls.ButtonGroup.group: typeGroup
                }

                Controls.RadioButton {
                    text: "Tachometer"
                    checked: cfg_typeFace === this.text
                    onClicked: { if (checked) cfg_typeFace = this.text }
                    Controls.ButtonGroup.group: typeGroup
                }

                Controls.RadioButton {
                    text: "Small"
                    checked: cfg_typeFace === this.text
                    onClicked: { if (checked) cfg_typeFace = this.text }
                    Controls.ButtonGroup.group: typeGroup
                }


                    RowLayout {
                        spacing: Kirigami.Units.smallSpacing
                        Controls.Label {
                        text: i18n("     Option :")
                        font.italic: true
                    }

                        Controls.RadioButton {
                            text: "Dark"
                            checked: cfg_themeFace === this.text
                            onClicked: { if (checked) cfg_themeFace = this.text }
                        }

                        Controls.RadioButton {
                            text: "Light"
                            checked: cfg_themeFace === this.text
                            onClicked: { if (checked) cfg_themeFace = this.text }
                            }
                        }
                }

                Kirigami.Separator {
                    Kirigami.FormData.isSection: true
                    }

    Controls.Label {
        text: i18n("Other options :")
        font.pointSize: Kirigami.Units.largeSpacing * 1.5// Augmenter la taille du titre
        }
    }

    Kirigami.FormLayout {
        id: otherOptionsLayout
            Controls.CheckBox {
                id: showSensorsLegendCheckbox
                text: i18n("Show Sensors Legend")
                Controls.ButtonGroup.group: option
                }

            Controls.CheckBox {
                id: showSensorslabelCheckbox
                text: i18n("Show Sensors Digital")
                }
            }
    }
