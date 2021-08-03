/**
 * Created by cwico@tractionondemand.com on 2020-11-30.
 */
({
	doInit: function (cmp, event, helper) {
		// MyKomen will pass a value of 1 for users who are authenticated but not yet opted-in to MyKomen Health
		// In MyKomen, this parameter will not exist and thus will default to false
		var authParam = new URL(window.location.href).searchParams.get("c__authenticated");
		if(authParam === "1") {
			cmp.set("v.isMyKomenAuthenticated", true);
		}

		var action = cmp.get("c.getTemplateData");
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var templateData = response.getReturnValue();
				cmp.set("v.isGuest", templateData.isGuest);
				cmp.set("v.myKomenURL", templateData.myKomenURL);
			} else if (state === "ERROR") {
				var errors = response.getError();
				console.error(errors);

				if(errors[0] && errors[0].message) {
					var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						"title": "Error",
						"type": "error",
						"message": errors[0].message
					});
					toastEvent.fire();
				}
			}
		});

		$A.enqueueAction(action);
	},

	gotoLogin: function (cmp, event, helper) {
		var myKomenURL = cmp.get("v.myKomenURL");

		if(myKomenURL) { // We are in MyKomen Health, use the "classic" login url to redirect to SSO
			let loginLink = '/login?startURL=';

			// If we're on a subpage, set the path so we can return to the same page
			let currentPath = helper.getCurrentUrlPath();
			if ( currentPath ) {
				loginLink += currentPath;
			} else {
				loginLink += '/s/';
			}

			window.location.href = loginLink;

		} else { // We are in MyKomen, use the lightning community login url
			var pageRef = {
				type: 'comm__loginPage',
				attributes: {
					actionName: 'login'
				}
			}

			var navService = cmp.find("navService");
			navService.navigate(pageRef);
		}
	},

	gotoRegistration: function (cmp, event, helper) {
		var myKomenURL = cmp.get("v.myKomenURL");
		if(myKomenURL) { // We are in MyKomen Health, use the external registration URL

			let registerLink = myKomenURL + "login/SelfRegister";
			// URL Params so NPSP knows we've come from HC, and what page we're on
			registerLink += "?c__mkhRef=1";
			let currentPath = helper.getCurrentUrlPath();
			if ( currentPath ) {
				registerLink += "&c__refPath=" + currentPath;
			}
			window.location.href = registerLink;

		} else { // We are in MyKomen, open the local Register page
			window.location.href = "/s/login/SelfRegister"
		}
	},

	gotoOptIn: function(cmp) {
		var myKomenURL = cmp.get("v.myKomenURL");
		window.location.href = myKomenURL + "HealthOptIn";
	}
});