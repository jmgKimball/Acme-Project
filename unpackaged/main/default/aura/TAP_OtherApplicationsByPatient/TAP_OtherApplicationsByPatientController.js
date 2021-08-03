({
    
    onLoad : function(component, event, helper) {
        component.set('v.mycolumns', [
            {label: 'Name', fieldName: 'appUrl', type: 'url', 
             typeAttributes: {label: { fieldName: 'Name' }, target: 'Application__c'}},
            {label: 'Application Status', fieldName: 'Application_Status__c', type: 'text'},
            {label: 'Payment Date', fieldName: 'Payment_Date__c', type: 'Date'}
            
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
                    record['appUrl']='/lightning/r/Application__c/' + record['Id'] + '/view';
                });
                component.set("v.applist", records);
            }
        });
        $A.enqueueAction(action);
    }  
})