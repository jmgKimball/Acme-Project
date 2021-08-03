import { LightningElement, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import {updateRecord} from 'lightning/uiRecordApi';
import createProviderAndConConRel from '@salesforce/apex/KHC_SearchProviderController.createProviderAndConConRel';
import searchProvider from '@salesforce/apex/KHC_SearchProviderController.searchProvider';
import { formatString } from "c/khcLwcUtils";

import NAME_LABEL from '@salesforce/label/c.Name';
import ADDRESS_LINE_1_LABEL from '@salesforce/label/c.Address_line_1';
import CITY_LABEL from '@salesforce/label/c.City';
import STATE_LABEL from '@salesforce/label/c.State';
import STATUS_LABEL from '@salesforce/label/c.Status';
import TAXONOMIES_LABEL from '@salesforce/label/c.Taxonomies';
import SELECT_LABEL from '@salesforce/label/c.Select';
import SUCCESS_LABEL from '@salesforce/label/c.Success';
import ERROR_LABEL from '@salesforce/label/c.Error';
import ADD_NEW_PROVIDER_LABEL from '@salesforce/label/c.Add_new_provider';
import RECORD_UPDATED_SUCCESSFULLY_LABEL from '@salesforce/label/c.Record_updated_successfully';
import SEARCH_FOR_YOUR_PROVIDER_LABEL from '@salesforce/label/c.Search_for_your_provider';
import FIRST_NAME_LABEL from '@salesforce/label/c.First_Name';
import LAST_NAME_LABEL from '@salesforce/label/c.Last_Name';
import SEARCH_LABEL from '@salesforce/label/c.Search';
import PROVIDER_PAGINATION_RESULT_LABEL from '@salesforce/label/c.Provider_Pagination_Result';
import EDIT_SEARCH_LABEL from '@salesforce/label/c.Edit_Search';
import PREVIOUS_PAGE_LABEL from '@salesforce/label/c.Previous_Page';
import NEXT_PAGE_LABEL from '@salesforce/label/c.Next_Page';
import BACK_TO_RESULT_LABEL from '@salesforce/label/c.Back_to_results';
import IS_PAST_RPOVIDER_LABEL from '@salesforce/label/c.Is_Past_Provider';
import PROVIDER_RESULT_LABEL from '@salesforce/label/c.Provider_Result';
import ADD_A_NEW_PROVIDER_LABEL from '@salesforce/label/c.Add_a_new_provider';
import PROVIDER_SEARCH_VALIDATION_MSG_LABEL from '@salesforce/label/c.Provider_Search_Validation_Message';

const columns = [
    { label: NAME_LABEL, fieldName: 'name', cellAttributes: { class: 'dt-col-name'} },
    { label: ADDRESS_LINE_1_LABEL, fieldName: 'address_1', cellAttributes: { class: 'dt-col-name'} },
    { label: CITY_LABEL, fieldName: 'city', cellAttributes: { class: 'dt-col-city'} },
    { label: STATE_LABEL, fieldName: 'state', cellAttributes: { class: 'dt-col-state'} },
    { label: STATUS_LABEL, fieldName: 'status', cellAttributes: { class: 'dt-col-status'} },
    { label: TAXONOMIES_LABEL, fieldName: 'taxonomies', cellAttributes: { class: 'dt-col-taxonomies'} },
    {
        type: 'button',
        action : 'handleSelectProvider',
        typeAttributes: { label: SELECT_LABEL, name: 'selectProvider', variant : 'brand' }  
    }
];

export default class SearchProvider extends NavigationMixin(LightningElement) {
    showSpinner = false;
    foundNoProvider = false;
    hasANewProvider = false;
    filterValue = {
        "city" : "",
        "state" : "",
        "zipCode" : "",
        "providerLastName" : "",
        "providerFirstName" : ""
    };
    columns = columns;
    data = [];
    providerMap = [];
    skip = 0;	
    currentPage = 1;
    selectedRow;
    existingProviderMap = [];

    searchForYourProviderLabel = SEARCH_FOR_YOUR_PROVIDER_LABEL;
    firstNameLabel = FIRST_NAME_LABEL;
    lastNameLabel = LAST_NAME_LABEL;
    cityLabel = CITY_LABEL;
    stateLabel = STATE_LABEL;
    searchLabel = SEARCH_LABEL;
    editSearchLabel = EDIT_SEARCH_LABEL;
    selectLabel = SELECT_LABEL;
    previousPageLabel = PREVIOUS_PAGE_LABEL;
    nextPageLabel = NEXT_PAGE_LABEL;
    backToResultLabel = BACK_TO_RESULT_LABEL;
    isPastProviderLabel = IS_PAST_RPOVIDER_LABEL;
    addNewProviderLabel = ADD_NEW_PROVIDER_LABEL;
    providerResultLabel = PROVIDER_RESULT_LABEL;
    addANewProviderLabel = ADD_A_NEW_PROVIDER_LABEL;


    @api
    get existingProviders(){
    }
    set existingProviders( value){
        if( value != undefined ){
            let existingProviderMap = this.existingProviderMap;
            value.forEach( provider => {
                existingProviderMap[provider.Provider__r.NPI_ID__c] = { Id: provider.Id, Active: provider.HealthCloudGA__Active__c};
            });
            this.existingProviderMap = existingProviderMap;
        }
    }
    @api
    get pastProviders(){} 
    set pastProviders( value ){
        if( value != undefined ){
            let existingProviderMap = this.existingProviderMap;
            value.forEach( provider => {
                existingProviderMap[provider.Provider__r.NPI_ID__c] = { Id: provider.Id, Active: provider.HealthCloudGA__Active__c};
            });
            this.existingProviderMap = existingProviderMap;
        }
    }

    get showSearchProvider(){
        if( this.data.length > 0 ){
            return true;
        }
        return false;
    }
    get showProviderList(){
        if( this.data.length > 0 && this. selectedRow == undefined){
            return true;
        }
        return false;
    }
    get showDisabledNext(){
        if( this.data.length > 0 && this.data.length < 20){
            return true;
        }
        return false;
    }
    get showDisabledPrevious(){
        if( this.currentPage == 1 ){
            return true;
        }
        return false;
    }

    get showPaginationDetails(){
        if( this.currentPage == 1 && this.data.length > 0 && this.data.length < 20 ){
            return false;
        }
        return true;
    }

    get providerPaginationResultLabel(){
        /*return String.format( PROVIDER_PAGINATION_RESULT_LABEL, this.data.length, 
                                this.filterValue.providerFirstName, this.filterValue.providerLastName, 
                                this.filterValue.city, this. filterValue.state );*/
        let args = new Array();
        args.push( this.data.length );
        args.push( this.filterValue.providerFirstName );
        args.push( this.filterValue.providerLastName );
        args.push( this.filterValue.city );
        args.push( this. filterValue.state );
        return formatString( PROVIDER_PAGINATION_RESULT_LABEL, args);
    }

    backToResults(){
        this.selectedRow = undefined;
    }

    handleSearchClicked(){
        this.showSpinner = true;
        var inp = this.template.querySelectorAll("lightning-input");
        inp.forEach(function(element){
            if(element.name == "City"){
                this.filterValue.city = element.value;
            } else if( element.name == "State" ){
                this.filterValue.state = element.value;
            } else if( element.name == "ZipCode" ){
                this.filterValue.zipCode = element.value;
            } else if( element.name == "ProviderLastName" ){
                this.filterValue.providerLastName = element.value;
            } else if( element.name == "ProviderFirstName" ){
                this.filterValue.providerFirstName = element.value;
            }
        },this);	

        if( this.validateFilterInput() ) this.searchProviders();

    }

    handleNext( evt ){	
        this.showSpinner = true;	
        this.skip += 20;	
        this.currentPage ++;
        this.filterValue.skip = this.skip;	
        this.searchProviders();	
    }	
    handlePrevious( evt ){	
        if( this.skip > 0 ){	
            this.showSpinner = true;	
            this.skip -= 20;	
            this.currentPage --;
            this.filterValue.skip = this.skip;	
            this.searchProviders();	
        }	
    }	

    validateFilterInput(){
        if( this.filterValue.state != "" && this.filterValue.city == "" && 
            this.filterValue.providerFirstName == "" && this.filterValue.providerLastName =="" ){
                this.showToast( ERROR_LABEL, PROVIDER_SEARCH_VALIDATION_MSG_LABEL, 'error' );
                this.showSpinner = false;
                return false;
            }
        return true;
    }

    //Method to search Provider	
    searchProviders(){
        let currentContext = this;
        searchProvider({ filterValueStr: JSON.stringify(this.filterValue) })	
            .then( (result) => {	
                let resp = JSON.parse(result);

                if( resp.result_count > 0 ){	
                    let filteredResult = [];	
                    let filteredResultMap = [];	
                    resp.results.forEach( function( provider ){
                        let providerRow = {};	
                        currentContext.populateBasicInfo( provider, providerRow, currentContext);
                        currentContext.populateAddress( provider, providerRow);
                        currentContext.populateTaxonomies( provider, providerRow);
						//NPI Id	
                        providerRow.npi_id = provider.number;
                        filteredResult.push( providerRow );	
                        filteredResultMap[providerRow.npi_id] = providerRow;
                    } );	
                    this.data = filteredResult;	
                    this.providerMap = filteredResultMap;
                } else{
                    this.foundNoProvider = true;
                    const evt= new CustomEvent('backbuttonevent', {detail:{hideBackButton:true}});
                    this.dispatchEvent(evt);
                }
                this.showSpinner = false;	
            })	
            .catch(error => {	
                this.showSpinner = false;
            });	
    }

    //Handle Select click
    handleSelect( evt ){
        let selectedRow = this.providerMap[evt.target.dataset.id];
        let isActive;
        if( this.existingProviderMap.hasOwnProperty(evt.target.dataset.id) ){
            isActive = this.existingProviderMap[evt.target.dataset.id].Active;
            selectedRow.existing_record_id = this.existingProviderMap[evt.target.dataset.id].Id;
        }
        selectedRow.is_past = ( isActive == false ? true : false );
        this.selectedRow = selectedRow;
        const event= new CustomEvent('backbuttonevent', {detail:{hideBackButton:true}});
        this.dispatchEvent(event);
        this.hasANewProvider = true;

    }
    renderedCallback(){
        if( this.selectedRow != undefined ){
            this.template.querySelectorAll('.isPast').forEach( elm =>{
                elm.checked = this.selectedRow.is_past;
            });
        }
    }
    
    //Save conatct and Case Team Members
    saveContactAndTeamMember(){
        if( this.selectedRow != undefined ){
            if( this.selectedRow.hasOwnProperty( 'existing_record_id' ) ){
                this.updateConConRel( this.selectedRow );
            }else{
                this.createProviderAndContactToContactRel( this.selectedRow );
            }
        }
    }

    createProviderAndContactToContactRel( row ){
        let cont = { 'sobjectType': 'Contact' };
        cont.FirstName = row.first_name;
        cont.LastName = row.last_name;
        cont.NPI_ID__c = row.npi_id + '';
        cont.HealthCloudGA_Gender_c = row.gender != undefined ? row.gender : null;
        cont.MailingStreet = row.address_1 + ' ' + row.address_2;
        cont.MailingCity = row.city;
        cont.MailingStateCode = row.state;
        cont.MailingPostalCode = row.postal_code;
        cont.MailingCountry = row.country_name;
        let isActive = true;
        this.template.querySelectorAll('.isPast').forEach( elm =>{
            isActive = !elm.checked;
        });
        createProviderAndConConRel({ provider: cont, isActive : isActive })	
            .then(result => {	
                this.showSpinner = false;	
                if( result == "Success"){
                    this.showToast( SUCCESS_LABEL, RECORD_UPDATED_SUCCESSFULLY_LABEL, 'success' );
                    this.navigateToWebPage();
                }else{
                    this.showToast( ERROR_LABEL, result, 'error' );
                }
            })	
            .catch(error => {
                this.showSpinner = false;
                this.showToast( ERROR_LABEL, error, 'error' );	
            });	
    }

    updateConConRel( row ){
        this.showSpinner = true;
        const record = {
            fields: {
                Id: row.existing_record_id
            }
        };
        let isActive = true;
        this.template.querySelectorAll('.isPast').forEach( elm =>{
            isActive = !elm.checked;
        });
        record.fields.HealthCloudGA__Active__c = isActive;
        updateRecord( record ).then(result => {
            this.showToast( SUCCESS_LABEL, RECORD_UPDATED_SUCCESSFULLY_LABEL, 'success');
            this.navigateToWebPage();
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
    //Basic info
    populateBasicInfo( provider, providerRow, currentContext ){
        if( provider.hasOwnProperty('basic') ){	
            if( provider.basic.hasOwnProperty('first_name') && provider.basic.hasOwnProperty('last_name') ){	
                providerRow.first_name = currentContext.titleCase( provider.basic.first_name );
                providerRow.last_name = currentContext.titleCase( provider.basic.last_name );
                providerRow.name =  providerRow.first_name + ' ' + providerRow.last_name;
                
            }else{	
                providerRow.name = currentContext.titleCase( provider.basic.name );	
                providerRow.last_name = providerRow.name;
            }	
            if( provider.basic.hasOwnProperty('gender')){
                providerRow.gender = provider.basic.gender;	
            }

            providerRow.status = ( provider.basic.status == 'A' ? 'Active' : 'Inactive' );	
            providerRow.last_updated = provider.basic.last_updated;	
        }
    }
    //Address	
    populateAddress( provider, providerRow){
        if( provider.hasOwnProperty('addresses') ){	
            provider.addresses.forEach(address => {	
                if( address.address_purpose == 'LOCATION' ){	
                    providerRow.address_1 = address.address_1;	
                    providerRow.address_2 = address.address_2;	
                    providerRow.city = address.city;	
                    providerRow.state = address.state;	
                    providerRow.postal_code = address.postal_code;
                    providerRow.country_name = address.country_name;
                }	
            });	
        }	
    }
    //Taxonomies
    populateTaxonomies( provider, providerRow){
        if( provider.hasOwnProperty('taxonomies') ){	
            let taxonomyDesc = '';	
            provider.taxonomies.forEach(taxonomy => {	
                taxonomyDesc += taxonomy.desc + ', ';	
            });	
            if( taxonomyDesc.endsWith(', ') ){	
                taxonomyDesc = taxonomyDesc.substr( 0, taxonomyDesc.length-2 );	
            }  	
            providerRow.taxonomies = taxonomyDesc;	
        }	
    }

    findRowIndexById(id) {
        let ret = -1;
        this.data.some((row, index) => {
            if (row.id === id) {
                ret = index;
                return true;
            }
            return false;
        });
        return ret;
    }

    titleCase( str ) {
        str = str.toLowerCase().split(' ');
        for (var i = 0; i < str.length; i++) {
          str[i] = str[i].charAt(0).toUpperCase() + str[i].slice(1); 
        }
        return str.join(' ');
    }

    editSearch(){
        this.data = [];
        const evt= new CustomEvent('backbuttonevent', {detail:{hideBackButton:false}});
        this.dispatchEvent(evt);
    }

    //TODO: Navigate to community, make it dynamic
    navigateToWebPage() {
        // Navigate to a URL
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/s/my-providers'
            }
        },
        true // Replaces the current page in your browser history with the URL
      );
    }

    backToSearchScreen(){
        const evt= new CustomEvent('backbuttonevent', {detail:{hideBackButton:false}});
        this.dispatchEvent(evt);
        this.foundNoProvider = false;
    }

}