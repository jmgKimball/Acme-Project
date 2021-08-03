({
    init : function(component, event, helper) {
        var action=component.get('c.checkAccessOnApplication');
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result= response.getReturnValue();
                if(result.hasEditAccess === true) {
                    component.set("v.hasEditAccess", true);
                }
            }
        });
        $A.enqueueAction(action);
        helper.loadCarePrograms(component);
    },
    onLoad : function(component, event, helper) {
        
        var program = component.get('v.existingCareProgram');
        console.log(program);
        if(program){
            component.set("v.showCareProgram", true);
            component.set("v.IsCareProgramavailable", true);
        } else {
            component.set("v.showCareProgram", false);
            component.set("v.IsCareProgramavailable", false);
        }
    },
    handleProgramTypeChange: function(component, event){
        component.set("v.careProgram",component.get('v.careProgramWrapper')[event.getParam("value")]);
        $A.get('e.force:refreshView').fire();
    },
    /***********************************************************************************************************
    *@description It updates the selected care program and handles if there is no program selected.
    ***********************************************************************************************************/
   
       updateSelectedCareProgram  : function (component, event, helper) {
        if(event.getParam('selectedRows')[0]) {
            component.set('v.CareProgramId', event.getParam('selectedRows')[0].Id);
            component.set('v.CareProgramRecord', event.getParam('selectedRows')[0]);
            component.find('saveButton').set('v.disabled',false);
        } else {
            component.find('saveButton').set('v.disabled',true);
        }
    },

    
    handleSave : function(component, event, helper){
        $A.util.toggleClass(component.find("mySpinner"), "slds-hide");
        var fields = {};
        fields.recordId = component.get("v.recordId");
        fields.Care_Program__c = component.get('v.CareProgramId');
        component.find('careProgram').submit(fields);
        $A.get('e.force:refreshView').fire();
    },
    handleSuccess: function(component, event, helper) {
    	component.set("v.IsCareProgramavailable",true);
        component.set("v.showCareProgram",true);
        component.set("v.existingCareProgram",component.get('v.CareProgramRecord'));
        var toastEvent = $A.get("e.force:showToast");  
        toastEvent.setParams({
            "type" : "Success",
            "message": "Care Program updated successfully!"
        });
        toastEvent.fire();
        var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": component.get("v.recordId")
            });
            navEvt.fire();
	},

    handleChange: function(component, event, helper){
        let wrapper = component.get("v.careProgramWrapper");
        if(!wrapper) {
            helper.loadCarePrograms(component);
        } else {
            component.set("v.programType","suggested");
            component.set("v.careProgram",wrapper.suggested);
            component.set("v.showCareProgram",false);
            $A.get('e.force:refreshView').fire();
        }
    },
    
    handleBack : function(component, event, helper){
        component.set("v.showCareProgram",true);
    }
})