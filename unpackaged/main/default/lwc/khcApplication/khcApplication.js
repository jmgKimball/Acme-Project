/**
 * Created by vupneja on 2/18/2021.
 */

import {api, LightningElement, wire, track} from 'lwc';

import getApplications from '@salesforce/apex/KHC_ApplicationController.getApplications';
import getLoggedInUserDetails from '@salesforce/apex/KHC_ApplicationController.getLoggedInUserDetails';
import withdrawApplication from '@salesforce/apex/KHC_ApplicationController.withdrawApplication';
import getPatientDetails from '@salesforce/apex/KHC_ApplicationController.getPatientDetails';
import getPatientNavigationRecordTypeID from '@salesforce/apex/KHC_ApplicationController.getPatientNavigationRecordTypeID';

import list from './list.html';
import edit from './edit.html';

import SUCCESS_LABEL from "@salesforce/label/c.Success";
import ERROR_LABEL from "@salesforce/label/c.Error";
import EDIT_LABEL from "@salesforce/label/c.Edit";
import CANCEL_LABEL from '@salesforce/label/c.Cancel';
import SAVE_LABEL from '@salesforce/label/c.Application_Save';
import ADD_LABEL from '@salesforce/label/c.Application_Add_Button';
import WITHDRAW_LABEL from '@salesforce/label/c.Application_Withdraw_Button';
import APP_WITHDRAWAL_MSG_LABEL from '@salesforce/label/c.Application_Withdraw_Msg';
import APP_ERROR_MSG_LABEL from '@salesforce/label/c.Application_Error_Msg';
import APP_SUCCESS_MSG_LABEL from '@salesforce/label/c.Application_Success_Msg';
import MY_APPLICATION_HEADER_TEXT from "@salesforce/label/c.Application_Header";
import MY_ADD_APPLICATION_HEADER_TEXT from '@salesforce/label/c.Application_Add_Header';
import UNAPPROVED_LABEL from '@salesforce/label/c.Application_Unapproved';
import APPROVED_LABEL from '@salesforce/label/c.Application_Approved';
import INPROCESSING_LABEL from '@salesforce/label/c.Application_In_Processing';
import NO_APPLICATION_LABEL from '@salesforce/label/c.Application_No_Entry';
import APPLICATION_DESCRIPTION_LABEL from '@salesforce/label/c.Application_Field_Description';
import APPLICATION_DATE_WITHDRAWN_LABEL from '@salesforce/label/c.Application_Date_Withdrawn';
import APPLICATION_NOT_APPROVED_LABEL from '@salesforce/label/c.Application_Not_Approved';
import APPLICATION_WITHDRAWN_LABEL from '@salesforce/label/c.Application_Withdrawn';

import {getObjectInfo} from "lightning/uiObjectInfoApi";
import APPLICATION_OBJECT from '@salesforce/schema/Application__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class KhcMyApplication extends LightningElement {

    activePage = list;
    showSpinner = true;
    headerText = MY_APPLICATION_HEADER_TEXT;
    headerAddText = MY_ADD_APPLICATION_HEADER_TEXT;
    editLabel = EDIT_LABEL;
    saveLabel = SAVE_LABEL;
    addLabel = ADD_LABEL;
    withdrawLabel = WITHDRAW_LABEL;
    cancelLabel = CANCEL_LABEL;
    approvedLabel=APPROVED_LABEL;
    inprocessingLabel=INPROCESSING_LABEL;
    noApplicationLabel = NO_APPLICATION_LABEL;
    statusLabel;
    emailLabel;
    sourceLabel;
    stateLabel;
    abnormalLabel;
    activeLabel;
    applicationApproved ;
    applicationPending;
    applicationNotApproved;
    applicationWithdrawn;
    applicationDescription = APPLICATION_DESCRIPTION_LABEL;
    applicationNumberLabel;
    withdrawnDate;
    applicationDateWithdrawn = APPLICATION_DATE_WITHDRAWN_LABEL;
    applicationNotApprovedLabel = APPLICATION_NOT_APPROVED_LABEL;
    applicationWithdrawnLabel = APPLICATION_WITHDRAWN_LABEL;

    render(){
        return this.activePage
    }

    /**
     * @description fetch the Application data the list screen
     */
    retrieveApplicationRequests(){
        getApplications()
            .then( result =>{
                let applicationApp = [];
                let applicationPend = [];
                let applicationNotApproved = [];
                let applicationWithdrawn = [];
                result.forEach( applicationRequest => {
                    applicationRequest.showDetails = false;
                    applicationRequest.abnormalScreeningResultValue = applicationRequest.Abnormal_Screening_Result__c === true ? 'Yes' : 'No';
                    applicationRequest.inActiveTreatmentValue = applicationRequest.In_Active_Treatment__c === true ? 'Yes' : 'No';

                    if (applicationRequest.Application_Status__c == 'Approved'
                        || applicationRequest.Application_Status__c == 'Completed') {
                        applicationApp.push(applicationRequest);
                    }
                    if (applicationRequest.Application_Status__c == 'Rejected'
                        || applicationRequest.Application_Status__c == 'Deferred') {
                        applicationNotApproved.push(applicationRequest);
                    }

                    if (applicationRequest.Application_Status__c == 'Canceled') {
                        this.withdrawnDate = applicationRequest.Status_Change_Date__c.substring(0,10);
                        applicationWithdrawn.push(applicationRequest);
                    }

                    if (applicationRequest.Application_Status__c == 'New' || applicationRequest.Application_Status__c == 'Need More Information'
                        || applicationRequest.Application_Status__c == 'In Review') {
                        applicationPend.push(applicationRequest);
                    }
                });
                this.applicationApproved = applicationApp;
                this.applicationPending = applicationPend;
                this.applicationNotApproved = applicationNotApproved;
                this.applicationWithdrawn = applicationWithdrawn;
            })
            .catch( error => {
                console.error( '** error **' + error );
                this.showSpinner = false;
            } );
    }

    get hasApplications(){
        if( (this.applicationApproved != undefined && this.applicationApproved.length > 0) ||
            ( this.applicationPending != undefined && this.applicationPending.length > 0) ||
            ( this.applicationNotApproved != undefined && this.applicationNotApproved.length > 0) ||
        this.applicationWithdrawn != undefined && this.applicationWithdrawn.length > 0)
            return true;
        return false;
    }

    get hasApprovedApplications(){
        return this.applicationApproved !== undefined && this.applicationApproved.length > 0;
    }

    get hasPendingApplications(){
        return this.applicationPending !== undefined && this.applicationPending.length > 0;
    }

    get hasNotApprovedApplications(){
        return this.applicationNotApproved !== undefined && this.applicationNotApproved.length > 0;
    }

    get hasWithdrawnApplications() {
        return this.applicationWithdrawn !== undefined && this.applicationWithdrawn.length > 0;
    }

    connectedCallback(){
        this.retrieveApplicationRequests();
        this.showSpinner = false;
        if( this.loggedInUser == undefined){
            getLoggedInUserDetails()
                .then( result => {
                    this.loggedInUser = result;
                })
                .catch( error => {});
        }
    }

    handleAddApplicationClick(){
        this.recordId = null;
        this.activePage = edit;
        this.headerText = MY_APPLICATION_HEADER_TEXT;
        this.saveLabel = SAVE_LABEL;
    }

    /**
     * @description To handle the withdrawal of the Application
     */
    handleWithdrawApplication(evt){
        this.showSpinner = true;
        this.recordId = evt.target.dataset.id;
        withdrawApplication({ enrollmentId: this.recordId  })
            .then( (result) => {
                this.showToast( SUCCESS_LABEL, APP_WITHDRAWAL_MSG_LABEL, 'success' );
                this.showSpinner = false;
                this.refreshComponent();
            }).catch(error => {
            console.error(error);
            this.showToast( ERROR_LABEL, error.body.message, 'error' );
            this.showSpinner = false;
        })
    }

    handleCancelClick(){
        this.activePage = list;
    }

    applicationFields;
    applicationPrePopulatedFields;

    /**
     * @description wire method to get the field list for Edit screen
     */
    @wire(getObjectInfo, { objectApiName: APPLICATION_OBJECT })
    oppInfo({ data, error }) {
        if (data){
            let fieldList = [
                { apiName :  "Abnormal_Screening_Result__c", label : data.fields.Abnormal_Screening_Result__c.label},
                { apiName :  "In_Active_Treatment__c", label : data.fields.In_Active_Treatment__c.label},
            ];
            this.connectedCallback();
            let prefilledfieldList = [
                { value :  "Patient Portal", label : data.fields.Application_Source__c.label},
                { value :  "New", label : data.fields.Application_Status__c.label},
            ];
            this.statusLabel = data.fields.Application_Status__c.label;
            this.emailLabel = data.fields.Patient_Email_Address__c.label;
            this.sourceLabel = data.fields.Application_Source__c.label;
            this.stateLabel = data.fields.Patient_State__c.label;
            this.abnormalLabel = data.fields.Abnormal_Screening_Result__c.label;
            this.activeLabel =data.fields.In_Active_Treatment__c.label;
            this.applicationNumberLabel = data.fields.Name.label;
            this.applicationFields = fieldList;
            this.applicationPrePopulatedFields = prefilledfieldList;
        }
    }

    /**
     * @description To render the spinner.
     */
    handleLoad( evt ){
        this.showSpinner = false;
    }

    /**
     * @description To handle success while submitting the new application
     */
    handleSuccess( evt ){
        this.showToast( SUCCESS_LABEL, APP_SUCCESS_MSG_LABEL, 'success' );
        this.refreshComponent();
        this.showSpinner = false;
    }

    /**
     * @description To handle error while submitting the new application
     */
    handleError( evt ){
        this.showToast( ERROR_LABEL, APP_ERROR_MSG_LABEL, 'error' );
        this.showSpinner = false;
    }

    /**
     * @description Handle the Submit of the new application
     */
    handleSubmit( evt ){
        evt.preventDefault();
        const fields = evt.detail.fields;
        getPatientDetails({accId:this.loggedInUser.Account__c})
            .then( (result) => {
                fields.Applicant_Email__c = result.PersonEmail;
            }).catch(error => {
            console.error(error);
        })
        getPatientNavigationRecordTypeID()
            .then((result) =>{
                fields.RecordTypeId=result;
            }).catch(error=>{
            console.error(error);
        })
        fields.Patient__c = this.loggedInUser.Account__c;
        fields.Application_Source__c= 'Patient Portal';
        fields.Application_Status__c = 'New';
        this.template.querySelector('lightning-record-edit-form').submit( fields );
    }

    /**
     * @description For Toast messages
     */
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
        this.recordId = '';
        this.activePage = list;
        this.retrieveApplicationRequests();
    }

    /**
     * @description Save of the new application
     */
    handleSave(){
        this.showSpinner = true;
        var checkValid = new Promise((resolve, reject) => {
            this.template.querySelectorAll( '.application-form lightning-input-field').forEach( elm => {
                if( !elm.reportValidity() ) resolve( false );
            });
            resolve( true );
        });
        checkValid.then( result => {
            if( result ){
                this.template.querySelector(".submit-application").click();
            }else{
                this.showSpinner = false;
            }
        });
    }

}