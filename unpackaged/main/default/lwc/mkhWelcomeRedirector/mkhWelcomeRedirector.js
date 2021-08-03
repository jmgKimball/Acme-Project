/**
 * Component that sends users to the welcome page on first login
 *
 * @author Grant Adamson, Traction on Demand
 * @date 2020-09-14
 */
import {LightningElement, wire} from 'lwc';
import Id from '@salesforce/user/Id';
import {getFieldValue, getRecord} from 'lightning/uiRecordApi';
import MYKOMEN_HEALTH_ONBOARDING_STATUS from '@salesforce/schema/User.MyKomen_Health_Onboarding_Status__c';
import {NavigationMixin} from "lightning/navigation";

export default class MkhWelcomeRedirector extends NavigationMixin(LightningElement) {
    @wire(getRecord, {recordId: Id, fields: [MYKOMEN_HEALTH_ONBOARDING_STATUS]})
    handleUserRecord({data: user, error}) {
        if(this.isInBuilder()) { // Don't fire the redirect if we are in the builder interface rather than the real site
            return;
        }

        if (error) {
            console.error(error.body.message);
            return;
        }

        if (user && this.userHasNotCompletedOnboarding(user)) {
            this.navigateToWelcomePage();
        }
    }

    isInBuilder() {
        const hostname = window.location.hostname.toLowerCase();
        return hostname.indexOf("sitepreview") >= 0 || hostname.indexOf("livepreview") >= 0;
    }

    userHasNotCompletedOnboarding(user) {
        return !getFieldValue(user, MYKOMEN_HEALTH_ONBOARDING_STATUS);
    }

    navigateToWelcomePage() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Welcome__c'
            }
        });
    }
}