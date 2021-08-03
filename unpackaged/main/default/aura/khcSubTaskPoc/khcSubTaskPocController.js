/**
 * Created by vupneja on 11/20/2020.
 */

({
    openTabWithSubtab : function(component, event, helper) {
        console.log("*** Test SubTask" , component.find("RecordId"));
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            //url: '/lightning/r/Account/0012f00000aDpdzAAC/view',
            //recordId: '0012f00000aDpdzAAC',
            recordId : component.get("v.RecordId"),
            focus: true
        }).then(function(response) {
            workspaceAPI.openSubtab({
                parentTabId: response,
                //url: '/lightning/r/Case/5002f0000081ojqAAA/view',
                //recordId: '5002f0000081ojqAAA',
                recordId : component.get("v.SubRecordId"),
                focus: true
            });
        })
            .catch(function(error) {
                console.log(error);
            });
    }
});