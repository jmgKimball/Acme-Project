/**
 * Custom component for viewing and editing Family Health History records and their children
 *
 * @author Grant Adamson, Traction on Demand
 * @date 2020-09-17
 */
import {LightningElement, track, wire} from 'lwc';
import userId from "@salesforce/user/Id";
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import {deleteRecord} from 'lightning/uiRecordApi';
import getAccountIdForUser from "@salesforce/apex/KHC_AccountService.getAccountIdForUser";
import loadHistory from "@salesforce/apex/KHC_FamilyHealthHistoryCtlr.loadHistory";

import FAMILY_MEDICAL_HISTORY_OBJECT from '@salesforce/schema/Patient_Contact__c';

import RELATIONSHIP_FIELD from '@salesforce/schema/Patient_Contact__c.Relationship__c';
import RELATED_THROUGH_FAMILY_MEMBER_FIELD from '@salesforce/schema/Patient_Contact__c.Related_through_family_member__c';
import FAMILY_MEMBER_NAME_FIELD from '@salesforce/schema/Patient_Contact__c.Family_Member_Name__c';
import GENDER_FIELD from '@salesforce/schema/Patient_Contact__c.Gender__c';
import WAS_THIS_PERSON_BORN_A_TWIN_OR_MULTIPLE_FIELD from '@salesforce/schema/Patient_Contact__c.Was_this_person_born_a_twin_multiple__c';
import BIRTH_YEAR_FIELD from '@salesforce/schema/Patient_Contact__c.Birth_Year__c';
import ADOPTED_FIELD from '@salesforce/schema/Patient_Contact__c.Adopted__c';
import RACE_PICKLIST_FIELD from '@salesforce/schema/Patient_Contact__c.Race_Picklist__c';
import RACE_FIELD from '@salesforce/schema/Patient_Contact__c.Race__c';

import ETHNICITY_FIELD from '@salesforce/schema/Patient_Contact__c.Ethnicity__c';
import ARE_THEY_ASHKENAZI_JEWISH_FIELD from '@salesforce/schema/Patient_Contact__c.Are_They_Ashkenazi_Jewish__c';
import IS_THIS_PERSON_LIVING_FIELD from '@salesforce/schema/Patient_Contact__c.Is_this_person_living__c';
import ESTIMATED_AGE_AT_DEATH_FIELD from '@salesforce/schema/Patient_Contact__c.Estimated_Age_at_Death__c';
import CAUSE_OF_DEATH_FIELD from '@salesforce/schema/Patient_Contact__c.Cause_of_Death__c';

import view from './view.html';
import edit from './edit.html';

import FAMILY_HEALTH_HEADER_TEXT from "@salesforce/label/c.Family_Health_Header_Text";
import ADD_ANOTHER_FAMILY_MEMBER_LABEL from "@salesforce/label/c.Add_Another_Family_Member";
import EDIT_LABEL from "@salesforce/label/c.Edit";
import FAMILY_HEALTH_ADD_HEADER_TEXT from "@salesforce/label/c.Family_Health_Add_Header_Text";
import FAMILY_HEALTH_EDIT_HEADER_TEXT from "@salesforce/label/c.Family_Health_Edit_Header_Text";
import ADD_FAMILY_MEMBER_LABEL from "@salesforce/label/c.Add_Family_Member";
import ADD_NEW_FAMILY_MEMBER_LABEL from "@salesforce/label/c.Add_New";
import UPDATE_LABEL from "@salesforce/label/c.Update";
import REMOVE_FAMILY_MEMBER_LABEL from "@salesforce/label/c.Remove_Family_Member";
import CANCEL_LABEL from "@salesforce/label/c.Cancel";
import REMOVE_LABEL from "@salesforce/label/c.Remove";
import DOWNLOAD_MY_FAMILY_HISTORY_LABEL from "@salesforce/label/c.Download_My_Family_History";

const FIELDS = [
    FAMILY_MEMBER_NAME_FIELD, GENDER_FIELD,
    WAS_THIS_PERSON_BORN_A_TWIN_OR_MULTIPLE_FIELD, BIRTH_YEAR_FIELD, ADOPTED_FIELD, RACE_PICKLIST_FIELD, ETHNICITY_FIELD,
    ARE_THEY_ASHKENAZI_JEWISH_FIELD
];

export default class KhcFamilyHealthHistory extends LightningElement {
    headerText = FAMILY_HEALTH_HEADER_TEXT;
    addAnotherFamilyMemberLabel = ADD_ANOTHER_FAMILY_MEMBER_LABEL;
    addNewFamilyMemberLabel = ADD_NEW_FAMILY_MEMBER_LABEL;
    editLabel = EDIT_LABEL;
    saveLabel = ADD_FAMILY_MEMBER_LABEL;
    removeFamilyMemberLabel = REMOVE_FAMILY_MEMBER_LABEL;
    cancelLabel = CANCEL_LABEL;
    removeLabel = REMOVE_LABEL;
    downloadMyFamilyHistoryLabel = DOWNLOAD_MY_FAMILY_HISTORY_LABEL;

    showSpinner = false;
    activePage = view;
    patientId;

    medicalHistoryFields;
    
    @track history = [];
    @track editId;
    @track editExistingConditions;
    familyMemberRecordTypeID;
    hasNoRelationship = true;
    isLiving = false;
    disableRelationshipFields = ['Mother', 'Father', 'Full Sibling'];

    @wire(getObjectInfo, { objectApiName: FAMILY_MEDICAL_HISTORY_OBJECT })
    oppInfo({ data, error }) {
        if (data){
            this.medicalHistoryFields = FIELDS.map(field => ({
                apiName: field.fieldApiName,
                label: data.fields[field.fieldApiName].label
            }));

            if(data.recordTypeInfos) {
                let recordIds = data.recordTypeInfos;
                this.familyMemberRecordTypeID = Object.keys(recordIds).find(id => recordIds[id].name === 'Family Medical History');
            }

        } else if(error) {
            console.error(error);
        }
    }

    get hasEditId() {
        return !!this.editId;
    }
    
    get downloadFamilyHistoryLink(){
        return '/apex/KHC_ExportMedicalHistory?id=' + this.patientId;
    }

    async connectedCallback() {
        try {
            this.patientId = await getAccountIdForUser({userId});
            await this.refreshHistory();
        } catch (e) {
            console.error(e.body.message);
        }
    }

    async refreshHistory() {
        if(!this.patientId) {
            this.history = [];
        }

        try {
            this.history = await loadHistory({patientId: this.patientId});
        } catch (e) {
            console.error(e.body.message);
        }
    }

    render() {
        return this.activePage;
    }

    onEdit(event) {
        this.showSpinner = true;
        this.headerText = FAMILY_HEALTH_EDIT_HEADER_TEXT;
        this.saveLabel = UPDATE_LABEL;
        this.editId = event.target.dataset.id;

        const record = this.history.find(item => item.Id === this.editId);

        this.hasNoRelationship = this.disableRelationshipFields.includes(record.Relationship__c) || !record.Relationship__c;
        this.isLiving = record.Is_this_person_living__c;
        this.editExistingConditions = record.Family_Medical_History_Conditions__r;
        this.activePage = edit;
    }

    onAdd() {
        this.showSpinner = true;
        this.headerText = FAMILY_HEALTH_ADD_HEADER_TEXT;
        this.saveLabel = ADD_FAMILY_MEMBER_LABEL;
        this.hasNoRelationship = true;
        this.isLiving = false;
        this.activePage = edit;
    }

    onFormLoad() {
        this.showSpinner = false;
    }

    onSave() {
        this.template.querySelector("button[type='submit']").click();
    }

    onFormSubmit() {
        this.showSpinner = true;
    }

    async onFormSuccess(event) {
        this.editId = event.detail.id;
        // For whatever reason the update to editId when new records are created wasn't reflected in the
        // conditions component, so explicitly sending it in the save function
        await this.saveConditions(this.editId);
        await this.refreshHistory()
        this.switchToViewPage();
        this.showSpinner = false;
    }

    async saveConditions(historyId) {
        const conditionsEditor = this.template.querySelector("c-khc-family-conditions-editor");
        await conditionsEditor.save(historyId);
    }

    onFormError() {
        this.showSpinner = false;
    }

    async onRemove() {
        try {
            await deleteRecord(this.editId);
            await this.refreshHistory();
        } catch(e) {
            console.error(e.body.message);
        }
        this.switchToViewPage();
    }

    onCancel() {
        this.switchToViewPage();
    }

    switchToViewPage() {
        this.headerText = FAMILY_HEALTH_HEADER_TEXT;
        this.editId = null;
        this.editExistingConditions = null;
        this.activePage = view;
    }

    setFamilyRelationField() {
        let relationship = this.template.querySelector("lightning-input-field[data-name='relationship']");
        this.hasNoRelationship = this.disableRelationshipFields.includes(relationship.value) || !relationship.value;

        if(this.hasNoRelationship) {
            this.template.querySelector("lightning-input-field[data-name='familyRelationship']").value = '';
        }
    }

    setDeathFields() {
        let isPersonLiving = this.template.querySelector("lightning-input-field[data-name='isPersonLiving']");
        this.isLiving = isPersonLiving.value;

        if(this.isLiving) {
            this.template.querySelector("lightning-input-field[data-name='ageAtDeath']").value = '';
            this.template.querySelector("lightning-input-field[data-name='causeOfDeath']").value = '';
        }
    }

    get disableDeathFields() {
        return this.isLiving ? 'khc-disabled-field' : '';
    }

    get disableFamilyRelationshipFields() {
        return this.hasNoRelationship ? 'khc-disabled-field' : '';
    }

}