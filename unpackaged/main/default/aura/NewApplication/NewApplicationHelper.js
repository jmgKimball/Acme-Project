({        
        
         
    validateContactForm: function(component) {
        var validContact = true;
         // Show error messages if required fields are blank
        var allValid = component.find('applicationRecordSave').reduce(function (validFields, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validFields && inputCmp.get('v.validity').valid;
        }, true);
        if (allValid) {
            // Verify we have an account to attach it to
            var newApplication = component.get("v.newApplication");
            if($A.util.isEmpty(newApplication)) {
                validContact = false;
                console.log("Quick action context doesn't have a valid account.");
            }
        return(validContact);
            
        }  
	},
    
    showHide : function(component) {
        var editForm = component.find("applicationRecordSave");
       $A.util.toggleClass(editForm, "slds-hide");
    }
})