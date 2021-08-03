({
    myAction : function(component, event, helper) {
        
    },
    
    handleError: function (cmp, event, helper) {
        cmp.find('notifLib').showToast({
            "title": "Something has gone wrong!",
            "message": event.getParam("message"),
            "variant": "error"
        });
    },
    
    doInit: function(component, event, helper) {
        // Prepare a new record from template
        component.find("applicationRecordCreator").getNewRecord(
            "Application__c", // sObject type (entityAPIName)
            null,      // recordTypeId
            false,     // skip cache?
            $A.getCallback(function() {
                var rec = component.get("v.newApplication");
                var error = component.get("v.newApplicationError");
                if(error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                }
                else {
                    console.log("Record template initialized: " + rec.sobjectType);
                }
            })
        );
    },
    
    handleSubmit : function(component, event, helper) {
        
        event.preventDefault(); // stop form submission
        var eventFields = event.getParam("fields");
        eventFields[component.set("v.simpleNewApplication.Id")] = component.get("v.recordId");
        var result = component.get("v.simpleNewApplication.Id");
        component.find('applicationRecordSave').submit(eventFields);
        
        var urlEvent = $A.get("e.force:navigateToURL");
		urlEvent.setParams({ "url": 'https://dev-komen.cs69.force.com/s/recordlist/Application__c/00B2D0000023vEkUAI' });   // Pass your community URL
		urlEvent.fire();
        /*
		var payload = event.getParams().response; 
        var AcctId = component.get("v.recordId");
        var sObectEvent = $A.get("e.force:navigateToSObject");
        sObectEvent .setParams({
            "recordId": AcctId,
            "slideDevName": "detail"
        });
    sObectEvent.fire();
    */
    
    },
    
    handleCancel: function(component, event, helper) {
        component.destroy();
        // helper.showHide(component);
        // event.preventDefault();
       
    } 
    
    
})
/*
    handleSaveApplication: function(component, event, helper) {
        if(helper.validateContactForm(component)) {
            component.set("v.simpleNewApplication.Id", component.get("v.recordId"));
            component.find("applicationRecordSave").saveRecord(function(saveResult) {
            //component.find("applicationRecordSave").submit(function(saveResult) {
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    // record is saved successfully
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Saved",
                        "message": "The record was saved."
                    });
                    resultsToast.fire();

                } else if (saveResult.state === "INCOMPLETE") {
                    // handle the incomplete state
                    console.log("User is offline, device doesn't support drafts.");
                } else if (saveResult.state === "ERROR") {
                    // handle the error state
                    console.log('Problem saving contact, error: ' + 
                                 JSON.stringify(saveResult.error));
                } else {
                    
                }
            });
        }
    },
   
    handleCancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
   
   
 
    
    handleSaveApplication : function(component, event, helper) {
        component.set("v.simpleNewApplication.Id", component.get("v.recordId"));
        component.find("applicationRecordSave").submit();
        
        helper.showHide(component);
            
    },
    */