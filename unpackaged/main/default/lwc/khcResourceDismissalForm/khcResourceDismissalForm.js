/**
 * Created by mlandels on 2021-06-14.
 */

// Salesforce
import {LightningElement, api, wire} from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import REFERRAL_DISMISSAL_REASON from '@salesforce/schema/Referral_Record__c.Dismissal_Reason__c';
import REFERRAL_RECORD_OBJECT from '@salesforce/schema/Referral_Record__c';
import {ShowToastEvent} from "lightning/platformShowToastEvent";

// Apex
import removeReferral from '@salesforce/apex/KHC_ResourceLibraryCtrl.removeReferral';

// Labels
import DISMISS_LABEL from '@salesforce/label/c.Dismiss'
import SELECT_DISMISSAL_REASON_LABEL from '@salesforce/label/c.Select_Dismissal_Reason'
import A_DISMISSAL_REASON_MUST_BE_SELECTED_LABEL from '@salesforce/label/c.A_Dismissal_Reason_Must_Be_Selected'
import ERROR_LABEL from "@salesforce/label/c.Error";
import SUCCESS_LABEL from "@salesforce/label/c.Success";

export default class KhcResourceDismissalForm extends LightningElement {
    dismissLabel = DISMISS_LABEL;
    selectDismissalReasonLabel = SELECT_DISMISSAL_REASON_LABEL;

    @api
    knowledgeArticleId;
    dismissalPicklistValues;
    selectedDismissalReason;

    @wire(getObjectInfo, { objectApiName: REFERRAL_RECORD_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: REFERRAL_DISMISSAL_REASON
    })
    wiredPickListValue({ data, error }){
        if(data){
            this.dismissalPicklistValues = data.values;
        }
        if(error){
            console.log('Error getting Dismissal_Reason__c picklist values', error);
            this.dismissalPicklistValues = undefined;
        }
    }

    handleChange(event) {
        this.selectedDismissalReason = event.detail.value;
    }

    handleDismissReferral (event) {
        if ( !this.selectedDismissalReason ) {
            this.showToastMessage( ERROR_LABEL, A_DISMISSAL_REASON_MUST_BE_SELECTED_LABEL, 'error' );
            return;
        }

        removeReferral ({
            knowledgeArticleId : this.knowledgeArticleId,
            dismissalReason : this.selectedDismissalReason
        }).then(result =>{
            this.dispatchEvent(new CustomEvent('dismiss'));
            this.showToastMessage( SUCCESS_LABEL, '', 'success' );
        }).catch(error=>{
            this.showToastMessage( ERROR_LABEL, error, 'error' );
        })

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