/**
 * @description JS controller for mkFileUploadWrapper
 * @author      Scott Taylor, Traction on Demand
 * @date        2020-10-23
 */
({
    /**
     * @description Close a parent quick action modal
     * @author      Scott Taylor, Traction on Demand
     * @date        2020-10-23
     *
     * @param component Component reference
     * @param event     Event reference
     */
    closeAction : function(component, event) {
        $A.get("e.force:closeQuickAction").fire();
    }
})