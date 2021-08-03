/**
 * @description Lightning web component for My Health Condition
 * @author Vikrant Upneja, Traction on Demand
 * @date 9/12/2020.
 */

import {LightningElement, api, track, wire} from 'lwc';
import getConditionRecordType from '@salesforce/apex/kHC_MyHeathConditionsController.getConditionRecordType';
import getBCancerConditions from '@salesforce/apex/kHC_MyHeathConditionsController.getBCancerConditions';
import getChronicConditions from '@salesforce/apex/kHC_MyHeathConditionsController.getChronicConditions';
import getCondition from '@salesforce/apex/kHC_MyHeathConditionsController.getCondition';
import deleteRecord from '@salesforce/apex/KHC_DeleteUtility.deleteRecord';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import view from './view.html';
import edit from './edit.html';

import MY_HEALTH_CONDITION_HEADER_TEXT from "@salesforce/label/c.My_Health_Conditions_Header_Text";
import ADD_HEALTH_CONDITION_HEADER_TEXT from "@salesforce/label/c.Add_Health_Conditions_Text";
import CANCEL_LABEL from "@salesforce/label/c.Cancel";
import REMOVE_LABEL from "@salesforce/label/c.Remove";
import UPDATE_CONDITION_LABEL from "@salesforce/label/c.Update_health_condition";
import ADD_NEW_CONDITION_LABEL from "@salesforce/label/c.Add_new_condition";
import ADD_ANOTHER_CONDITION_LABEL from "@salesforce/label/c.Add_another_condition";
import ADD_NEW_HEALTH_CONDITION_LABEL from "@salesforce/label/c.Add_new_health_condition";
import NO_HEALTH_CONDITION_LABEL from "@salesforce/label/c.No_health_condition_exist";
import WHEN_WERE_YOU_DIAGNOSED_LABEL from "@salesforce/label/c.When_were_you_diagnosed";
import WHEN_DID_THIS_CONDITION_END_LABEL from "@salesforce/label/c.When_did_this_condition_end";
import EDIT_HEADER_LABEL from "@salesforce/label/c.Edit_Health_Condition";
import PICKLIST_OTHER_OPTION_LABEL from "@salesforce/label/c.Other_Picklist_Option"

export default class KhcMyHealthConditions extends LightningElement {

    headerText=MY_HEALTH_CONDITION_HEADER_TEXT;
    headerEditLabel = EDIT_HEADER_LABEL;
    headerAddText = ADD_HEALTH_CONDITION_HEADER_TEXT;

    cancelLabel = CANCEL_LABEL;
    removeLabel = REMOVE_LABEL;
    addNewConditionLabel = ADD_NEW_CONDITION_LABEL;
    updateConditionLabel = UPDATE_CONDITION_LABEL;
    addAnotherConditionLabel = ADD_ANOTHER_CONDITION_LABEL;
    addNewHealthConditionLabel = ADD_NEW_HEALTH_CONDITION_LABEL;
    noHealthConditionExistLabel = NO_HEALTH_CONDITION_LABEL;
    whenWereYouDiagnosed =WHEN_WERE_YOU_DIAGNOSED_LABEL;
    whenDidThisConditionEnd =WHEN_DID_THIS_CONDITION_END_LABEL;

    @api recordId;
    @api objectApiName;

    @track showSpinner = false;
    @track showViewHealthCondition = false;
    @track showHealthCondition = false;
    @track addHealthCondition = false;
    @track newHealthCondition = false;
    @track noHealthConditionExist = false;
    @track showBCEditHealthCondition = false;
    @track showChronicEditHealthCondition = false;
    @track editId;
    bcConditionExist = false;

    hcRecordTypeMap=[];
    bcCondition ;
    chronicCondition;
    conditionTypeValue = 'Breast Cancer';
    error;
    otherCancerTypeReadOnly = true;
    otherCancerSubTypeReadOnly = true;
    activePage = view;
    OTHER_CANCER_OPTION = PICKLIST_OTHER_OPTION_LABEL; 

    render(){
        return this.activePage;
    }

    get conditionTypeOptions() {
        return [{value:"Breast Cancer" , label:"Breast Cancer"},
            {value:"Other" , label:"Other"}];
    }

    setOtherCancerTypeField() {
        let typeSelectedOption = this.template.querySelector("lightning-input-field[data-name='breastCancerType']");
        let subTypeSelectedOption = this.template.querySelector("lightning-input-field[data-name='breastCancerSubType']");

        this.otherCancerTypeReadOnly = typeSelectedOption.value !== this.OTHER_CANCER_OPTION;
        this.otherCancerSubTypeReadOnly = subTypeSelectedOption.value !== this.OTHER_CANCER_OPTION;
    }

    /**
     * Get the all the RecordType List for Health Condition from apex using imperative method
     */
    getRecordType(){
        getConditionRecordType({}).then(result =>{
            if(result){
                let recordtypeMap =[];
                var conts = Object.keys(result);
                for(var key in conts){
                    recordtypeMap.push({value:result[conts[key]].Id,key:result[conts[key]].Name});
                }
                this.hcRecordTypeMap = recordtypeMap;
            }
        }).catch(error=>{
            console.error("getRecordType Error");
        })
    }

    /**
     * Get the all the Breast Cancer Condition from apex using imperative method
     */
    getBCConditions(){
        getBCancerConditions({
            currentLoggedAccount: this.recordId
        }).then(result =>{
            if(result){
                this.bcCondition = result;
                if(result.length >0){
                    this.bcCondition = result;
                    this.showHealthCondition = true;
                    this.showViewHealthCondition =true;
                    this.bcConditionExist = true;
                }else{
                    this.noHealthConditionExist = true;
                    this.showHealthCondition = false;
                    this.showViewHealthCondition =false;
                }
            }
        }).catch(error=>{
            console.error("BC Query Error");

        })
    }

    /**
     * Get the all the Health Condition from apex using imperative method
     */
    getChronicConditions(){
        getChronicConditions
        ({
            currentLoggedAccount: this.recordId
        }).then(result =>{
            if(result){
                if(result.length >0){
                    this.chronicCondition = result;
                    this.noHealthConditionExist = false;
                    this.showHealthCondition = true;
                    this.showViewHealthCondition =true;
                    //this.showEditHealthCondition =false;
                }else{
                    if(this.bcConditionExist == false){
                        this.noHealthConditionExist = true;
                        this.showHealthCondition = false;
                        this.showViewHealthCondition =false;
                    }
                }
            }
        }).catch(error=>{
            console.error("CC Query Error");
        })
    }

    /*
     * ConnectedCallback runs after all wires
     */
    connectedCallback() {
        this.bcCondition = null;
        this.chronicCondition = null;
        getBCancerConditions({
            currentLoggedAccount: this.recordId
        }).then(result =>{
            if(result.length>0){
                this.bcCondition = result;
                this.bcConditionExist = true;
                this.showHealthCondition = true;
                this.showViewHealthCondition = true;
                //this.showEditHealthCondition = false;
                this.noHealthConditionExist = false;
            }else{
                this.bcConditionExist = false;
            }
        }).catch(error=>{
            console.error("BC Query Error");
        })

        getChronicConditions
        ({
            currentLoggedAccount: this.recordId
        }).then(result =>{
            if(result.length>0){
                this.chronicCondition = result;
                //this.ccConditionExist = true;
                this.showHealthCondition = true;
                this.showViewHealthCondition = true;
                //this.showEditHealthCondition = false;
                this.noHealthConditionExist = false;
            }else{
                console.log('In Chronic Condition this.bcConditionExist ', this.bcConditionExist);
                if (this.bcConditionExist == false) {
                    this.noHealthConditionExist = true;
                    this.showHealthCondition = false;
                    this.showViewHealthCondition = false;
                }
            }
        }).catch(error=>{
            console.error("CC Query Error");
        })
        this.getRecordType();
    }

    /*
     *  Use the lightning/uiRecordApi to delete the record
     */
    deleteRecord(event) {
        const recordId = event.target.dataset.recordid;
        deleteRecord( {rec: { Id: recordId } } )
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Health Condition Is Deleted',
                        variant: 'success',
                    }),
                );
                this.getBCConditions();
                this.getChronicConditions();
                this.activePage = view;
                this.showSpinner = false;
            })
            .catch(error => {
                console.error("Error while deleting a health record ");
            });
    }

    /*
     *  Method to render View form of Health Condition
     */
    openViewForm() {
        this.activePage = view;
        this.showViewHealthCondition = true;
    }

    // Toggle between the Present Condition and the New Conditions
    addNewCondition(){
        this.showHealthCondition = false;
        this.addHealthCondition = true;
        this.showViewHealthCondition = false;
        this.otherCancerTypeReadOnly = true;
        this.otherCancerSubTypeReadOnly = true;
    }

    // New
    addFirstCondition(){
        this.newHealthCondition = true;
        this.noHealthConditionExist = false;
        this.otherCancerTypeReadOnly = true;
        this.otherCancerSubTypeReadOnly = true;
    }
    //new
    showNoCondition(){
        this.newHealthCondition = false;
        this.noHealthConditionExist = true;
        this.showSpinner = false;
    }

    showExistingCondition(){
        this.activePage = view;
        this.connectedCallback();
        this.addHealthCondition = false;
        this.newHealthCondition = false;
        this.noHealthConditionExist = false;
        this.showViewHealthCondition =true;
        this.showHealthCondition = true;
    }


    handleConditionTypeValueEvent(event) {
        this.conditionTypeValue = event.target.value;
    }

    get renderOptionalField() {
        return this.conditionTypeValue === 'Breast Cancer' ? true : false;
    }

    get recordTypeId(){
        //console.log('Getting value in recordTypeId -> ', this.hcRecordTypeMap.keys(), this.hcRecordTypeMap.values(), this.hcRecordTypeMap[0].key );
        if( this.conditionTypeValue == 'Breast Cancer' && this.hcRecordTypeMap[0].key == 'Breast Cancer' )
            return this.hcRecordTypeMap[0].value;
        else
            return this.hcRecordTypeMap[1].value;
    }
    onFormLoad() {
        this.showSpinner = false;
    }
    onFormSubmit() {
        this.showSpinner = true;
    }

    handleInputError() {
        this.showSpinner = false;
    }

    onEditBC(event) {
        this.editId = event.target.dataset.id;
        this.showBCEditHealthCondition = true;
        this.showChronicEditHealthCondition = false;
        this.activePage = edit;

        //if other cancer type is chosen, enable other cancer type field
        getCondition({recordId: this.editId, currentLoggedAccount: this.recordId})
            .then(result => {
                this.otherCancerTypeReadOnly = (result[0].Breast_Cancer_Type__c !== this.OTHER_CANCER_OPTION);
                this.otherCancerSubTypeReadOnly = (result[0].Breast_Cancer_Sub_Type__c !== this.OTHER_CANCER_OPTION);
            })
    }

    onEditChronic(event) {
        this.editId = event.target.dataset.id;
        this.showChronicEditHealthCondition = true;
        this.showBCEditHealthCondition = false;
        this.activePage = edit;
    }
}