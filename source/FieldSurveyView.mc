import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Position;
import Toybox.Timer;

class FieldSurveyView extends WatchUi.View {

    // "Selected" lines
    var startSelected as Drawable?;
    var option1_1Selected as Drawable?;
    var option1_2Selected as Drawable?;
    var option2_2Selected as Drawable?;
    var endSelected as Drawable?;

    // PX text
    var point as Text?;
    // Option labels
    var option1_1Label as Text?;
    var option1_2Label as Text?;
    var option2_2Label as Text?;

    // No GPS dot counter
    var noGpsDotCounter = 1;

    function initialize() {
        View.initialize();

        // Timer for No GPS "..."
        var dotTimer = new Timer.Timer();
        dotTimer.start(method(:dotTimerCallback), 1000, true);
    }

    // Load your resources here
    function onLayout(dc as Graphics.Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
        
        startSelected = View.findDrawableById("StartSelected");
        option1_1Selected = View.findDrawableById("Option1_1Selected");
        option1_2Selected = View.findDrawableById("Option1_2Selected");
        option2_2Selected = View.findDrawableById("Option2_2Selected");
        endSelected = View.findDrawableById("EndSelected");

        if (System.getDeviceSettings().isTouchScreen) {
            startSelected.setVisible(false);
        }
        option1_1Selected.setVisible(false);
        option1_2Selected.setVisible(false);
        option2_2Selected.setVisible(false);
        endSelected.setVisible(false);

        var divider1 = View.findDrawableById("Divider1");
        if (optionCount == 2) {
            divider1.setVisible(true);
        } else {
            divider1.setVisible(false);
        }

    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Graphics.Dc) as Void {

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        var startSelectionText = !surveyInProgress ? "Start" : "P" + (recordCount + 1);
        if (!isGpsValid()) {
            startSelectionText = "No GPS";
            if (noGpsDotCounter == 3) {
                startSelectionText += "...";
            } else if (noGpsDotCounter == 2) {
                startSelectionText += "..";
            } else {
                startSelectionText += ".";
            }
        } else if (!isApiUrlSet()) {
            startSelectionText = "No API Url";
        }

        point = new WatchUi.Text({
            :text => startSelectionText,
            :color => Graphics.COLOR_WHITE,
            :font => Graphics.FONT_TINY,
            :locX => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY => dc.getHeight() * 0.08,
        });

        option1_1Label = new WatchUi.Text({
            :text => option1Prop,
            :color => Graphics.COLOR_WHITE,
            :font => Graphics.FONT_TINY,
            :locX => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY => dc.getHeight() * 0.46,
        });
        option1_2Label = new WatchUi.Text({
            :text => option1Prop,
            :color => Graphics.COLOR_WHITE,
            :font => Graphics.FONT_TINY,
            :locX => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY => dc.getHeight() * 0.32,
        });
        option2_2Label = new WatchUi.Text({
            :text => option2Prop,
            :color => Graphics.COLOR_WHITE,
            :font => Graphics.FONT_TINY,
            :locX => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY => dc.getHeight() * 0.56,
        });

        if (optionCount == 1) {
            option1_1Label.draw(dc);
        } else {
            option1_2Label.draw(dc);
            option2_2Label.draw(dc);
        }
        point.draw(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // Update dot counter
    function dotTimerCallback() as Void {
        noGpsDotCounter = (noGpsDotCounter + 1) % 3 == 0 ? 3 : (noGpsDotCounter + 1) % 3;
        WatchUi.requestUpdate();
    }
}