import { LightningElement, api, wire, track} from 'lwc';
import {isAppointmentLaterToday} from 'c/khcLwcUtils'
import getMyInformation from '@salesforce/apex/kHC_MyHeathProfileController.getMyInformation';
import updateAccount from '@salesforce/apex/kHC_MyHeathProfileController.updateAccount';
import getRedirectorData from '@salesforce/apex/MKH_MyKomenRedirectorController.getRedirectorData';
import getBloodTypePicklistValues from '@salesforce/apex/kHC_MyHeathProfileController.getBloodTypePicklistValues';
import getRelationShipValues from '@salesforce/apex/kHC_MyHeathProfileController.getRelationShipValues';
import getBreastHealthTopic from '@salesforce/apex/kHC_MyHeathProfileController.getBreastHealthTopic';

import getProvidersByPatientId from '@salesforce/apex/kHC_MyHeathProfileController.getProvidersByPatientId';
import getInsurancesByMemberId from '@salesforce/apex/kHC_MyHeathProfileController.getInsurancesByMemberId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import TYPE_OF_ASSESSMENT_LABEL from '@salesforce/label/c.Type_of_Assessment';
import DATE_OF_ASSESSMENT_LABEL from '@salesforce/label/c.Date_of_Assessment';
import RISK_LEVEL_LABEL from '@salesforce/label/c.Risk_Level';
import NOTES_RISK_ASSESSMENT_LABEL from '@salesforce/label/c.Notes_Risk_Assessment';
import MY_HEALTH_SUMMARY_LABEL from '@salesforce/label/c.My_Health_Summary';
import MANAGE_CONTACT_INFO_LABEL from '@salesforce/label/c.Manage_Contact_Information';
import MY_PROFILE_LABEL from '@salesforce/label/c.My_Profile';
import HEIGHT_LABEL from '@salesforce/label/c.Height';
import EDIT_LABEL from '@salesforce/label/c.Edit';
import BLOOD_TYPE_LABEL from '@salesforce/label/c.Blood_Type';
import ORGAN_DONOR_LABEL from '@salesforce/label/c.Organ_Donor';
import CAREGIVER_OR_CO_SURVIVOR_LABEL from '@salesforce/label/c.Caregiver_or_Co_Survivor';
import TWIN_MULTIPLE_LABEL from '@salesforce/label/c.Twin_Multiple';
import MY_FAMILY_HISTORY_LABEL from '@salesforce/label/c.My_Family_History';
import MY_HEALTH_CONDITIONS_LABEL from '@salesforce/label/c.My_Health_Conditions';
import MY_HEALTH_PROVIDER_LABEL from '@salesforce/label/c.My_Health_Provider';
import MY_MEDICATIONS_LABEL from '@salesforce/label/c.My_Medications';
import MY_IMMUNIZATIONS_LABEL from '@salesforce/label/c.My_Immunizations';
import MY_ALLERGIES_LABEL from '@salesforce/label/c.My_Allergies';
import MY_PROCEDURES_LABEL from '@salesforce/label/c.My_Procedures';
import MY_HEALTH_PROFILE_LABEL from '@salesforce/label/c.My_Health_Profile';
import HEIGHT_FT_LABEL from '@salesforce/label/c.Height_ft';
import HEIGHT_IN_LABEL from '@salesforce/label/c.Height_in';
import ARE_YOU_A_TWIN_MULTIPLE_LABEL from '@salesforce/label/c.Are_you_a_twin_multiple';
import ARE_YOU_AN_ORGAN_DONOR_LABEL from '@salesforce/label/c.Are_you_an_Organ_Donor';
import KEEPING_PROFILE_UPDATED_LABEL from '@salesforce/label/c.Keeping_Profile_Updated';
import ARE_YOU_A_CAREGIVER_OR_CO_SURVIVOR_LABEL from '@salesforce/label/c.Are_you_a_Caregiver_or_Co_Survivor';
import UPDATE_LABEL from '@salesforce/label/c.Update';
import CANCEL_LABEL from '@salesforce/label/c.Cancel';
import ERROR_LABEL from '@salesforce/label/c.Error';
import SUCCESS_LABEL from '@salesforce/label/c.Success';
import ERROR_LOADING_BLOOD_TYPES_LABEL from '@salesforce/label/c.Could_not_get_blood_types';
import ERROR_LOADING_PROFILE_INFO_LABEL from '@salesforce/label/c.Could_not_load_Profile_information';
import ERROR_LOADING_RELATIONSHIP_LABEL from '@salesforce/label/c.Could_not_load_relationship_information';
import ACCOUNT_UPDATED_LABEL from '@salesforce/label/c.Account_updated';
import ERROR_REFERESHING_PROFILE_INFORMATION_LABEL from '@salesforce/label/c.Could_not_refresh_Profile_information';
import ERROR_UPDATING_PROFILE_INFORMATION_LABEL from '@salesforce/label/c.Could_not_update_Profile_information';
import MANAGE_MY_FAMILY_HISTORY_LABEL from '@salesforce/label/c.Manage_My_Family_History';
import MANAGE_MY_HEALTH_CONDITIONS_LABEL from '@salesforce/label/c.Manage_My_Health_Conditions';
import MANAGE_MY_HEALTH_PROVIDERS_LABEL from '@salesforce/label/c.Manage_My_Health_Providers';
import MANAGE_MY_MEDICATIONS_LABEL from '@salesforce/label/c.Manage_My_Medications';
import MANAGE_MY_ALLERGIES_LABEL from '@salesforce/label/c.Manage_My_Allergies';
import MANAGE_MY_IMMUNIZATIONS_LABEL from '@salesforce/label/c.Manage_My_Immunizations';
import MANAGE_MY_PROCEDURES_LABEL from '@salesforce/label/c.Manage_My_Procedures';
import MY_INSURANCES_LABEL from '@salesforce/label/c.My_Insurances';
import MANAGE_MY_INSURANCES_LABEL from '@salesforce/label/c.Manage_My_Insurances';
import CARE_GIVER_SUPPORTERS_LABEL from '@salesforce/label/c.CARE_GIVER_SUPPORTERS';
import RELATIONSHIP_TO_CANCER_PATIENT_LABEL from '@salesforce/label/c.Relationship_to_Cancer_Patient';
import WHAT_IS_YOUR_RELATIONSHIP_TO_PATIENT_LABEL from '@salesforce/label/c.What_is_your_Relationship_with_the_patient';
import MANAGE_MY_CARE_GIVER_SUPPORTERS_LABEL from '@salesforce/label/c.Manage_My_Caregivers_Supporters';
import APPOINTMENTS_LABEL from '@salesforce/label/c.APPOINTMENTS';
import MANAGE_MY_APPOINTMENTS_LABEL from '@salesforce/label/c.Manage_My_Appointments';
import HEALTH_INTEREST_LABEL from "@salesforce/label/c.What_Breast_Health_Topics_Are_On_Your_Mind";

export default class KhcMyHealthProfile extends LightningElement {

    myHealthSummaryLabel = MY_HEALTH_SUMMARY_LABEL;
    manageContactInfoLabel = MANAGE_CONTACT_INFO_LABEL;
    myProfileLabel = MY_PROFILE_LABEL;
    heightLabel = HEIGHT_LABEL;
    editLabel = EDIT_LABEL;
    bloodTypeLabel = BLOOD_TYPE_LABEL;
    organDonorLabel = ORGAN_DONOR_LABEL;
    caregiverOrSurvivorLabel = CAREGIVER_OR_CO_SURVIVOR_LABEL;
    twinMultipleLabel = TWIN_MULTIPLE_LABEL;
    myFamilHistoryLabel = MY_FAMILY_HISTORY_LABEL;
    myHealthConditionsLabel = MY_HEALTH_CONDITIONS_LABEL;
    myHealthProvidersLabel = MY_HEALTH_PROVIDER_LABEL;
    myAllergiesLabel = MY_ALLERGIES_LABEL;
    myImmunizationsLabel = MY_IMMUNIZATIONS_LABEL;
    mhyProceduresLabel = MY_PROCEDURES_LABEL;
    myHealthProfileLabel = MY_HEALTH_PROFILE_LABEL;
    myMedicationsLabel = MY_MEDICATIONS_LABEL;
    myInsurancesLabel = MY_INSURANCES_LABEL;
    myCareGiverSupportersLabel = CARE_GIVER_SUPPORTERS_LABEL;
    myAppointments = APPOINTMENTS_LABEL;
    heightFtLabel = HEIGHT_FT_LABEL;
    heightInLabel = HEIGHT_IN_LABEL;
    areYouATwinMultipleLabel = ARE_YOU_A_TWIN_MULTIPLE_LABEL;
    areYouAnOrganDonorLabel = ARE_YOU_AN_ORGAN_DONOR_LABEL;
    keepingProfileUpdateLabel = KEEPING_PROFILE_UPDATED_LABEL;
    areYouaCaregiverOrCoSurvivorLabel = ARE_YOU_A_CAREGIVER_OR_CO_SURVIVOR_LABEL;
    updateLabel = UPDATE_LABEL;
    cancelLabel = CANCEL_LABEL;
    manageMyFamilyHistoryLabel = MANAGE_MY_FAMILY_HISTORY_LABEL;
    manageMyHealthConiditionsLabel = MANAGE_MY_HEALTH_CONDITIONS_LABEL;
    manageMyHealthProvidersLabel = MANAGE_MY_HEALTH_PROVIDERS_LABEL;
    manageMyMedicationsLabel = MANAGE_MY_MEDICATIONS_LABEL;
    manageMyAllergiesLabel = MANAGE_MY_ALLERGIES_LABEL;
    manageMyImmunizationsLabel = MANAGE_MY_IMMUNIZATIONS_LABEL;
    manageMyProceduresLabel = MANAGE_MY_PROCEDURES_LABEL;
    manageMyInsurancesLabel = MANAGE_MY_INSURANCES_LABEL;
    manageMyCaregiversSupporterLabel = MANAGE_MY_CARE_GIVER_SUPPORTERS_LABEL;
    manageMyAppointments = MANAGE_MY_APPOINTMENTS_LABEL;
    relationshipLabel = RELATIONSHIP_TO_CANCER_PATIENT_LABEL;
    whatIsYourRelationShipLabel = WHAT_IS_YOUR_RELATIONSHIP_TO_PATIENT_LABEL;
    typeOfAssessmentLabel = TYPE_OF_ASSESSMENT_LABEL;
    dateOfAssessmentLabel = DATE_OF_ASSESSMENT_LABEL;
    riskLevelLabel = RISK_LEVEL_LABEL;
    notesRiskAssessmentLabel = NOTES_RISK_ASSESSMENT_LABEL;
    healthInterestLabel = HEALTH_INTEREST_LABEL;

    activeSections = [''];
    areDetailsVisible = false;
    @track disabledUpdate = true;
    @track familyMembers;
    @track medications;
    @track conditions;
    @track surgeries;
    @track immunizations;
    @track intolerances;
    @track contact;
    @track cases;
    insurances;
    caregiversSupporters;
    appointments = [];
    upcomingAppointments = [];

    initialAccountDetails;
    @track accId; // TODO change this name
    @track selectedOrganDonor;
    @track selectedBloodType;
    @track selectedTwin;
    @track selectedCareGiver;
    @track showUpdateScreen;
    @track showMyHProfileScreen;
    @track rhesus;
    @track bloodTypeScreen;
    @track heightDetails;
    typeOfAssessment;
    riskLevel;
    riskNotes;
    dateOfAssessment;

    @track selectedRelationship;
    @track selectedHealthInterests;

    heightOptions = [] ;

    @api recordId;
    @api objectApiName;

    checkboxOptions = [{value:"Yes" , label:"Yes"},
                        {value:"No" , label:"No"}];

     bloodTypeOptions = [];
     relationShipOptions = [];
     healthInterestOptions = [];

    connectedCallback() {
        this.showMyHProfileScreen = true;
        this.showUpdateScreen = false;

        getMyInformation({
            currentLoggedAccount: this.recordId
        })
        .then(result => {
            this.buildAccountDetails(result) ;
            this.areDetailsVisible = true;
            
            getBloodTypePicklistValues({
            
            }).then(result => {
                result.forEach(  element => {
                    let myObj = {value: element, label: element};
                    this.bloodTypeOptions.push(myObj);
                });
               
             }).catch(error => {
                    const evt = new ShowToastEvent({
                    title: ERROR_LABEL,
                    message: ERROR_LOADING_BLOOD_TYPES_LABEL,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt); 
            });

            getRelationShipValues({
            }).then(result => {
                result.forEach(  element => {
                    let myObj = {value: element, label: element};
                    this.relationShipOptions.push(myObj);
                });

            }).catch(error => {
                const evt = new ShowToastEvent({
                    title: ERROR_LABEL,
                    message: ERROR_LOADING_RELATIONSHIP_LABEL,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            });

            getBreastHealthTopic({
            }).then(result => {
                result.forEach(  element => {
                    let myObj = {value: element, label: element};
                    this.healthInterestOptions.push(myObj);
                });

            }).catch(error => {
                const evt = new ShowToastEvent({
                    title: ERROR_LABEL,
                    message: ERROR_LOADING_RELATIONSHIP_LABEL,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            });


         }) .catch(error => {
             console.log( error );
            const evt = new ShowToastEvent({
                title: ERROR_LABEL,
                message: ERROR_LOADING_PROFILE_INFO_LABEL,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);  
        });
        this.displayDetails();
    }
    displayDetails(){
        this.areDetailsVisible = true;
    }
    handleHeightChange(event){
        this.selectedHeight = event.detail.value;
    }
    handleOrganDonorChange(event){
        this.selectedOrganDonor = event.detail.value;
    }
    handleTwinChange(event){
        this.selectedTwin = event.detail.value;
    }
    handleCareGiverChange(event){
        this.selectedCareGiver = event.detail.value;
    }
    handleBloodTypeChange(event){
        this.selectedBloodType = event.detail.value;
    }
    handleRelationShipChange(event){
        this.selectedRelationship = event.detail.value;
    }
    handleHealthInterestChange(e){
        this.selectedHealthInterests = e.detail.value;
    }


    handleHeightFt(event){
        this.selectedHeightFt = event.target.value;
        if (this.selectedHeightFt)
            this.disabledUpdate = false;
        else
            this.disabledUpdate = true;
    }

    handleHeightIn(event){
        this.selectedHeightIn = event.target.value;          
    }

    handleUpdate (event){
        let acc = {
            Blood_Type__pc: this.selectedBloodType,
            Organ_Donor__pc: (this.selectedOrganDonor === "Yes") ? true : false,
            Multiple_Twin__pc: (this.selectedTwin === "Yes") ? true : false,
            Care_Giver_Co_Survivor__pc: (this.selectedCareGiver === "Yes") ? true : false,
            Height_ft__pc: this.selectedHeightFt,
            Height_in__pc: this.selectedHeightIn,
            Id: this.accId,
            Relationship_To_Cancer__pc: this.selectedRelationship,
            Breast_Health_topics_on_your_mind__pc: this.selectedHealthInterests
        };
        //TODO add a loading icon to get users a feedback
        let conToBeUpdated = {
            Id: this.contact.Id
        }
        
        updateAccount({
            accountToBeUpdated: acc,
            contactToBeUpdated: conToBeUpdated
        })
        .then(result => { // TODO add a fancy success message
            const evt = new ShowToastEvent({
                title: SUCCESS_LABEL,
                message: ACCOUNT_UPDATED_LABEL,
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);

            getMyInformation({
                currentLoggedAccount: this.recordId
            })
            .then(result => {
                this.buildAccountDetails(result) ;
                
                this.showMyHProfileScreen = true;
                this.showUpdateScreen = false;
            }).catch(error => {
                const evt = new ShowToastEvent({
                    title: ERROR_LABEL,
                    message: ERROR_REFERESHING_PROFILE_INFORMATION_LABEL,
                    variant: 'error',
                    mode: 'dismissable' 
                });
            });
            
          }).catch(error => {
            const evt = new ShowToastEvent({
                title: ERROR_LABEL,
                message: ERROR_UPDATING_PROFILE_INFORMATION_LABEL,
                variant: 'error',
                mode: 'dismissable' 
            });
            this.dispatchEvent(evt); 
        }); 
    }

    navigateToUpdateProfilePage() {
        this.populateAccountDetails( this.initialAccountDetails );
        this.showUpdateScreen = !(this.showUpdateScreen);
        this.showMyHProfileScreen = !(this.showMyHProfileScreen);
    }

    redirectToNPSPProfile(){
        getRedirectorData().then(result => {
           window.location.href = result.myKomenURL + result.profilePage;
        });
    }

    buildAccountDetails(result){
        let proceduresCount = 0;
        let peopleCount = 0;
        let issuesCount = 0;
        let medicationsCount = 0;
        let allergiesCount = 0;
        let immunizationsCount = 0;
        let providersCount = 0;
        let insurancesCount = 0;
        let caregiverSupporterCount = 0;
        let appointmentsCount = 0;

        result.forEach(  element => {
            this.initialAccountDetails = element;
            this.populateAccountDetails( element );

            if (element.Contacts){
                let contacts = element.Contacts;
                this.contact = contacts[0];
            }

            if (element.HealthCloudGA__Conditions__r){
                this.conditions = element.HealthCloudGA__Conditions__r;
                issuesCount = element.HealthCloudGA__Conditions__r.length;

            }
            if (element.HealthCloudGA__MedicationStatements__r){
                this.medications = element.HealthCloudGA__MedicationStatements__r;
                medicationsCount = element.HealthCloudGA__MedicationStatements__r.length;
            }
            if (element.Patient_Contacts__r){
                let familyMembers = [];
                let caregiversSupporters = [];

                element.Patient_Contacts__r.forEach( pateintContact =>{
                    if( pateintContact.RecordType && pateintContact.RecordType.Name == 'Supporter/Caregiver' ){
                        caregiversSupporters.push( pateintContact );
                        caregiverSupporterCount++;
                    }else if( pateintContact.RecordType && pateintContact.RecordType.Name == 'Family Medical History' ){
                        familyMembers.push( pateintContact );
                        peopleCount++;
                    }
                });
                if( caregiverSupporterCount > 0) this.caregiversSupporters = caregiversSupporters;
                if( peopleCount > 0) this.familyMembers = familyMembers;
            }
            if (element.HealthCloudGA__AllergyIntolerances__r){
                this.intolerances =  element.HealthCloudGA__AllergyIntolerances__r;
                allergiesCount = element.HealthCloudGA__AllergyIntolerances__r.length;
            }
            if (element.HealthCloudGA__Immunizations__r){
                this.immunizations =  element.HealthCloudGA__Immunizations__r;
                immunizationsCount = element.HealthCloudGA__Immunizations__r.length;
            }
            if (element.HealthCloudGA__EHRProcedures__r){
                this.surgeries =  element.HealthCloudGA__EHRProcedures__r;
                proceduresCount = element.HealthCloudGA__EHRProcedures__r.length;
            }
            if (element.HealthCloudGA__Encounters__r){
                this.upcomingAppointments =  element.HealthCloudGA__Encounters__r;
            }

            if(this.upcomingAppointments) {
                for(let i = 0; i < this.upcomingAppointments.length; i++) {
                    let now = new Date();
                    let temp = (new Date(this.upcomingAppointments[i].Appointment_Date__c));
                    let appointmentDate = new Date(temp.getTime() + temp.getTimezoneOffset() * 60000);

                    let appointmentIsLaterToday = isAppointmentLaterToday(now, appointmentDate, this.upcomingAppointments[i].Appointment_Time__c);

                    if (appointmentDate > now || appointmentIsLaterToday) {
                        this.appointments.push(this.upcomingAppointments[i]);
                        appointmentsCount++;
                    }
                }
            }

            this.mhyProceduresLabel = `${MY_PROCEDURES_LABEL} (${proceduresCount})`;
            this.myImmunizationsLabel = `${MY_IMMUNIZATIONS_LABEL} (${immunizationsCount})`;
            this.myAllergiesLabel = `${MY_ALLERGIES_LABEL} (${allergiesCount})`;
            this.myFamilHistoryLabel = `${MY_FAMILY_HISTORY_LABEL} (${peopleCount})`;
            this.myMedicationsLabel = `${MY_MEDICATIONS_LABEL} (${medicationsCount})`;
            this.myHealthConditionsLabel = `${MY_HEALTH_CONDITIONS_LABEL} (${issuesCount})`;
            this.myCareGiverSupportersLabel =  `${CARE_GIVER_SUPPORTERS_LABEL} (${caregiverSupporterCount})`;
            this.myAppointments = `${APPOINTMENTS_LABEL} (${appointmentsCount})`;
        });


        getProvidersByPatientId({
            contactId: this.contact.Id
        })
        .then(response => {
            this.cases = response;
            providersCount = response.length ;
            this.myHealthProvidersLabel = `${MY_HEALTH_PROVIDER_LABEL} (${providersCount})`;
        });

        getInsurancesByMemberId({
            memberId: this.contact.Id
        }).then( response =>{
            this.insurances = response;
            insurancesCount = response.length;
            this.myInsurancesLabel = `${MY_INSURANCES_LABEL} (${insurancesCount})`;
        });

    }

    populateAccountDetails( element ){
        this.selectedHeightFt = element.Height_ft__pc;
        this.selectedHeightIn =element.Height_in__pc;
        this.heightDetails = '';
        if (this.selectedHeightFt){
            this.heightDetails = this.selectedHeightFt + "ft ";
            this.disabledUpdate = false;
        }
        if (this.selectedHeightIn){
            this.heightDetails = this.heightDetails + this.selectedHeightIn + "inches";
        }
        this.selectedOrganDonor = (element.Organ_Donor__pc == true) ? "Yes" : "No";
        this.selectedTwin = (element.Multiple_Twin__pc  == true) ? "Yes" : "No";
        this.selectedCareGiver = (element.Care_Giver_Co_Survivor__pc  == true) ? "Yes" : "No";
        this.selectedBloodType = element.Blood_Type__pc;
        this.bloodTypeScreen = this.selectedBloodType;
        this.typeOfAssessment = element.Type_of_Assessment__c;
        this.riskLevel = element.Risk_Level__c;
        this.riskNotes = element.Notes_Risk_Assessment__c;
        this.dateOfAssessment = element.Date_of_Assessment__c;
        let relationshipValues = element.Relationship_To_Cancer__pc;
        if(relationshipValues != null){
            this.selectedRelationship = relationshipValues.split(';');
        }else{
            this.selectedRelationship = '';
        }
        let healthInterest = element.Breast_Health_topics_on_your_mind__pc;
        if( healthInterest != null){
            this.selectedHealthInterests = healthInterest.split(';');
        }else{
            this.selectedHealthInterests = '';
        }
        this.accId = element.Id;
    }

}