({
	registerUser : function(component, event, helper) {
        //event.perventDefault();
        var navService =component.find("navService");
        var pageReference ={
            type : "comm__namedPage",
            attributes :{
                name : "Home"
            },
        }
        navService.navigate(pageReference);
	},
    /*
    handlelogin : function(component, event, helper){
        var navService = component.find("navService");
        var pageReference = {
            type : "comm__namedPage",
            attributes : {
                name : "Login"
            },
        }
        navService.navigate(pageReference);
    },
    */
    handlelogin : function(component, event, helper){
        var navService = component.find("navService");
        var pageReference = {
            type : "comm__loginPage",
            attributes : {
                actionName : "login"
            },
        }
        navService.navigate(pageReference);
    }
})