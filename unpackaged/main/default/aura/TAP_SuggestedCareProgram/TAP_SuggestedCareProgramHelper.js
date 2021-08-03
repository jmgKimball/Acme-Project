({
	loadCarePrograms : function(component) {
        
        var action=component.get('c.loadPrograms');
        action.setParams({
            "recordId":component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result= response.getReturnValue();
                
                component.set("v.careProgram",result.suggested);
                if(result.existing) {
                    component.set("v.existingCareProgram",result.existing[0]);
                }
                component.set("v.careProgramWrapper", result);
                $A.get('e.force:refreshView').fire();
            }   
        });
        $A.enqueueAction(action);
    }
})