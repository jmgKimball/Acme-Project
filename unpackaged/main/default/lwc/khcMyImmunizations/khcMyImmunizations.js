/**
 * Custom component for viewing and editing Immunizations
 *
 * @author Nitin Chandwani, Traction on Demand
 * @date 2020-10-01
 */
import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getImmunizations from '@salesforce/apex/KHC_ImmunizationsController.getImmunizations';
import deleteRecord from '@salesforce/apex/KHC_DeleteUtility.deleteRecord';
import getLoggedInUserDetails from '@salesforce/apex/KHC_MedicationController.getLoggedInUserDetails';
import list from './list.html';
import edit from './edit.html';

import MY_IMMUNIZATIONS_HEADER_TEXT from "@salesforce/label/c.My_Immunizations_Header_Text";
import EDIT_IMMUNIZATIONS_HEADER_TEXT from "@salesforce/label/c.Edit_Immunization";
import EDIT_LABEL from "@salesforce/label/c.Edit";
import NO_IMMUNIZATION_FOUND_LABEL from "@salesforce/label/c.No_Immunization_Found";
import ADD_A_NEW_IMMUNIZATION_LABEL from "@salesforce/label/c.Add_a_new_immunization";
import UPDATE_IMMUNIZATION_LABEL from '@salesforce/label/c.Update_immunization';
import IMMUNIZATION_LABEL from '@salesforce/label/c.Immunization';
import DATE_ADMINISTERED_LABEL from '@salesforce/label/c.Date_administered';
import SUCCESS_LABEL from "@salesforce/label/c.Success";
import SUCCESS_MESSAGE_LABEL from '@salesforce/label/c.Immunization_saved';
import ERROR_LABEL from "@salesforce/label/c.Error";
import ERROR_MESSAGE_LABEL from '@salesforce/label/c.Error_saving_Immunization';
import REMOVE_IMMUNIZATION_LABEL from '@salesforce/label/c.Remove_Immunization';
import IMMUNIZATION_DELETED_MESSAGE_LABEL from'@salesforce/label/c.Immunization_deleted';
import CANCEL_LABEL from '@salesforce/label/c.Cancel';

import IMMUNIZATION_OBJECT from '@salesforce/schema/HealthCloudGA__EhrImmunization__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class KhcMyImmunizations extends LightningElement {

    activePage = list;
    showSpinner = true;
    immunizations;
    recordId;
    loggedInUser;

    headerText = MY_IMMUNIZATIONS_HEADER_TEXT;
    editLabel = EDIT_LABEL;
    noRecordFoundLabel = NO_IMMUNIZATION_FOUND_LABEL;
    addANewImmunization = ADD_A_NEW_IMMUNIZATION_LABEL;
    immunizationLabel = IMMUNIZATION_LABEL;
    dateAdministeredLabel = DATE_ADMINISTERED_LABEL;
    saveButtonLabel = ADD_A_NEW_IMMUNIZATION_LABEL;
    removeImmunizationLabel = REMOVE_IMMUNIZATION_LABEL;
    cancelLabel = CANCEL_LABEL;

    immunizationFields;

    @wire(getObjectInfo, { objectApiName: IMMUNIZATION_OBJECT })
    oppInfo({ data, error }) {
        if (data){
            let fieldList = [
                { apiName :  "Immunization_Type__c", label : data.fields.Immunization_Type__c.label},
                { apiName :  "Date_Administered__c", label : data.fields.Date_Administered__c.label},

            ];
            this.immunizationFields = fieldList;
        }
    }
    render(){
        return this.activePage;
    }
    renderedCallback(){
    }
    connectedCallback(){
        this.reteriveImmunizations();
        if( this.loggedInUser == undefined){
            getLoggedInUserDetails()
                .then( result => {
                    this.loggedInUser = result;
                })
                .catch( error => {});
        }
    }
    handleAddImmunizationClick(){
        this.showSpinner = true;
        this.activePage = edit;
        this.headerText = ADD_A_NEW_IMMUNIZATION_LABEL;
        this.saveButtonLabel = ADD_A_NEW_IMMUNIZATION_LABEL;
    }
    handleCancelClick(){
        this.activePage = list;
        this.editRecordId = undefined;
    }
    
    handleEditImmunizationClick( evt ){
        this.recordId = evt.target.dataset.id;
        this.showSpinner = true;
        this.activePage = edit;
        this.headerText = EDIT_IMMUNIZATIONS_HEADER_TEXT;
        this.saveButtonLabel = UPDATE_IMMUNIZATION_LABEL;
    }

    get hasImmunization(){
        if( this.immunizations != undefined && this.immunizations.length > 0){
            return true;
        }
        return false;
    }

    handleLoad( evt ){
        this.showSpinner = false;
    }
    handleSuccess( evt ){
        this.showToast( SUCCESS_LABEL, SUCCESS_MESSAGE_LABEL, 'success' );
        this.refreshComponent();
        this.showSpinner = false;
    }
    handleSubmit( evt ){
        evt.preventDefault();
        const fields = evt.detail.fields;
        fields.HealthCloudGA__Account__c = this.loggedInUser.AccountId;
        this.template.querySelector('lightning-record-edit-form').submit( fields );
    }
    handleError( evt ){
        this.showToast( ERROR_LABEL, ERROR_MESSAGE_LABEL, 'error' );
        this.showSpinner = false;
    }
    handleSave(){
        this.showSpinner = true;
        var checkValid = new Promise((resolve, reject) => {
            this.template.querySelectorAll( '.immunization-form lightning-input-field').forEach( elm => {
                if( !elm.reportValidity() ) resolve( false );
            });
            resolve( true );
        });
        checkValid.then( result => {
            if( result ){
                this.template.querySelector(".submit-immunization").click();
            }else{
                this.showSpinner = false;
            }
        });
    }
    handleRemoveClick(){
        if( this.recordId != undefined && this.recordId != '' ){
            this.showSpinner = true;
            deleteRecord( {rec: { Id: this.recordId } } )
                .then( result => {
                    this.showToast( SUCCESS_LABEL, IMMUNIZATION_DELETED_MESSAGE_LABEL, 'success' );
                    this.showSpinner = false;
                    this.refreshComponent();
                })
                .catch(error => {
                    this.showToast( ERROR_LABEL, error.body.message, 'error' );
                    this.showSpinner = false;
                });
        }
    }

    reteriveImmunizations(){
        getImmunizations()
            .then( result =>{
                result.forEach( immunization =>{
                    if( immunization.hasOwnProperty('Date_Administered__c') &&
                        immunization.Date_Administered__c != null ){
                        let dt = new Date( immunization.Date_Administered__c );
                        immunization.year = dt.getFullYear();
                    }
                } );
                this.immunizations = result;
                this.showSpinner = false;
            })
            .catch( error => {
                console.log( error );
                this.showSpinner = false;
            } );
    }

    showToast( title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
    /**
     * @description Refresh and display list view
     */
    refreshComponent(){
        this.headerText = MY_IMMUNIZATIONS_HEADER_TEXT;
        this.recordId = '';
        this.activePage = list;
        this.reteriveImmunizations();
    }
}