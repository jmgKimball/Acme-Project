/**
 * Created by mlandels on 2021-03-23.
 */
// Salesforce
import {LightningElement, api, wire} from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

// Labels
import REPORT_AN_ISSUE_LABEL from "@salesforce/label/c.Report_an_Issue";
import CASE_OBJECT from '@salesforce/schema/Case';

export default class KhcReportResourceIssue extends LightningElement {
    // Labels
    reportAnIssueLabel = REPORT_AN_ISSUE_LABEL;
    // Data
    @api knowledge;
    recordTypeId;
    // Page State Attributes
    showSpinner = true;

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    caseInfo({ data, error }) {
        if( data ){
            if( data.recordTypeInfos ){
                Object.keys( data.recordTypeInfos ).forEach( recordTypeId =>{
                    if( data.recordTypeInfos[recordTypeId].name == 'Knowledge Resource' ){
                        this.recordTypeId = recordTypeId;
                    }
                });
            }
        }
    }

    handleOnload(){
        this.showSpinner = false;    
    }

    handleSubmit() {
        this.showSpinner = true;
    }

    handleSuccess  (){
        this.showSpinner = false;
        const reportSuccessEvent = new CustomEvent( "reportissuesuccess", {} );
        this.dispatchEvent( reportSuccessEvent );
    }
}