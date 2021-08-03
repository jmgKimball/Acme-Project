import { LightningElement } from 'lwc';
import getProviders from '@salesforce/apex/KHC_SearchProviderController.getProviders';
import {updateRecord} from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import MY_CURRENT_PROVIDERS_LABEL from '@salesforce/label/c.My_Current_Providers';
import NO_EXISTING_PROVIDERS_LABEL from '@salesforce/label/c.No_Existing_Providers';
import MY_PAST_PROVIDERS_LABEL from '@salesforce/label/c.My_Past_Providers';
import ADD_A_NEW_PROVIDER_LABEL from '@salesforce/label/c.Add_a_new_provider';
import RECORD_UPDATED_SUCCESSFULLY_LABEL from '@salesforce/label/c.Record_updated_successfully';
import SEARCH_FOR_YOUR_PROVIDERS_LABEL from '@salesforce/label/c.Search_for_your_provider';
import BACK_LABEL from '@salesforce/label/c.Back';
import SUCCESS_LABEL from '@salesforce/label/c.Success';
import ERROR_LABEL from '@salesforce/label/c.Error';

export default class KhcMyProviders extends LightningElement {
    existingProviders = [];
    pastProviders = [];
    showAddProvider = false;
    currentSection = 'My_Provider';
    hideBackButton = false;

    myCurrentProvidersLabel = MY_CURRENT_PROVIDERS_LABEL;
    noExistingProvidersLabel = NO_EXISTING_PROVIDERS_LABEL;
    myPastProvidersLabel = MY_PAST_PROVIDERS_LABEL;
    addNewProviderLabel = ADD_A_NEW_PROVIDER_LABEL;
    recordUpdatesSUccessfullyLabel = RECORD_UPDATED_SUCCESSFULLY_LABEL;
    searchForYourProviderLabel = SEARCH_FOR_YOUR_PROVIDERS_LABEL;
    backLabel = BACK_LABEL;

    connectedCallback(){
        this.reteriveProviders();
    }

    get showExistingProviders(){
        return this.existingProviders.length > 0;
    }
    get showPastProviders(){
        return this.pastProviders.length > 0;
    }
    get showMyProividers(){
        return this.currentSection == 'My_Provider';
    }
    get showBack(){
        if(this.currentSection == 'Search_Provider')
            if(this.hideBackButton == false) return true;
        return false;
    }
    
    handleAddProviderClick(){
        this.showAddProvider = true;
        this.currentSection = 'Search_Provider';
    }
    handleBackClick(){
        if( this.currentSection == 'Search_Provider' ){
            this.showAddProvider = false;
            this.currentSection = 'My_Provider';
        }
    }

    reteriveProviders(){
        getProviders()
            .then( result => {
                let existingProviders = [];
                let pastProviders = [];
                result.forEach( provider => {
                    provider.showDetails = false;
                    if( provider.HealthCloudGA__Active__c == true ){
                        existingProviders.push( provider );
                    }else{
                        pastProviders.push( provider );
                    }
                });
                this.existingProviders = existingProviders;
                this.pastProviders = pastProviders;
            })
            .catch( error => {
                console.log( error );
            });
    }

    handleSetInactiveClick( evt ){
        this.showSpinner = true;
        const record = {
            fields: {
                Id: evt.target.dataset.id
            }
        };
        record.fields.HealthCloudGA__Active__c = false;
        updateRecord( record ).then(result => {
            this.showToast( SUCCESS_LABEL, RECORD_UPDATED_SUCCESSFULLY_LABEL, 'success');
            this.reteriveProviders();
            this.showSpinner = false;
        })
        .catch(error => {
            this.showToast( ERROR_LABEL, error.body.message, 'error');
            this.showSpinner = false;
        });

    }

    //Show Toast message
    showToast( title, msg, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    handleHideBackButton(event){
        this.hideBackButton = event.detail.hideBackButton;
    }
}