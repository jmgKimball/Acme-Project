({
/* Launch the correct flow */
  init : function (cmp) {
    var flow = cmp.find("flowData");
    flow.startFlow("Recommend_a_Resource");

  },
    /*On change listener*/
handleStatusChange : function (component, event) {    
    //alert('event.getParam '+event.getParam('status'));
    if(event.getParam('status') === "FINISHED") {
        $A.get("e.force:closeQuickAction").fire();
    }        
}


})