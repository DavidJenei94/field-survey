import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Communications;

class FieldSurveyMenuDelegate extends WatchUi.MenuInputDelegate {

    // Survey data and names (extracted from storage)
    var surveyNames as Array<String> = [];
    var surveyData as Array<String> = [];

    function initialize() {
        MenuInputDelegate.initialize();
    }

    // Called when a menu item is selected
    function onMenuItem(item as Symbol) as Void {
        if (item == :item_sync) {
            var dataValue = Application.Storage.getValue("data");
            if (dataValue == null || dataValue.equals("")) {
                return;
            }

            extractData(dataValue);

            var surveys = [];
            for (var i = 0; i < surveyData.size(); i++) {
                var survey = {
                    "name" => surveyNames[i],
                    "data" => surveyData[i]
                };
                surveys.add(survey);
            }

            var url = apiUrlProp;
            var params = {
                "surveys" => surveys,
                "apiKey" => apiKeyProp,
            };

            var options = {
                :method => Communications.HTTP_REQUEST_METHOD_POST,
                :headers => {
                    "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON
                },
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_TEXT_PLAIN
            };
            Communications.makeWebRequest(
                url, 
                params,
                options,
                method(:onPostComplete)
            );
        } else if (item == :item_clear) {
            Application.Storage.clearValues();
            surveyData = [];
            surveyNames = [];
        }
    }
    
    // Called when the POST request is complete
    function onPostComplete(responseCode as Number, data as Dictionary) as Void {
        if (responseCode == 200) {
            Application.Storage.clearValues();
            surveyData = [];
            surveyNames = [];
        } else {
            // Handle error
        }
    }

    // Extract survey data from the input into class variables
    function extractData(input as String) as Void {
        var fixedPart = "FieldSurvey_";
        var delimiter = "__FS__";
        var startIndex = 0;

        while (true) {
            // Find the fixed part
            var fixedPartIndex = input.find(fixedPart);
            if (fixedPartIndex == null) {
                break;
            }

            // Extract the date part
            var nameStartIndex = fixedPartIndex;
            var dateEndIndex = input.substring(nameStartIndex, input.length()).find(delimiter);
            if (dateEndIndex == null) {
                break;
            }
            dateEndIndex += nameStartIndex; // Adjust to the original string index
            var namePart = input.substring(nameStartIndex, dateEndIndex);
            surveyNames.add(namePart);

            // Extract the data part
            var dataStartIndex = dateEndIndex + delimiter.length();
            var dataEndIndex = input.substring(dataStartIndex, input.length()).find(fixedPart);
            if (dataEndIndex == null) {
                dataEndIndex = input.length();
            } else {
                dataEndIndex += dataStartIndex; // Adjust to the original string index
            }
            var dataPart = input.substring(dataStartIndex, dataEndIndex);
            surveyData.add(dataPart);

            // Update the start index for the next iteration
            startIndex = dataEndIndex;
            input = input.substring(startIndex, input.length()); // Adjust the input string to start from the new index
        }
    }
}