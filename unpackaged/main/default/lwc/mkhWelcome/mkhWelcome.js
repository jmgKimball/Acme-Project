/**
 * Custom opt-in component that authorizes a user to access MyKomen Health via SSO
 * Users are redirected here if their SSO login to MyKomen Health is rejected due to not being opt-ed in yet
 *
 * @author Grant Adamson, Traction on Demand
 * @date 2020-09-10
 */
import {LightningElement, track, wire} from 'lwc';
import {NavigationMixin} from "lightning/navigation";
import {updateRecord} from 'lightning/uiRecordApi';
import {getPicklistValues} from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getContactIdForUser from "@salesforce/apex/KHC_AccountService.getContactIdForUser";
import getUserRecord from "@salesforce/apex/KHC_AccountService.getUserRecord";
import MYKOMEN_HEALTH_RELATIONSHIP from '@salesforce/schema/Contact.Relationship_To_Cancer__c';
import MYKOMEN_HEALTH_INTEREST from '@salesforce/schema/Contact.Breast_Health_topics_on_your_mind__c';
import MYKOMEN_HEALTH_ONBOARDING_STATUS from '@salesforce/schema/User.MyKomen_Health_Onboarding_Status__c';
import MyKomenHealthAssets from '@salesforce/resourceUrl/MyKomenHealthAssets';

import relationship from './relationship.html';
import onboarding from './onboarding.html';
import userId from "@salesforce/user/Id";

import REMIND_ME_LATER_LABEL from "@salesforce/label/c.Remind_Me_Later";
import BACK_TO_MY_ACCOUNT from "@salesforce/label/c.Back_to_My_Account";
import CONTINUE_LABEL from "@salesforce/label/c.Continue";
import RELATIONSHIP_PAGE_HEADER_TEXT from "@salesforce/label/c.Relationship_Page_Header_Text";
import RELATIONSHIP_PAGE_HEADER_DETAIL from "@salesforce/label/c.Relationship_Page_Header_Detail";
import WHY_AM_I_BEING_ASKED_THIS_LABEL from "@salesforce/label/c.Why_am_I_being_asked_this";
import ONBOARDING_STEPS_START_LABEL from "@salesforce/label/c.Onboarding_Steps_Start";
import ONBOARDING_STEPS_END_LABEL from "@salesforce/label/c.Onboarding_Steps_End";
import STEP_LABEL from "@salesforce/label/c.Step";
import OF_LABEL from "@salesforce/label/c.of";
import CREATE_MY_HEALTH_PROFILE_LABEL from "@salesforce/label/c.Create_My_Health_Profile";
import HEALTH_PROFILE_DESCRIPTION from "@salesforce/label/c.Health_Profile_Description";
import ADD_MY_FAMILY_HISTORY_LABEL from "@salesforce/label/c.Add_my_family_History";
import FAMILY_HISTORY_DESCRIPTION from "@salesforce/label/c.Family_History_Description";
import ADD_CARE_PROVIDERS_LABEL from "@salesforce/label/c.Add_Care_Providers";
import CARE_PROVIDERS_DESCRIPTION from "@salesforce/label/c.Care_Providers_Description";
import ADD_MEDICATIONS_LABEL from "@salesforce/label/c.Add_Medications";
import MEDICATIONS_DESCRIPTION from "@salesforce/label/c.Medications_Description";
import HEALTH_INTEREST_LABEL from "@salesforce/label/c.What_Breast_Health_Topics_Are_On_Your_Mind";
import ERROR_LABEL from "@salesforce/label/c.Error";

const COMPLETED_STATUS = "Completed";
const SKIPPED_STATUS = "Skipped";
const BUTTON_PRESSED_CSS_CLASS = "slds-is-pressed";

const ONBOARDING_STEP_DATA = [
    {
        actionLabel: CREATE_MY_HEALTH_PROFILE_LABEL,
        actionTarget: 'My_Health_Profile',
        imageURL: MyKomenHealthAssets + "/images/healthProfile@2x.png",
        descriptionText: HEALTH_PROFILE_DESCRIPTION
    },
    {
        actionLabel: ADD_MY_FAMILY_HISTORY_LABEL,
        actionTarget: 'My_Family_Health_History',
        imageURL: MyKomenHealthAssets + "/images/familyHistory@2x.png",
        descriptionText: FAMILY_HISTORY_DESCRIPTION
    },
    {
        actionLabel: ADD_CARE_PROVIDERS_LABEL,
        actionTarget: 'My_Providers',
        imageURL: MyKomenHealthAssets + "/images/careProviders@2x.png",
        descriptionText: CARE_PROVIDERS_DESCRIPTION
    },
    {
        actionLabel: ADD_MEDICATIONS_LABEL,
        actionTarget: 'My_Medications',
        imageURL: MyKomenHealthAssets + "/images/medications@2x.png",
        descriptionText: MEDICATIONS_DESCRIPTION
    },
];

export default class MkhWelcome extends NavigationMixin(LightningElement) {
    relationshipPageHeaderText = RELATIONSHIP_PAGE_HEADER_TEXT;
    relationshipPageHeaderDetail = RELATIONSHIP_PAGE_HEADER_DETAIL;
    whyAmIBeingAskedThisLabel = WHY_AM_I_BEING_ASKED_THIS_LABEL;
    onboardingStepsStartLabel = ONBOARDING_STEPS_START_LABEL;
    onboardingStepsEndLabel = ONBOARDING_STEPS_END_LABEL;
    healthInterestLabel = HEALTH_INTEREST_LABEL;
    stepLabel = STEP_LABEL;
    ofLabel = OF_LABEL;
    continueLabel = CONTINUE_LABEL;
    remindMeLaterLabel = BACK_TO_MY_ACCOUNT;
    selectedRelationships;
    activePage = relationship;
    onboardingStep = 0;

    @track relationships = [];
    @track healthInterestsOptions;
    healthInterests;
    selHealthInterests;

    @wire(getPicklistValues, {
        fieldApiName: MYKOMEN_HEALTH_RELATIONSHIP,
        recordTypeId: "012000000000000AAA" // Master Record Type
    })
    handlePicklistValues({data, error}) {
        if (error) {
            this.showToastMessage( ERROR_LABEL, error.body.message, 'error');
        }

        if (data) {
            this.relationships = data.values;
        }
    }

    @wire(getPicklistValues, {
        fieldApiName: MYKOMEN_HEALTH_INTEREST,
        recordTypeId: "012000000000000AAA" // Master Record Type
    })
    getHealthInterestsOptions({data, error}) {
        
        if (error) {
            this.showToastMessage( ERROR_LABEL, error.body.message, 'error');
        }

        if (data) {
            this.healthInterestsOptions = data.values;
        }
    }

    @wire(getUserRecord, {userId : userId} )
    getUserData({data, error}){
        if (error) {
            this.showToastMessage( ERROR_LABEL, error.body.message, 'error');
        }

        if (data) {
            let relationshipValues = data.Contact.Relationship_To_Cancer__c;
            let selHealthInterests = data.Contact.Breast_Health_topics_on_your_mind__c;
            if(selHealthInterests != null){
                this.selHealthInterests = selHealthInterests.split(';');
            }else{
                this.selHealthInterests = '';
            }
            if(relationshipValues != null){
                this.selectedRelationships = relationshipValues.split(';');
            }
        }
    }

    get currentStep() {
        return this.onboardingStep + 1;
    }

    get totalSteps() {
        return ONBOARDING_STEP_DATA.length;
    }

    get actionLabel() {
        return ONBOARDING_STEP_DATA[this.onboardingStep].actionLabel;
    }

    get imageURL() {
        return ONBOARDING_STEP_DATA[this.onboardingStep].imageURL;
    }

    get descriptionText() {
        return ONBOARDING_STEP_DATA[this.onboardingStep].descriptionText;
    }

    render() {
        return this.activePage;
    }

    renderedCallback(){
        
        if( this.selectedRelationships ){
            this.selectedRelationships.forEach( selRel => {
                let elm = this.template.querySelector( `[data-value="${selRel}"]` );
                elm.classList.add(BUTTON_PRESSED_CSS_CLASS);
            })
        }
        
    }

    handleChangeInterest(e) {
        let healthInterest = '';
        if( e.detail.value ){
            healthInterest = e.detail.value.join(";");
        }
        this.healthInterests = healthInterest;
    }

    onRelationshipToggle(event) {
        const button = event.target;

        if (button.classList.contains(BUTTON_PRESSED_CSS_CLASS)) {
            button.classList.remove(BUTTON_PRESSED_CSS_CLASS);
        } else {
            button.classList.add(BUTTON_PRESSED_CSS_CLASS);
        }

        this.selectedRelationships = this.getSelectedRelationships();
    }

    getSelectedRelationships() {
        const result = [];

        const buttons = this.template.querySelectorAll("." + BUTTON_PRESSED_CSS_CLASS);
        buttons.forEach(button => {
            result.push(button.dataset.value);
        });

        return result;
    }

    async onRelationshipContinue() {
        await this.updateContact();
        //this.switchToOnboarding();
        // TEMPORARILY REMOVING ONBOARDING LOGIC. ONLY THE RELATIONSHIP TO BREAST CANCER SCREEN WILL BE RENDERED
        await this.saveOnboardingStatus(COMPLETED_STATUS);
        this.navigateToHomePage();
    }

    async updateContact() {
        const contactId = await getContactIdForUser({userId});

        const record = {
            fields: {
                Id: contactId
            }
        };
        record.fields[MYKOMEN_HEALTH_RELATIONSHIP.fieldApiName] = this.getSelectedRelationships().join(";");
        record.fields[MYKOMEN_HEALTH_INTEREST.fieldApiName] = this.healthInterests;
        try {
            await updateRecord(record);
        } catch(e) {
            this.showToastMessage( ERROR_LABEL, e.body.message, 'error');
        }
    }

    async onAction() {
        const pageName = ONBOARDING_STEP_DATA[this.onboardingStep].actionTarget;
        await this.saveOnboardingStatus(COMPLETED_STATUS);
        this.navigateToPage(pageName);
    }

    switchToOnboarding() {
        this.activePage = onboarding;
    }

    async onSkip() {
        await this.saveOnboardingStatus(SKIPPED_STATUS);
        // TEMPORARILY REMOVING ONBOARDING LOGIC. ONLY THE RELATIONSHIP TO BREAST CANCER SCREEN WILL BE RENDERED
        // window.scrollTo(0, 0);
        //
        // if (this.activePage === relationship) {
        //     this.activePage = onboarding;
        // } else {
        //     this.nextOnboardingStep();
        // }

        this.navigateToHomePage();
    }

    async saveOnboardingStatus(status) {
        const fields = {Id: userId};
        fields[MYKOMEN_HEALTH_ONBOARDING_STATUS.fieldApiName] = status;

        try {
            await updateRecord({fields});
        } catch (e) {
            this.showToastMessage( ERROR_LABEL, e.body.message, 'error');
        }
    }

    nextOnboardingStep() {
        if (this.onboardingStep === ONBOARDING_STEP_DATA.length - 1) {
            this.navigateToHomePage();
        } else {
            this.onboardingStep++;
        }
    }

    navigateToHomePage() {
        this.navigateToPage("Home");
    }

    navigateToPage(pageName) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: pageName
            }
        });
    }

    showToastMessage( title, message, variant ){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            }),
        );
    }
}