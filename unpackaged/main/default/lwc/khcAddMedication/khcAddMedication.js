import { LightningElement, api, wire } from 'lwc';
import deleteRecord from '@salesforce/apex/KHC_DeleteUtility.deleteRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getLoggedInUserDetails from '@salesforce/apex/KHC_MedicationController.getLoggedInUserDetails';

import ADD_A_MEDICATION_LABEL from "@salesforce/label/c.Add_a_new_Medication";
import ADDITIONAL_DETAILS_LABEL from "@salesforce/label/c.Additional_Details";
import MEDICATION_START_DATE_TIME_LABEL from "@salesforce/label/c.Medication_Start_Date_Time";
import NUMBER_OF_DOSE_LABEL from "@salesforce/label/c.Number_of_dose";
import TAKEN_WITH_FOOD_LABEL from "@salesforce/label/c.Taken_with_food";
import DOSAGE_VALUE_LABEL from "@salesforce/label/c.Dosage_Value";
import DOSAGE_UNIT_LABEL from "@salesforce/label/c.Dosage_Unit";
import FREQUENCY_VALUE_LABEL from "@salesforce/label/c.Frequency_Value";
import FREQUENCY_UNIT_LABEL from "@salesforce/label/c.Frequency_Unit";
import NOTES_LABEL from "@salesforce/label/c.Notes";
import REMOVE_MEDICATION_LABEL from "@salesforce/label/c.Remove_Medication";
import ADD_NEW_MEDICATION_LABEL from "@salesforce/label/c.Add_new_Medication";
import EDIT_MEDICATION_LABEL from "@salesforce/label/c.Edit_Medication";
import UPDATE_MEDICATION_LABEL from "@salesforce/label/c.Update_Medication";
import ERROR_LABEL from "@salesforce/label/c.Error";
import SUCCESS_LABEL from "@salesforce/label/c.Success";
import MEDICATION_REQUIRED_LABEL from "@salesforce/label/c.Medication_is_required";
import ERROR_SAVING_MEDICATION_LABEL from "@salesforce/label/c.Error_saving_Medication";
import MEDICATION_SAVED_LABEL from "@salesforce/label/c.Medication_saved";
import MEDICATION_DELETED_LABEL from "@salesforce/label/c.Medication_deleted";

export default class KhcAddMedication extends NavigationMixin(LightningElement) {

    @api recordId;
    @api showMedicationDetail = false;   
    
    additionalDetailsLabel = ADDITIONAL_DETAILS_LABEL;
    medicationStartDatetimelabel = MEDICATION_START_DATE_TIME_LABEL;
    numberOfDoseLabel = NUMBER_OF_DOSE_LABEL;
    takenWithfoodLabel = TAKEN_WITH_FOOD_LABEL;
    dosageValueLabel = DOSAGE_VALUE_LABEL;
    dosageUnitLabel = DOSAGE_UNIT_LABEL;
    frequencyValueLabel = FREQUENCY_VALUE_LABEL;
    frequencyUnitLabel = FREQUENCY_UNIT_LABEL;
    notesLabel = NOTES_LABEL;
    removeMedicationLabel = REMOVE_MEDICATION_LABEL;

    showAdditionalDetails = false;
    sectionLabel = ADD_A_MEDICATION_LABEL;
    buttonLabel = ADD_NEW_MEDICATION_LABEL;
    medicationStatement = {};
    isLoaded = false;
    isDelete = false;
    loggedInUser;
    showSpinner = false;

    
    editRecord(){
        this.sectionLabel = EDIT_MEDICATION_LABEL;
        this.buttonLabel = UPDATE_MEDICATION_LABEL;
    }

    connectedCallback(){
        if( this.loggedInUser == undefined){
            getLoggedInUserDetails()
                .then( result => {
                    this.loggedInUser = result;
                })
                .catch( error => {});
        }
    }
    renderedCallback(){
        if( this.recordId != undefined ){
            this.editRecord();
            if( this.showAdditionalDetails && this.medicationStatement.hasOwnProperty( 'With_Food__c' ) ){
                this.template.querySelector( '.withFood' ).checked = this.medicationStatement.With_Food__c;
            }
        }
    }
    
    handleShowAdditionalDetails(){
        this.showAdditionalDetails = !this.showAdditionalDetails;
        this.showSpinner = true;
    }
    handleLoad(event) {
        if( this.recordId != undefined ){
            let fields = Object.values(event.detail.records)[0].fields;
            const recordId = Object.keys(event.detail.records)[0];
            this.medicationStatement = {
                Id: recordId
            };
            let medicationStatement = {};
            Object.keys(fields).forEach(element => {
                if( element == 'Medication__r' ){
                    medicationStatement['Medication__r'] = {"Id" : fields[element].value.fields.Id.value, "Name" : fields[element].value.fields.Name.value};
                }else{
                    medicationStatement[ element ] = fields[element].value;
                }
            });
            this.medicationStatement = medicationStatement;
        }
        this.isLoaded = true;
        this.showSpinner = false;
    }
    handleMedicationChanged( evt ){
        let medicationStatement = this.medicationStatement;
        medicationStatement.Medication__r = evt.detail;
        this.medicationStatement = medicationStatement;
    }
    handleSubmit( evt ){
        evt.preventDefault();  
        this.showSpinner = true;
        const fields = evt.detail.fields;
        if( !this.medicationStatement.hasOwnProperty( 'Medication__r') ){
            this.showToast( ERROR_LABEL, MEDICATION_REQUIRED_LABEL, 'error' );
            this.showSpinner = false;
        }
        fields.HealthCloudGA__Account__c = this.loggedInUser.AccountId;
        fields.Medication__c = this.medicationStatement.Medication__r.Id;
        let withFoodElm = this.template.querySelector( '.withFood' );
        fields.With_Food__c = ( withFoodElm != null ? withFoodElm.checked : false );
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }
    handleSuccess( event ){
        this.showToast( SUCCESS_LABEL, MEDICATION_SAVED_LABEL, 'success' );
        this.navigateToWebPage()
    }
    handleError( evt ){
        if( !this.isDelete ) this.showToast( ERROR_LABEL, ERROR_SAVING_MEDICATION_LABEL, 'error' );
    }
    removeMedicationStatement( evt ){
        this.showSpinner = true;
        let context = this;
        this.isDelete = true;
        this.showMedicationDetail = false;
        deleteRecord( {rec: { Id: this.recordId } } )
            .then(() => {
                context.showToast( SUCCESS_LABEL, MEDICATION_DELETED_LABEL, 'success' );
                this.showSpinner = false;
                this.navigateToWebPage();
            })
            .catch(error => {
                context.showToast( ERROR_LABEL, error.body.message, 'error' );
                this.showMedicationDetail = true;
                this.showSpinner = false;
            });
    }

    showToast( title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    fireListRefresh(){
        const medicationRefresh = new CustomEvent("recordchange");
        this.dispatchEvent( medicationRefresh );
    }

    //TODO: Navigate to community, make it dynamic
    navigateToWebPage() {
        // Navigate to a URL
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/s/my-medications/'
            }
        },
        true // Replaces the current page in your browser history with the URL
      );
    }
}