/*
 * Copyright (c) 2015-2023 Meltytech, LLC
 * Author: Lauren Dennedy
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Shotcut.Controls as Shotcut

Shotcut.KeyframableFilter {
    property string centerProperty: '0'
    property string bandwidthProperty: '1'
    property string stagesProperty: '2'
    property string wetnessProperty: 'wetness'

    function setControls() {
        var position = getPosition();
        blockUpdate = true;
        sliderCenter.value = filter.getDouble(centerProperty, position);
        centerKeyframesButton.checked = filter.animateIn <= 0 && filter.animateOut <= 0 && filter.keyframeCount(centerProperty) > 0;
        sliderBandwidth.value = filter.getDouble(bandwidthProperty, position);
        bandwidthKeyframesButton.checked = filter.animateIn <= 0 && filter.animateOut <= 0 && filter.keyframeCount(bandwidthProperty) > 0;
        sliderStages.value = filter.getDouble(stagesProperty, position);
        stagesKeyframesButton.checked = filter.animateIn <= 0 && filter.animateOut <= 0 && filter.keyframeCount(stagesProperty) > 0;
        sliderWetness.value = filter.getDouble(wetnessProperty, position) * sliderWetness.maximumValue;
        wetnessKeyframesButton.checked = filter.animateIn <= 0 && filter.animateOut <= 0 && filter.keyframeCount(wetnessProperty) > 0;
        blockUpdate = false;
        enableControls(isSimpleKeyframesActive());
    }

    function enableControls(enabled) {
        sliderCenter.enabled = sliderBandwidth.enabled = sliderStages.enabled = sliderWetness.enabled = enabled;
    }

    function updateSimpleKeyframes() {
        updateFilter(centerProperty, sliderCenter.value, centerKeyframesButton, null);
        updateFilter(bandwidthProperty, sliderBandwidth.value, bandwidthKeyframesButton, null);
        updateFilter(stagesProperty, sliderStages.value, stagesKeyframesButton, null);
        updateFilter(wetnessProperty, sliderWetness.value / sliderWetness.maximumValue, wetnessKeyframesButton, null);
    }

    keyframableParameters: preset.parameters
    startValues: [322, 322, 1, 1]
    middleValues: [322, 322, 1, 1]
    endValues: [322, 322, 1, 1]
    width: 350
    height: 150
    Component.onCompleted: {
        if (filter.isNew) {
            // Set default parameter values
            filter.set(centerProperty, 322);
            filter.set(bandwidthProperty, 322);
            filter.set(stagesProperty, 1);
            filter.set(wetnessProperty, 1);
            filter.savePreset(preset.parameters);
        }
        setControls();
    }

    GridLayout {
        anchors.fill: parent
        anchors.margins: 8
        columns: 4

        Label {
            text: qsTr('Preset')
            Layout.alignment: Qt.AlignRight
        }

        Shotcut.Preset {
            id: preset

            parameters: [centerProperty, bandwidthProperty, stagesProperty, wetnessProperty]
            Layout.columnSpan: parent.columns - 1
            onBeforePresetLoaded: {
                resetSimpleKeyframes();
            }
            onPresetSelected: {
                setControls();
                initializeSimpleKeyframes();
            }
        }

        Label {
            text: qsTr('Center frequency')
            Layout.alignment: Qt.AlignRight
        }

        Shotcut.SliderSpinner {
            id: sliderCenter

            minimumValue: 5
            maximumValue: 21600
            suffix: ' Hz'
            onValueChanged: updateFilter(centerProperty, value, centerKeyframesButton, getPosition())
        }

        Shotcut.UndoButton {
            onClicked: sliderCenter.value = 322
        }

        Shotcut.KeyframesButton {
            id: centerKeyframesButton

            onToggled: {
                enableControls(true);
                toggleKeyframes(checked, centerProperty, sliderCenter.value);
            }
        }

        Label {
            text: qsTr('Bandwidth')
            Layout.alignment: Qt.AlignRight
        }

        Shotcut.SliderSpinner {
            id: sliderBandwidth

            minimumValue: 5
            maximumValue: 21600
            suffix: ' Hz'
            onValueChanged: updateFilter(bandwidthProperty, value, bandwidthKeyframesButton, getPosition())
        }

        Shotcut.UndoButton {
            onClicked: sliderBandwidth.value = 322
        }

        Shotcut.KeyframesButton {
            id: bandwidthKeyframesButton

            onToggled: {
                enableControls(true);
                toggleKeyframes(checked, bandwidthProperty, sliderBandwidth.value);
            }
        }

        Label {
            text: qsTr('Rolloff rate')
            Layout.alignment: Qt.AlignRight
        }

        Shotcut.SliderSpinner {
            id: sliderStages

            minimumValue: 1
            maximumValue: 10
            onValueChanged: updateFilter(stagesProperty, value, stagesKeyframesButton, getPosition())
        }

        Shotcut.UndoButton {
            onClicked: sliderStages.value = 1
        }

        Shotcut.KeyframesButton {
            id: stagesKeyframesButton

            onToggled: {
                enableControls(true);
                toggleKeyframes(checked, stagesProperty, sliderStages.value);
            }
        }

        Label {
            text: qsTr('Dry')
            Layout.alignment: Qt.AlignRight
        }

        Shotcut.SliderSpinner {
            id: sliderWetness

            minimumValue: 0
            maximumValue: 100
            decimals: 1
            label: qsTr('Wet')
            suffix: ' %'
            onValueChanged: updateFilter(wetnessProperty, value / maximumValue, wetnessKeyframesButton, getPosition())
        }

        Shotcut.UndoButton {
            onClicked: sliderWetness.value = sliderWetness.maximumValue
        }

        Shotcut.KeyframesButton {
            id: wetnessKeyframesButton

            onToggled: {
                enableControls(true);
                toggleKeyframes(checked, wetnessProperty, sliderWetness.value / sliderWetness.maximumValue);
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }

    Connections {
        function onChanged() {
            setControls();
        }

        function onInChanged() {
            updateSimpleKeyframes();
        }

        function onOutChanged() {
            updateSimpleKeyframes();
        }

        function onAnimateInChanged() {
            updateSimpleKeyframes();
        }

        function onAnimateOutChanged() {
            updateSimpleKeyframes();
        }

        function onPropertyChanged(name) {
            setControls();
        }

        target: filter
    }

    Connections {
        function onPositionChanged() {
            setControls();
        }

        target: producer
    }
}
