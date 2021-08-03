({
	saveStatus : function(component) {
        
        var selectedStatus = component.get("v.simpleRecord").Application_Status__c;
        
		component.find("recordHandler").saveRecord($A.getCallback(function(saveResult) {
            console.log(saveResult.state);
            $A.util.toggleClass(component.find("mySpinner"), "slds-hide");
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT")
            {
                component.set("v.showUpdateButton",false);
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Application Status updated to " + selectedStatus + ".",
                    "type": "success"
                });             
                toastEvent.fire();
                component.set("v.previousStatus",component.get("v.simpleRecord.Application_Status__c"));
                $A.get('e.force:refreshView').fire();
                
            } else if (saveResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
                var toastEvent = $A.get("event.force:showToast");
                var errMsg = saveResult.error[0].message;
                toastEvent.setParams({ "type": "error", "message": errMsg });
                toastEvent.fire();
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
        }))
	}
})