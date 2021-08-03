({
    
    handleError: function(component, event, helper) {
        component.set("v.isselected",true);
    },
    
    handleSuccess : function(component, event, helper) {
        
        
        component.find('notifLib').showToast({
            "variant": "success",
            "message": "Submitted successfully"
        });
        
    }
})