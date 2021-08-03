import { LightningElement, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import {ShowToastEvent} from "lightning/platformShowToastEvent";

import deleteRecord from '@salesforce/apex/KHC_DeleteUtility.deleteRecord';
import getSupporters from '@salesforce/apex/KHC_PatientContactsController.getSupporters';
import getLoggedInUser from '@salesforce/apex/KHC_PatientContactsController.getLoggedInUser';
import PATIENT_CONTACT_OBJECT from '@salesforce/schema/Patient_Contact__c';
import CAREGIVER_SUPPORTER_HEADER_LABEL from '@salesforce/label/c.Caregivers_Supporters';
import ADD_CAREGIVER_SUPPORTER_HEADER_LABEL from '@salesforce/label/c.Add_Caregiver_Supporter';
import EDIT_CAREGIVER_SUPPORTER_HEADER_LABEL from '@salesforce/label/c.Edit_Caregiver_Supporter';
import CANCEL_LABEL from "@salesforce/label/c.Cancel";
import REMOVE_LABEL from "@salesforce/label/c.Remove";
import UPDATE_LABEL from "@salesforce/label/c.Update_Caregiver_Supporter";
import EDIT_LABEL from "@salesforce/label/c.Edit";
import SUCCESS_LABEL from "@salesforce/label/c.Success";
import ERROR_LABEL from "@salesforce/label/c.Error";
import ADD_NEW_CONTACT_LABEL from "@salesforce/label/c.Add_New_Contact";
import SUCCESS_MESSAGE_LABEL from '@salesforce/label/c.Record_updated_successfully';
import PRINTABLE_VIEW_LABEL from '@salesforce/label/c.Printable_View';
import NAME_LABEL from '@salesforce/label/c.Name';
import list from './list.html';
import edit from './edit.html';

export default class KhcManageContacts extends LightningElement {
    activePage = list;
    showSpinner = true;
    patientContactFields;
    patientContactFieldsMap;
    loaded = false;
    editRecordId;
    loggedInUser;
    patientContacts;
    recordTypeId;

    headerText = CAREGIVER_SUPPORTER_HEADER_LABEL;
    cancelLabel = CANCEL_LABEL;
    removeLabel = REMOVE_LABEL;
    editLabel = EDIT_LABEL;
    addNewContactLabel = ADD_NEW_CONTACT_LABEL;
    printableViewLabel = PRINTABLE_VIEW_LABEL;

    constructor(){
        super();
    }

    connectedCallback(){
        this.getLoggedInUser();
        this.getSupporters();
    }

    render(){
        return this.activePage;
    }


    get editHeaderText(){
        if( this.editRecordId == undefined ) return ADD_CAREGIVER_SUPPORTER_HEADER_LABEL;
        return EDIT_CAREGIVER_SUPPORTER_HEADER_LABEL;
    }

    get saveButtonLabel(){
        if( this.editRecordId == undefined ) return ADD_CAREGIVER_SUPPORTER_HEADER_LABEL;
        return UPDATE_LABEL;
    }

    get printableViewLink(){
        return '/apex/KHC_CaregiversSupportersPdf?id=' + this.loggedInUser.AccountId;
    }

    @wire(getObjectInfo, { objectApiName: PATIENT_CONTACT_OBJECT })
    patientContactInfo({ data, error }) {
        if (data){
            let fieldList = [
                { apiName : "Family_Member_Name__c", label : NAME_LABEL },
                { apiName : "Relationship__c", label : data.fields.Relationship__c.label},
                { apiName : "Email__c", label : data.fields.Email__c.label },
                { apiName : "Phone__c", label : data.fields.Phone__c.label },
                { apiName : "Mobile_Phone__c", label : data.fields.Mobile_Phone__c.label },
                { apiName : "Mailing_Street__c", label : data.fields.Mailing_Street__c.label },
                { apiName : "Mailing_City__c", label : data.fields.Mailing_City__c.label },
                { apiName : "Mailing_State_Province__c", label : data.fields.Mailing_State_Province__c.label },
                { apiName : "Mailing_Country__c", label : data.fields.Mailing_Country__c.label },
                { apiName : "Mailing_Zip_Postal_Code__c", label : data.fields.Mailing_Zip_Postal_Code__c.label },
                { apiName : "Emergency_Contact__c", label : data.fields.Emergency_Contact__c.label },
                { apiName : "Description_Notes__c", label : data.fields.Description_Notes__c.label },
                
            ];
            this.patientContactFields = fieldList;
            let fieldMap = { 
                Family_Member_Name__c : { label : data.fields.Family_Member_Name__c.label }, 
                Relationship__c : { label : data.fields.Relationship__c.label },
                Email__c : { label : data.fields.Email__c.label },
                Phone__c : { label : data.fields.Phone__c.label },
                Mobile_Phone__c : { label : data.fields.Mobile_Phone__c.label },
                MailingAddress : { label : "Mailing Address" },
                Emergency_Contact__c : { label : data.fields.Emergency_Contact__c.label },
                Description_Notes__c : { label : data.fields.Description_Notes__c.label },
            };
            if( data.recordTypeInfos ){
                let recordTypeId;
                Object.keys( data.recordTypeInfos ).forEach( function(key){
                    if( data.recordTypeInfos[key].name == 'Supporter/Caregiver' ){
                        recordTypeId = key;
                    }
                });
                this.recordTypeId = recordTypeId;
            }
            this.patientContactFieldsMap = fieldMap;
            this.loaded = true;
        }
    }

    getSupporters(){
        getSupporters().then( result => {
            result.forEach( patientContact => { 
                patientContact.Emergency_ContactValue = patientContact.Emergency_Contact__c === true ? 'Yes' : 'No';
                patientContact.Relationship__c = !patientContact.Relationship__c ? "" : patientContact.Relationship__c;

                if(!patientContact.Relationship__c) {
                    patientContact.accordianHeading =  patientContact.Family_Member_Name__c;
                }

                else {
                    patientContact.accordianHeading =  patientContact.Family_Member_Name__c + ' (' + patientContact.Relationship__c + ')';
                }

            });
            this.patientContacts = result;
            this.showSpinner = false;
        }).catch( error => {    
            this.showToastMessage( ERROR_LABEL, error, 'error' );
        });
    }
    
    getLoggedInUser(){
        getLoggedInUser()
        .then( results => {
            this.loggedInUser = results;
        }).
        catch( error => {
            this.showToastMessage( ERROR_LABEL, error, 'error' );
        });
    }

    handleAddNewContactClick(){
        this.activePage = edit;
        this.showSpinner = true;
    }
    handleEdit( event ){
        this.editRecordId = event.target.dataset.id;
        this.activePage = edit;
        this.showSpinner = true;
    }
    handleCancelClick(){
        this.refreshComponent();
    }
    handleDeleteClick(){
        this.showSpinner = true;
        deleteRecord( {rec: { Id: this.editRecordId } } )
            .then(() => {
                this.refreshComponent();
                this.showSpinner = false;
                this.showToastMessage( SUCCESS_LABEL, SUCCESS_LABEL, 'success' );
            })
            .catch(error => {
                this.showSpinner = false;
                this.showToastMessage( ERROR_LABEL, error, 'error' );
            });
    }
    handleLoad(){
        this.showSpinner = false;
    }
    handleSubmit(event){
        this.showSpinner = true;
     }
    handleSuccess( res ){
        this.showToastMessage( SUCCESS_LABEL, SUCCESS_MESSAGE_LABEL, 'success' );
        this.refreshComponent();
        this.showSpinner = false;
    }
    handleError( error ){
        console.log( error );
        this.showToastMessage( ERROR_LABEL, ERROR_MESSAGE_LABEL, 'error' );
        this.showSpinner = false;
    }

    handleEmergencyContactChange( event ){
        this.conConRel.fields.Emergency_Contact__c = event.target.checked;
    }

    refreshComponent(){
        this.editRecordId = undefined;
        this.getSupporters();
        this.activePage = list;
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