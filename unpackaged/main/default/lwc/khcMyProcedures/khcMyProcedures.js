/**
 * Created by vupneja on 10/2/2020.
 */

import {LightningElement, api,wire ,track } from 'lwc';

import getProcedures from '@salesforce/apex/kHC_MyProceduresController.getProcedures';
import getEditProcedure from '@salesforce/apex/kHC_MyProceduresController.getEditProcedure'
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import deleteRecord from '@salesforce/apex/KHC_DeleteUtility.deleteRecord';

import view from './view.html';
import edit from './edit.html';

import ADD_ANOTHER_PROCEDURE_LABEL from "@salesforce/label/c.Add_another_procedure";
import ADD_FIRST_PROCEDURE_LABEL from "@salesforce/label/c.Add_first_procedure";
import NO_PROCEDURE_TEXT_LABEL from "@salesforce/label/c.No_Procedure_text";
import MY_SURGERY_HEADER_TEXT from "@salesforce/label/c.My_Surgeries_Header_Text";
import ADD_NEW_PROCEDURE_HEADER_TEXT from "@salesforce/label/c.Add_a_new_procedure";
import EDIT_PROCEDURE_HEADER_TEXT from "@salesforce/label/c.Edit_Procedure";
import CANCEL_LABEL from "@salesforce/label/c.Cancel";
import REMOVE_LABEL from "@salesforce/label/c.Remove";
import UPDATE_LABEL from "@salesforce/label/c.Update_Procedure";
import EDIT_LABEL from "@salesforce/label/c.Edit";
import OTHER_PROCEDURE_OPTION_LABEL from "@salesforce/label/c.Other_Procedure_Option"

import HEALTH_PROCEDURE_OBJECT from '@salesforce/schema/HealthCloudGA__EHRProcedure__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class KhcMyProcedures extends LightningElement {

    cancelLabel = CANCEL_LABEL;
    removeLabel = REMOVE_LABEL;
    updateLabel = UPDATE_LABEL;
    editLabel = EDIT_LABEL;
    addAnotherProcedureLabel = ADD_ANOTHER_PROCEDURE_LABEL;
    addFirstprocedureLabel = ADD_FIRST_PROCEDURE_LABEL;
    noproceduretextlabel = NO_PROCEDURE_TEXT_LABEL ;
    mySurgeryHeaderLabel = MY_SURGERY_HEADER_TEXT ;
    addNewProcedureHeaderLabel = ADD_NEW_PROCEDURE_HEADER_TEXT
    editProceduresHeaderLabel = EDIT_PROCEDURE_HEADER_TEXT;
    otherProcedureLabel = OTHER_PROCEDURE_OPTION_LABEL
    
    @api recordId;
    @api objectApiName;

    @track showSpinner = false;
    @track showProcedure = false;
    @track showViewProcedure = true;
    @track showEditProcedure = false;
    @track noProcedureExist = false;
    @track addProcedure = false;
    @track isFirstProcedure = false;
    @track editId;
    error;
    procedureList;
    procedureIsOther = false;
    procedureFields;

    activePage = view;

    @wire(getObjectInfo, { objectApiName: HEALTH_PROCEDURE_OBJECT })
    oppInfo({ data, error }) {
        if (data){
            let fieldList = [
                { apiName :  "HealthCloudGA__PerformedDateTime__c", label : data.fields.HealthCloudGA__PerformedDateTime__c.label},
            ];

            this.procedureFields = fieldList;
        }
    }

    handleEvent(event) {
        let eventValue = event.target.value;
        this.procedureIsOther = eventValue === this.otherProcedureLabel
    }

    get isRequired() {
        return this.procedureIsOther;
    }

    /**
     * Get the all the Procedures from apex using imperative method
     */
    getProcedureList(){
        getProcedures({
            currentLoggedAccount: this.recordId
        }).then(result=>{

            if(result){
                if(result.length ==0){
                    this.addProcedure = false;
                    this.noProcedureExist=true;
                    this.showViewProcedure = false;
                    this.showSpinner = false;
                }else{
                    this.showViewProcedure = true;
                }
                    [...result].map(record =>{
                        if(record.HealthCloudGA__PerformedDateTime__c )
                            record.HealthCloudGA__PerformedDateTime__c = (record.HealthCloudGA__PerformedDateTime__c).toString().substring(0,4);
                        else record.HealthCloudGA__PerformedDateTime__c = '';
                    })
                this.procedureList = result;
            }
        }).catch(error=>{
            this.error = error;
            console.error("Error while getting the Procedures ", error);
        })
    }

    connectedCallback() {
        this.getProcedureList();
    }

    render(){
        return this.activePage;
    }

    /*
 *  Use the lightning/uiRecordApi to delete the record
 */
    deleteRecord(event) {
        const recordId = event.target.dataset.id;
        deleteRecord( {rec: { Id: recordId } } )
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Procedure Is Deleted',
                        variant: 'success',
                    }),
                );
                //this.getConditions();

                this.showSpinner = false;
                this.connectedCallback();
                this.activePage = view;
            })
            .catch(error => {
                console.error("Error while deleting a procedure record ", error);
            });
    }

    onEdit(event) {
        this.editId = event.target.dataset.id;
        getEditProcedure({currentLoggedAccount: this.recordId, recordId: this.editId})
            .then(result => {
                if(result.length > 0) {
                    this.procedureIsOther = result[0].Procedure_Type__c === this.otherProcedureLabel;
                }
            });

        this.showEditProcedure = true;
        this.activePage = edit;
    }

    openEditForm(){
        this.showViewProcedure = false;
        this.showEditProcedure = true;
    }

    openViewForm(){
        this.connectedCallback();
        this.editId = null;
        this.activePage = view;
        this.showEditProcedure = false;
        this.showViewProcedure = true;
    }

    addFirstProcedure(){
        this.isFirstProcedure = true;
        this.noProcedureExist = false;
        this.procedureIsOther = false;
    }

    showNoProcedure(){
        this.isFirstProcedure = false;
        this.noProcedureExist = true;
    }

    addNewProcedure(){
        this.activePage = view;
        this.showViewProcedure = false;
        this.showEditProcedure = false;
        this.showProcedure = false;
        this.addProcedure = true;
        this.showSpinner = false;
        this.procedureIsOther = false;
    }

    showExistingProcedure(){
        this.activePage = view;
        this.showSpinner = false;
        this.showViewProcedure = true;
        this.showProcedure = false;
        this.addProcedure = false;
    }

    showRefreshExistingProcedure(){
        this.connectedCallback();
        this.activePage = view;
        this.showSpinner = false;
        this.showViewProcedure = true;
        this.showProcedure = false;
        this.addProcedure = false;
        this.noProcedureExist = false;
        this.isFirstProcedure =false;
    }

    onFormLoad() {
        this.showSpinner = false;
    }

    onFormSubmit() {
        this.showSpinner = true;
    }

}