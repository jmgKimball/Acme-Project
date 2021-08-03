import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import upsertMedication from '@salesforce/apex/KHC_MedicationLookupController.upsertMedication';
import getAllMedications from '@salesforce/apex/KHC_MedicationLookupController.getAllMedications';

import MEDICATION_NAME_LABEL from "@salesforce/label/c.Medication_Name";
import MEDICATION_NAME_REQUIRED_LABEL from "@salesforce/label/c.Medication_Name_is_required";
import ERROR_LABEL from "@salesforce/label/c.Error";
import MATCHING_MEDICATION_ERROR_LABEL from "@salesforce/label/c.Matching_Medication";


export default class KhcMedicationLookup extends LightningElement {
    @api medicationRecord;
    showSpinner = true;
    showDruglist = false;
    drugList = [] ;
    searchString = null ;
    serviceError;
    hasServiceError = false;
    isEdit = true;
    medicationError;
    hasMedicationError = false;

    medicationNameLabel = MEDICATION_NAME_LABEL;

    handleMedicationListClick( evt ){
        evt.preventDefault();
        let keyword = this.template.querySelector('.medication-search').value;

        if( keyword != "" ){
            this.showSpinner = true;
            this.showDruglist = false;
            this.hasServiceError = false;
            this.hasMedicationError = false;
            let context = this;
            let drugs = [];

            getAllMedications({ keyword: keyword })
                .then( (result) => {
                        if(result !=null ) {
                            if(result.length > 5 ) {
                                this.drugList = result.slice(0, 5).map(drug => ({
                                    setid: drug.setid,
                                    title: drug.title
                                }));
                                this.showDruglist = true;
                            }else if(result.length > 0 && result.length <= 5) {
                                this.drugList = result.slice(0, result.length).map(drug => ({
                                    setid: drug.setid,
                                    title: drug.title
                                }));
                                this.showDruglist = true;
                            }else{
                            this.showDruglist = false;
                            this.medicationError = MATCHING_MEDICATION_ERROR_LABEL;
                            this.hasMedicationError = true;
                        }
                    }
                }).catch(error => {
                    let errorData = JSON.parse(error.body.message);
                    console.error(errorData.name +" (code "+ errorData.code +"): "+ errorData.message);
                    this.showSpinner = false;
                    this.serviceError = errorData.name;
                    this.hasServiceError = true;
                });
        }else{
            this.showToast( ERROR_LABEL, MEDICATION_NAME_REQUIRED_LABEL, 'error' );
        }
    }

    renderedCallback(event){
        this.showSpinner = false;
    }

    get isExisting(){
        if( this.medicationRecord != undefined && this.medicationRecord.hasOwnProperty('Id') ){
            this.isEdit = false;
            return true;
        }
        return false;
    }

    upsertMedication( keyword,setid, context ){

        let medication = { 'sobjectType' : 'Medication__c' };
        medication.Med_Name__c  = keyword;
        medication.Setid = setid;
        medication.Name = keyword.substring(0, 79) ;

        upsertMedication( { medication: medication } )
            .then( (result) =>{
                if( result != null ){
                    medication.Id = result;
                    this.medicationRecord = medication;
                    this.isEdit = false;
                    //Event to pass selected medication to parent
                    const medicationChanged = new CustomEvent("medicationchange", {
                        detail: medication
                    });
                    this.dispatchEvent( medicationChanged );
                }
            })
            .catch( error => {
                context.showToast( ERROR_LABEL, error, 'error' );
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

    clearMedication( evt ){
        this.medicationRecord = {};
        this.isEdit = true;
    }

    selectDrug(evt){
        let keyword = evt.target.dataset.recordName;
        let drugSetid = evt.target.dataset.drugSetid;
        this.SearchString = keyword;
        this.upsertMedication( keyword,drugSetid, this);
        this.showDruglist=false;
    }
    onSearchChange(event){
        this.hasMedicationError = false;
    }

    handlePress(event) {
        if(event.keyCode == 13 || event.which === 13) {
            event.preventDefault();
            this.handleMedicationListClick(event);
        }
    }

}