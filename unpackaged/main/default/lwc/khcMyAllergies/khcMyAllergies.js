/**
 * Custom component for viewing and editing Allergies
 *
 * @author Vikrant Upneja, Traction on Demand
 * @date 2021-01-15
 */
import {api, LightningElement, wire, track} from 'lwc';
import getAllergies from '@salesforce/apex/KHC_AllergyController.getAllergies';
import getLoggedInUserDetails from '@salesforce/apex/KHC_MedicationController.getLoggedInUserDetails';
import list from './list.html';
import edit from './edit.html';

import SUCCESS_LABEL from "@salesforce/label/c.Success";
import SUCCESS_MESSAGE_LABEL from '@salesforce/label/c.My_allergy_Save_Msg';
import ERROR_LABEL from "@salesforce/label/c.Error";
import ERROR_MESSAGE_LABEL from '@salesforce/label/c.My_Allergy_Error_Msg';
import EDIT_LABEL from "@salesforce/label/c.Edit";
import CANCEL_LABEL from '@salesforce/label/c.Cancel';

import SAVE_LABEL from '@salesforce/label/c.My_allergy_save';
import REMOVE_LABEL from '@salesforce/label/c.My_allergy_remove';
import ADD_LABEL from '@salesforce/label/c.My_allergy_add';
import NO_ALLERGY_LABEL from '@salesforce/label/c.My_allergy_no_allergy_found';
import EDIT_HEADER_TEXT from '@salesforce/label/c.My_Allergy_Edit_Header';
import UPDATE_LABEL from '@salesforce/label/c.My_Allergy_Update';

import ALLERGY_DELETION_MSG_LABEL from '@salesforce/label/c.My_Allergy_deletion_msg';

import MY_ALLERGIES_HEADER_TEXT from "@salesforce/label/c.My_Allergies_Header_Text";
import {getObjectInfo} from "lightning/uiObjectInfoApi";

import ALLERGY_OBJECT from '@salesforce/schema/HealthCloudGA__EhrAllergyIntolerance__c';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {deleteRecord} from "lightning/uiRecordApi";

export default class KhcMyAllergies extends LightningElement {

    activePage = list;
    showSpinner = true;
    headerText = MY_ALLERGIES_HEADER_TEXT;

    editLabel = EDIT_LABEL;
    saveLabel = SAVE_LABEL;
    removeLabel = REMOVE_LABEL;
    addLabel = ADD_LABEL;
    noAllergyLabel = NO_ALLERGY_LABEL;
    cancelLabel = CANCEL_LABEL;

    allergies;

    render(){
        return this.activePage
    }

    retrieveAllergies(){
        getAllergies()
            .then( result =>{
                this.allergies = result;
            })
            .catch( error => {
                console.error( error );
                this.showSpinner = false;
            } );
    }

    get hasAllergies(){
        if( this.allergies != undefined && this.allergies.length > 0){
            return true;
        }
        return false;
    }

    connectedCallback(){
        this.retrieveAllergies();
        this.showSpinner = false;
        if( this.loggedInUser == undefined){
            getLoggedInUserDetails()
                .then( result => {
                    this.loggedInUser = result;
                })
                .catch( error => {});
        }
    }

    handleAddAllergyClick(){
        this.recordId = null;
        this.activePage = edit;
        this.headerText = MY_ALLERGIES_HEADER_TEXT;
        this.saveLabel = SAVE_LABEL;
    }
    handleEditAllergyClick( evt ){
        this.recordId = evt.target.dataset.id;
        this.showSpinner = true;
        this.activePage = edit;
        this.headerText = EDIT_HEADER_TEXT;
        this.saveLabel = UPDATE_LABEL;
    }

    handleCancelAllergyClick(){
        this.activePage = list;
    }

    allergyFields;

    @wire(getObjectInfo, { objectApiName: ALLERGY_OBJECT })
    oppInfo({ data, error }) {
        if (data){
            let fieldList = [
                { apiName :  "Allergen_Name__c", label : data.fields.Allergen_Name__c.label},
                { apiName :  "Allergy_Type__c", label : data.fields.Allergy_Type__c.label},
                { apiName :  "Severity__c", label : data.fields.Severity__c.label},
                { apiName :  "Reaction_Type__c", label : data.fields.Reaction_Type__c.label},
                { apiName :  "HealthCloudGA__Reaction__c", label : data.fields.HealthCloudGA__Reaction__c.label},
            ];
            this.allergyFields = fieldList;
        }
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
            this.template.querySelectorAll( '.allergy-form lightning-input-field').forEach( elm => {
                if( !elm.reportValidity() ) resolve( false );
            });
            resolve( true );
        });
        checkValid.then( result => {
            if( result ){
                this.template.querySelector(".submit-allergy").click();
            }else{
                this.showSpinner = false;
            }
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

    handleRemoveClick(){
        if( this.recordId != undefined && this.recordId != '' ){
            this.showSpinner = true;
            deleteRecord( this.recordId )
                .then(() => {
                    this.showToast( SUCCESS_LABEL, ALLERGY_DELETION_MSG_LABEL, 'success' );
                    this.showSpinner = false;
                    this.refreshComponent();
                })
                .catch(error => {
                    console.error(error);
                    this.showToast( ERROR_LABEL, error.body.message, 'error' );
                    this.showSpinner = false;
                });
        }
    }

    /**
     * @description Refresh and display list view
     */
    refreshComponent(){
        this.recordId = '';
        this.activePage = list;
        this.retrieveAllergies();
    }

}