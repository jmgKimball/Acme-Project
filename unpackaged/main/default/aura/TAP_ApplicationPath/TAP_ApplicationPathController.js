({
    /*******************************************************************************************************
     * @description initialize the component, which is checking access on application.
     *******************************************************************************************************/
   
    doInit : function (component, event, helper) {
        component.set("v.showUpdateButton",false);
        var action=component.get('c.checkAccessesOnApplication');
        action.setParams({
            "recordId":component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
               var result= response.getReturnValue();
                if(result.hasEditAccess === true) {
                    component.set("v.isStatusEditable", true);
                }
            }   
        });
        $A.enqueueAction(action);
    },
    
    /*******************************************************************************************************
     * @description handle select hold the previous status value of application.And if Status is "Rejected",
     * rejection comment will be calculated.For this, calculateRejectionComment method is called from server 
     * side controller. 
     *******************************************************************************************************/
    handleSelect : function (component, event, helper) {
        var stepName = event.getParam("detail").value;
        if(!component.get("v.previousStatus")) {
            component.set("v.previousStatus",component.get("v.simpleRecord.Application_Status__c"));
        }
        component.set("v.simpleRecord.Application_Status__c", stepName);
        if(stepName === 'Rejected'){
            if(!component.get("v.simpleRecord.Rejection_Reason__c")) {
                let action=component.get('c.calculateRejectionComment');
                action.setParams({
                    "recordId":component.get("v.recordId")
                });
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        if(response.getReturnValue()) {
                            component.set("v.simpleRecord.Rejection_Reason__c",response.getReturnValue());
                        }
                    }
                    
                });
                
                $A.enqueueAction(action);
            }
        }
        if(component.get("v.previousStatus") !== stepName) {
            component.set("v.showUpdateButton",true);
        } else {
            component.set("v.showUpdateButton",false);
        }
    },
    
    handleCancel : function (component, event, helper) {
        
        component.set("v.showUpdateButton",false);
        $A.get('e.force:refreshView').fire();
    },
    
     /*********************************************************************************************************
     * @description handle save will check selected application status. For approved status, it will call 
     * isCareProgramSuggested method from apex controller.For rejected status it will ask and save the rejection reason.
     * For other status, status will be saved.'Approved''Rejected'$Label.c.Application_Status_Approved TAP_Constants.APPLICATION_STATUS_REJECTED
     **********************************************************************************************************/
    
    handleSave : function (component, event, helper) {
        $A.util.toggleClass(component.find("mySpinner"), "slds-hide");
        let selectedStatus = component.get("v.simpleRecord").Application_Status__c||$A.get("$Label.c.Application_Status_Approved")||$A.get("$Label.c.Application_Status_Rejected");
                             
        if(selectedStatus !== $A.get("$Label.c.Application_Status_Rejected") && component.get("v.simpleRecord.Rejection_Reason__c")) {
            component.get("v.simpleRecord").Rejection_Reason__c = undefined;
        }
        if(selectedStatus === $A.get("$Label.c.Application_Status_Approved")) {
            var action=component.get('c.isCareProgramSuggested');
            action.setParams({
                "recordId":component.get("v.recordId"),
                "careProgramId":component.get("v.simpleRecord").Care_Program__c
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    if(response.getReturnValue()) {
                        helper.saveStatus(component);
                    } else {
                        component.set("v.isModalOpen", true);
                    }
                }
                
            });
            
            $A.enqueueAction(action);
        } else {
            helper.saveStatus(component);
        }        
    },
    closeModel: function(component, event, helper) {
      component.set("v.simpleRecord.Select_non_suggested_Care_Program__c",false);
      component.set("v.isModalOpen", false);
      $A.util.toggleClass(component.find("mySpinner"), "slds-hide");
   },
  
   continueToSave: function(component, event, helper) {
        
       component.set("v.simpleRecord.Select_non_suggested_Care_Program__c",true);
       helper.saveStatus(component);
      component.set("v.isModalOpen", false);
   },
})