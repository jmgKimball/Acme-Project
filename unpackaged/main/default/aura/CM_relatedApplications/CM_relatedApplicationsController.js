({
    
   onLoad : function(component, event, helper) {
        component.set('v.mycolumns', [
            {label: 'Name', fieldName: 'appUrl', type: 'url', 
            typeAttributes: {label: { fieldName: 'Name' }, target: 'Application__c'}},
            
            
        ]);
        var action = component.get("c.relatedApplicationlist");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var records =response.getReturnValue();
                records.forEach(function(record){
                    record['appUrl']='/s/detail/' + record['Id'];
                });
                component.set("v.applist", records);
            }
        });
        $A.enqueueAction(action);
    }


})