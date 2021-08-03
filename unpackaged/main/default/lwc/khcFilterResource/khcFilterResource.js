// Salesforce
import { LightningElement, api } from 'lwc';
import isGuest from '@salesforce/user/isGuest';
// Apex
import getTypes from '@salesforce/apex/KHC_ResourceLibraryCtrl.getTypes';
import getLocations from '@salesforce/apex/KHC_ResourceLibraryCtrl.getLocations';
// Labels
import FILTERS_LABEL from '@salesforce/label/c.FILTERS';
import TYPE_LABEL from '@salesforce/label/c.Type';
import FEATURED_LABEL from '@salesforce/label/c.Featured';
import LOCATION_LABEL from '@salesforce/label/c.Location';
import FAVORITE_LABEL from '@salesforce/label/c.Favorites';
import TOPIC_LABEL from '@salesforce/label/c.Topic';
import REFERRED_LABEL from '@salesforce/label/c.Referred';

export default class KhcFilterResource extends LightningElement {
    // Labels
    filtersLabel = FILTERS_LABEL;
    typeLabel = TYPE_LABEL;
    featuredLabel = FEATURED_LABEL;
    locationLabel = LOCATION_LABEL;
    favoriteLabel = FAVORITE_LABEL;
    topicLabel = TOPIC_LABEL;
    referredLabel = REFERRED_LABEL;

    // Data Attributes
    @api topics;
    @api filters;
    selectedFilters;
    typeOptions;
    locationOptions;

    // Page State Attributes
    isGuest = isGuest;
    numTopicsSelected = 0;
    numLocationsSelected = 0;
    numTypesSelected = 0;
    isFilterDropdownOpen = false;

    connectedCallback(){
        this.selectedFilters = Object.assign({}, this.filters);
        if ( this.selectedFilters.topics ) {
            this.numTopicsSelected = this.selectedFilters.topics.length;
        }

        this.getTypes(); 
        this.getLocations();
    }

    renderedCallback(){
        let elem;
        if( this.filters.favourites ){
            elem = this.template.querySelector('[data-filter-type="favourites"]');
        }
        if( this.filters.featured ){
            elem = this.template.querySelector('[data-filter-type="featured"]');
        }
        if( this.filters.referred ){
            elem = this.template.querySelector('[data-filter-type="referred"]');
        }
        
        if( elem ) elem.classList.add('slds-pill-active');
    }

    getTypes(){
        getTypes()
            .then( result => {
                let typeOptions = [];
                this.typeOptions = result;
                result.forEach( type =>{
                    typeOptions.push( { label: type, value: type } );
                });
                this.typeOptions = typeOptions;
            }).
        catch( error => {
            console.log( error );
        });
    }

    getLocations(){
        getLocations()
            .then( result => {
                let locationOptions = [];
                this.locationOptions = result;
                result.forEach( location =>{
                    locationOptions.push( { label: location, value: location } );
                });
                this.locationOptions = locationOptions;
            }).
        catch( error => {
            console.log( error );
        });
    }

    handleFilterResults (event) {
        let target = event.currentTarget;
        let selectedFilter = target.dataset.filterType;
        target.classList.toggle('slds-pill-active');

        if ( isGuest &&
            (selectedFilter == 'featured' ||
            selectedFilter == 'favourites' ||
            selectedFilter == 'referred')) {
            this.handleIsGuest();
            target.classList.toggle('slds-pill-active');
            return;
        }

        switch(selectedFilter) {
            case 'featured':
                this.selectedFilters.featured = !this.filters.featured;
                break;
            case 'location':
                let locationFilterDropdown = this.template.querySelector('[data-id="khc-location-filter"]');
                locationFilterDropdown.classList.toggle('khc-filter-hidden');
                break;
            case 'favourites':
                this.selectedFilters.favourites = !this.filters.favourites;
                break;
            case 'referred':
                this.selectedFilters.referred = !this.filters.referred;
                break;
            default:
            // code block
        }
        this.applyFilters();
    }

    handleTypeChange( event ){
        if( event.detail.hasOwnProperty( "selectedOptions" ) ){
            this.selectedFilters.type = event.detail.selectedOptions;
        }
        this.numTypesSelected = this.selectedFilters.type.length;
        this.applyFilters();
    }

    handleTopicChange( event ){
        if( event.detail.hasOwnProperty( "selectedOptions" ) ){
            this.selectedFilters.topics = event.detail.selectedOptions;
        }
        this.numTopicsSelected = this.selectedFilters.topics.length;
        this.applyFilters();
    }

    handleLocationChange( event ){
        if( event.detail.hasOwnProperty( "selectedOptions" ) ){
            this.selectedFilters.location = event.detail.selectedOptions;
        }
        this.numLocationsSelected = this.selectedFilters.location.length;
        this.applyFilters();
    }

    applyFilters( ) {
        const selectedEvent = new CustomEvent("filtervaluechange", {
            detail: this.selectedFilters
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    handleFilterDropdownChange ( event ) {
        this.isFilterDropdownOpen = event.detail;
    }

    handleCloseFilterDropdown () {
        this.isFilterDropdownOpen = false;
        let childMultiselects = this.template.querySelectorAll('c-khc-multiselect-checkbox');
        if ( childMultiselects ) {
            childMultiselects.forEach(function(c){
                c.closeDropdown();
            });
        }
    }
    handleIsGuest () {
        const isGuestEvent = new CustomEvent("isguest", {detail: true});
        this.dispatchEvent(isGuestEvent);
    }
}