// Salesforce
import { LightningElement, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import CASE_OBJECT from '@salesforce/schema/Case';

// Apex
import getLoggedInUser from '@salesforce/apex/KHC_MyContactsController.getLoggedInUser';

// Labels
import SUCCESS_LABEL from "@salesforce/label/c.Success";
import ERROR_LABEL from "@salesforce/label/c.Error";
import KNOWLEDGE_RESOURCE_RECOMMENDATION_LABEL from "@salesforce/label/c.Knowledge_Resource_Recommendation";
import NAME_LABEL from "@salesforce/label/c.Name";
import SAVE_LABEL from "@salesforce/label/c.Save";
import ABOUT_THE_PERSON_SUBMITTING_THE_REQUEST_LABEL from "@salesforce/label/c.About_the_person_submitting_the_request";
import ABOUT_THE_RESOURCE_LABEL from "@salesforce/label/c.About_the_recommended_resource";

export default class KhcKnowledgeResourceRecommendation extends LightningElement {
    // Labels
    editHeaderText = KNOWLEDGE_RESOURCE_RECOMMENDATION_LABEL;
    nameLabel = NAME_LABEL;
    saveLabel = SAVE_LABEL;
    aboutThePersonSubmittingTheRequestLabel = ABOUT_THE_PERSON_SUBMITTING_THE_REQUEST_LABEL;
    aboutTheResourceLabel = ABOUT_THE_RESOURCE_LABEL;

    // Data
    recordTypeId;
    contactId;
    caseType = 'Resource Recommendation';
    caseOrigin = 'Web';

    // Page State Attributes
    showSpinner = true;

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    supporterInfo({ data, error }) {
        if( data ){
            if( data.recordTypeInfos ){
                Object.keys( data.recordTypeInfos ).forEach( recordTypeId =>{
                    if( data.recordTypeInfos[recordTypeId].name == 'Knowledge Resource' ){
                        this.recordTypeId = recordTypeId;
                    }
                });
            }
            this.getLoggedInUser();
            this.loaded = true;
        }
    }

    getLoggedInUser(){
        getLoggedInUser()
            .then( results => {
                this.contactId = results.ContactId;
            }).
        catch( error => {
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
        this.showToastMessage( SUCCESS_LABEL, res, 'success' );
        this.showSpinner = false;
        const closeModal = new CustomEvent( "handlesuccess", {});
        this.dispatchEvent( closeModal );
    }
    handleError( error ){
        this.showToastMessage( ERROR_LABEL, error, 'error' );
        this.showSpinner = false;
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