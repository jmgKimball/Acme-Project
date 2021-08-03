// Salesforce
import { LightningElement, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import isGuest from '@salesforce/user/isGuest';
import CASE_OBJECT from '@salesforce/schema/Case';

// Labels
import SUCCESS_LABEL from "@salesforce/label/c.Success";
import ERROR_LABEL from "@salesforce/label/c.Error";
import KNOWLEDGE_RESOURCE_RECOMMENDATION_LABEL from "@salesforce/label/c.Knowledge_Resource_Recommendation";
import NAME_LABEL from "@salesforce/label/c.Name";

// Apex
import getTopics from '@salesforce/apex/KHC_ResourceLibraryCtrl.getTopics';
import getLoggedInUser from '@salesforce/apex/KHC_MyContactsController.getLoggedInUser';

export default class KhcResourceLibrary extends LightningElement {
    // Labels
    editHeaderText = KNOWLEDGE_RESOURCE_RECOMMENDATION_LABEL;
    nameLabel = NAME_LABEL;

    // Data
    recordTypeId;
    contactId;
    loggedInUser;
    topicOptions;
    hasFilters = false;
    selectedTopics = [];

    // Page State Attributes
    isGuest = isGuest;
    showSpinner = true;
    referred;
    favourite;
    knowledge;
    filters;

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    caseInfo({ data, error }) {
        if ( isGuest ) {
            this.getTopics();
            return;
        }

        if( data ){
            if( data.recordTypeInfos ){
                Object.keys( data.recordTypeInfos ).forEach( recordTypeId =>{
                    if( data.recordTypeInfos[recordTypeId].name == 'Knowledge Resource Recommendation' ){
                        this.recordTypeId = recordTypeId;
                    }
                });
            }
            this.getLoggedInUser();
            this.getTopics();
            this.loaded = true;
            this.showSpinner = false;
        }
    }

    get showLandingScreen(){
        return ( !this.hasFilters && !this.knowledge );
    }

    get showSearchScreen(){
        return ( this.hasFilters && !this.knowledge );
    }

    getTopics(){
        let topicOptions = [];
        getTopics()
            .then( result =>{
                if( result ){
                    result.forEach( topic =>{
                        topicOptions.push( { label: topic, value: topic } );
                    });
                    this.topicOptions = topicOptions;
                }
            }).catch( error =>{
                this.showToastMessage( ERROR_LABEL, error, 'error' );
            });
    }

    handleTopicSearch (event) {
        this.hasFilters = true;
        if( event.detail ){
            if( event.detail.topics ){
                this.selectedTopics = event.detail.topics;
            }
            if( event.detail.referred ){
                this.referred = true;
            }
            if( event.detail.favourites ){
                this.favourite = true;
            }
        }
    }

    handleShowResource( event ){
        if( event.detail ){
            if( event.detail.knowledge ){
                this.knowledge = event.detail.knowledge;
                this.filters = event.detail.filters;
            }else{
                this.knowledge = event.detail;
            }
            
        }
    }

    handleBack( event ){
        if( event.detail ){
            this.hasFilters = true;
            this.knowledge = undefined;
        }else{
            this.knowledge = undefined;
            this.refreshComponent();
        }
        
    }
    getLoggedInUser(){
        getLoggedInUser()
            .then( results => {
                this.loggedInUser = results; 
                this.contactId = results.ContactId;
            }).
        catch( error => {
            this.showToastMessage( ERROR_LABEL, error, 'error' );
        });
    }

    handleLoad(){
        this.showSpinner = false;
    }

    handleSuccess( res ){
        this.showToastMessage( SUCCESS_LABEL, res, 'success' );
        this.showSpinner = false;
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
                variant: variant
            }),
        );
    }

    refreshComponent( ){
        this.hasFilters = false;
        this.selectedTopics = [];
        this.referred = false;
        this.favourite = false;
        this.filters = undefined;
    }
}