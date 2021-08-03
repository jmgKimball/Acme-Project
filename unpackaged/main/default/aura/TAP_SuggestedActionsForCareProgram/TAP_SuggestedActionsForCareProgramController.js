({
    /*******************************************************************************************************
     * On load calls the loadProgramDetails method from apex controller.
     *For record, it sets the flags as per the Care Program
     *If there are no rule, criteria, or detail with the respective care program record Id, 
     *it shows the Next Suggested Actions check list of values 
     *******************************************************************************************************/   
    
    
    onLoad : function(component, event, helper) {
        var action=component.get('c.loadProgramDetails');
        action.setParams({
            "recordId":component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result= response.getReturnValue();
                if(result.rules && result.rules > 0) {
                    component.set("v.eligibilityRule",true);
                } else {
                    component.set("v.eligibilityRule",false);
                }
                if(result.criterias && result.criterias > 0) {
                    component.set("v.eligibilityCriteria",true);
                } else {
                    component.set("v.eligibilityCriteria",false);
                }
                if(result.details && result.details > 0) {
                    component.set("v.eligibilityDetails",true);
                } else {
                    component.set("v.eligibilityDetails",false);
                }
                component.set("v.isLoaded",true);
            } 
        });
        $A.enqueueAction(action);
    }
})