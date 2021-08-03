/**
 * Created by vupneja on 11/20/2020.
 */

({
    invoke : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            recordId : component.get("v.RecordId"),
            focus: true
        }).then(function(response) {
            workspaceAPI.openSubtab({
                parentTabId: response,
                recordId : component.get("v.SubRecordId"),
                focus: true
            });
        }).catch(function(error) {
                console.log(error);
          });
    }
});