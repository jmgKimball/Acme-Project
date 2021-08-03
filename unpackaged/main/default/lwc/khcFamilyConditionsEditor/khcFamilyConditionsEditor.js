/**
 * Controller for condition sub-component used as part of Family Health History
 *
 * @author Grant Adamson, Traction on Demand
 * @date 2020-09-17
 * Modified 2020-11-25:Vikrant Upneja  SGK20-463 (Story)
 */
import {LightningElement, api, track, wire} from 'lwc';
import updateConditions from "@salesforce/apex/KHC_FamilyHealthHistoryCtlr.updateConditions";

import ADD_A_HEALTH_ISSUE_LABEL from "@salesforce/label/c.Add_a_Health_Issue";
import REMOVE_LABEL from "@salesforce/label/c.Remove";
import HEALTH_ISSUE_LABEL from "@salesforce/label/c.Health_Issue";
import ERROR_LABEL from "@salesforce/label/c.error";

import CONDITION_OBJECT from '@salesforce/schema/Family_Medical_History_Condition__c';
import CATEGORY_FIELD from '@salesforce/schema/Family_Medical_History_Condition__c.Condition_Category__c';
import SUBCATEGORY_FIELD from '@salesforce/schema/Family_Medical_History_Condition__c.Condition_Sub_Category__c';
import AGE_AT_DIAGNOSIS_FIELD from '@salesforce/schema/Family_Medical_History_Condition__c.Age_at_diagnosis__c';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import {getPicklistValues} from 'lightning/uiObjectInfoApi';
import {ShowToastEvent} from "lightning/platformShowToastEvent";


export default class KhcFamilyConditionsEditor extends LightningElement {
    addHealthIssueLabel = ADD_A_HEALTH_ISSUE_LABEL;
    removeLabel = REMOVE_LABEL;
    healthIssueLabel = HEALTH_ISSUE_LABEL;
    categoryLabel = "Category"; // These values will be overwritten once getObjectInfo wire call has executed
    subcategoryLabel = "Sub-Category";
    ageAtDiagnosisLabel = "Age at Diagnosis";

    @api historyId;
    @track categoryOptions;
    @track subCategoryOptions;
    @track ageAtDiagnosisOptions;
    @track conditions = [];
    conditionsToDelete = [];

    @api set existingConditions(value) {
        if (value) {
            this.conditions = [...value];
        }
    }

    get existingConditions() {}

    @wire(getObjectInfo, {objectApiName: CONDITION_OBJECT})
    conditionObjectInfo({data, error}) {
        if (data) {
            this.categoryLabel = data.fields[CATEGORY_FIELD.fieldApiName].label;
            this.subcategoryLabel = data.fields[SUBCATEGORY_FIELD.fieldApiName].label;
            this.ageAtDiagnosisLabel = data.fields[AGE_AT_DIAGNOSIS_FIELD.fieldApiName].label;
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getPicklistValues, {recordTypeId: '012000000000000AAA', fieldApiName: CATEGORY_FIELD})
    categoryFieldInfo({data, error}) {
        if (data) {
            this.categoryOptions = data.values;
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getPicklistValues, {recordTypeId: '012000000000000AAA', fieldApiName: SUBCATEGORY_FIELD})
    subCategoryFieldInfo({data, error}) {
        if (data) {
            this.subCategoryFieldData = data;
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getPicklistValues, {recordTypeId: '012000000000000AAA', fieldApiName: AGE_AT_DIAGNOSIS_FIELD})
    ageAtDiagnosisFieldInfo({data, error}) {
        if (data) {
            this.ageAtDiagnosisOptions = data.values;
        } else if (error) {
            console.error(error);
        }
    }

    handleCategoryChange(event) {
        let key = this.subCategoryFieldData.controllerValues[event.target.value];
        this.subCategoryOptions = this.subCategoryFieldData.values.filter(opt => opt.validFor.includes(key));
    }

    onAdd() {
        const categoryInput = this.template.querySelector(".category");
        const subCategoryInput = this.template.querySelector(".sub-category");
        const ageAtDiagnosisInput = this.template.querySelector(".age-at-diagnosis");

        if (categoryInput.reportValidity() && subCategoryInput.reportValidity() && ageAtDiagnosisInput.reportValidity()) {
            const condition = {};
            condition[CATEGORY_FIELD.fieldApiName] = categoryInput.value;
            condition[SUBCATEGORY_FIELD.fieldApiName] = subCategoryInput.value

            if (ageAtDiagnosisInput.value) {
                condition[AGE_AT_DIAGNOSIS_FIELD.fieldApiName] = ageAtDiagnosisInput.value;
            }

            this.conditions.push(condition);

            categoryInput.value = null;
            subCategoryInput.value = null;
            ageAtDiagnosisInput.value = null;
        }
    }

    onRemove(event) {
        const index = parseInt(event.target.dataset.index);

        const condition = this.conditions[index];
        if (condition.Id) {
            this.conditionsToDelete.push(condition);
        }

        this.conditions.splice(index, 1);
    }

    @api
    async save(historyId) {
        this.historyId = historyId;

        const conditionsToInsert = this.getConditionsToInsert();
        const conditionsToDelete = this.conditionsToDelete;

        if (conditionsToInsert.length === 0 && conditionsToDelete.length === 0) {
            return;
        }

        try {
            await updateConditions({conditionsToInsert, conditionsToDelete});
        } catch (e) {
            console.error(e);
            this.dispatchEvent(new ShowToastEvent({
                title: ERROR_LABEL,
                message: e.body.message,
                variant: "error"
            }));
        }
    }

    getConditionsToInsert() {
        const result = [];

        this.conditions.forEach(condition => {
            if (!condition.Id) {
                condition.Family_Medical_History__c = this.historyId;
                result.push(condition);
            }
        });

        return result;
    }
}