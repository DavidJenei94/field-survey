import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Position;

// Properties
var apiUrlProp as String = "";
var apiKeyProp as String = "";
var option1Prop as String = "";
var option2Prop as String = "";

// option count (eg. if 2nd is empty, it will be just 1)
var optionCount = 1;
// track if survey is in progress for Start/PX display
var surveyInProgress as Boolean = false;
// record count for survey points
var recordCount as Number = 0;
// Position info
var position as Position.Location?;

class FieldSurveyApp extends Application.AppBase {

    private var _accuracy as Number = -1;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }

    //! Update the current position
    //! @param info Position information
    public function onPosition(info as Info) as Void {
        if (info.accuracy != _accuracy) {
            _accuracy = info.accuracy;
            WatchUi.requestUpdate();
        }
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        setProperties();
        var view = new FieldSurveyView();
        return [ view, new FieldSurveyDelegate(view) ];
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() as Void {
        setProperties();
        WatchUi.requestUpdate();
    }

    // Set properties from the settings
    private function setProperties() as Void {
        // Storage available from API level 2.4.0
        apiUrlProp = Properties.getValue("api_url_prop");
        apiKeyProp = Properties.getValue("api_key_prop");
        option1Prop = Properties.getValue("option_1_prop");
        option2Prop = Properties.getValue("option_2_prop");

        optionCount += !option2Prop.equals("") ? 1 : 0;
    }
}

function getApp() as FieldSurveyApp {
    return Application.getApp() as FieldSurveyApp;
}

function isApiUrlSet() as Boolean {
    return !apiUrlProp.equals("");
}

function isGpsValid() as Boolean {
    return Position.getInfo().accuracy >= Position.QUALITY_USABLE;
}