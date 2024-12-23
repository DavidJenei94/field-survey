import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Position;
import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;

class FieldSurveyDelegate extends WatchUi.BehaviorDelegate {

    var itemCount = 2; // selectable items on screen - Start and End by default
    var selectedIndex = 0; // Index of selected item on screen

    private var _view as FieldSurveyView;

    function initialize(view as FieldSurveyView) {
        BehaviorDelegate.initialize();
        _view = view;

        itemCount += !option1Prop.equals("") ? 1 : 0;
        itemCount += !option2Prop.equals("") ? 1 : 0;
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new FieldSurveyMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    //! @return true if handled, false otherwise: false handles the system's default actions
    function onKey(keyEvent) as Boolean {
        var key = keyEvent.getKey();
        if (key == WatchUi.KEY_UP) {
            selectedIndex = (selectedIndex - 1 + itemCount) % itemCount;
        } else if (key == WatchUi.KEY_DOWN) {
            selectedIndex = (selectedIndex + 1) % itemCount;
        } else if (key == WatchUi.KEY_START || key == WatchUi.KEY_ENTER) {
            onItemClick(selectedIndex);
        } else {
            return false;
        }

         if (optionCount == 1) {
            if (selectedIndex == 0) {
                _view.startSelected.setVisible(true);
                _view.option1_1Selected.setVisible(false);
                _view.endSelected.setVisible(false);
            } else if (selectedIndex == 1) {
                _view.startSelected.setVisible(false);
                _view.option1_1Selected.setVisible(true);
                _view.endSelected.setVisible(false);
            } else if (selectedIndex == 2) {
                _view.startSelected.setVisible(false);
                _view.option1_1Selected.setVisible(false);
                _view.endSelected.setVisible(true);
            }
        } else if (optionCount == 2) {
            if (selectedIndex == 0) {
                _view.startSelected.setVisible(true);
                _view.option1_2Selected.setVisible(false);
                _view.option2_2Selected.setVisible(false);
                _view.endSelected.setVisible(false);
            } else if (selectedIndex == 1) {
                _view.startSelected.setVisible(false);
                _view.option1_2Selected.setVisible(true);
                _view.option2_2Selected.setVisible(false);
                _view.endSelected.setVisible(false);
            } else if (selectedIndex == 2) {
                _view.startSelected.setVisible(false);
                _view.option1_2Selected.setVisible(false);
                _view.option2_2Selected.setVisible(true);
                _view.endSelected.setVisible(false);
            } else if (selectedIndex == 3) {
                _view.startSelected.setVisible(false);
                _view.option1_2Selected.setVisible(false);
                _view.option2_2Selected.setVisible(false);
                _view.endSelected.setVisible(true);
            }
        }

        WatchUi.requestUpdate();
        return true;
    }

   function onItemClick(index as Number) as Void {
        if (!isApiUrlSet() && !isGpsValid()) {
            return;
        }

        if (index == 0) {
            startSurvey();
        } else if (index == itemCount - 1) {
            endSurvey();
        } else if (index == 1) {
            addEntry1();
        } else if (index == 2) {
            addEntry2();
        }
    }

    // Add survey name and header to the storage data
    function startSurvey() as Void {
        surveyInProgress = true;
        var actualDateTime = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var timestamp = actualDateTime.year + actualDateTime.month.format("%02d") + actualDateTime.day.format("%02d") + "_" + actualDateTime.hour.format("%02d") + actualDateTime.min.format("%02d") + actualDateTime.sec.format("%02d");
        var surveyName = "FieldSurvey_" + timestamp;
       
        var entry = surveyName + "__FS__id;latitude;longitude;value;date_time";
        var existingData = Application.Storage.getValue("data");
        Application.Storage.setValue("data", existingData + entry);
    }

    // Add survey entry "Option 1" to the storage data
    function addEntry1() as Void {
        addEntry(option1Prop);
    }

    // Add survey entry "Option 2" to the storage data
    function addEntry2() as Void {
        addEntry(option2Prop);
    }

    // Add survey entry to the storage data
    function addEntry(value as String) as Void {
        var position = Position.getInfo().position.toDegrees();
        var lat = position[0].format("%.6f");
        var lng = position[1].format("%.6f");
        var actualDateTime = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var dateTime = actualDateTime.year + "-" + actualDateTime.month.format("%02d") + "-" + actualDateTime.day.format("%02d") + " " + actualDateTime.hour.format("%02d") + ":" + actualDateTime.min.format("%02d") + ":" + actualDateTime.sec.format("%02d");

        var entry = "__NL__" + recordCount + ";" + lat + ";" + lng + ";" + value + ";" + dateTime;
        var existingData = Application.Storage.getValue("data");
        Application.Storage.setValue("data", existingData + entry);
        recordCount += 1;
    }

    // End the survey - reset progress
    function endSurvey() as Void {
        recordCount = 0;
        surveyInProgress = false;
    }
}