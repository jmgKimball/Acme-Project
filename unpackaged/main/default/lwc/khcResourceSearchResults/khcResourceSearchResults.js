/**
 * Created by vupneja on 3/18/2021.
 */
// Salesforce
import {api, LightningElement} from 'lwc';
import isGuest from '@salesforce/user/isGuest';

// Apex
import getResources from '@salesforce/apex/KHC_ResourceSearchController.getResources';

// Labels
import BACK_TO_RESOURCE_LIBRARY_LABEL from '@salesforce/label/c.Back_to_Resource_Library';
import RESOURCES_LABEL from '@salesforce/label/c.Resources';
import RESULTS_LABEL from '@salesforce/label/c.Results';
import LIST_VIEW_LABEL from '@salesforce/label/c.List_View';
import MAP_VIEW_LABEL from '@salesforce/label/c.Map_View';
import SUBMIT_A_RESOURCE_LABEL from '@salesforce/label/c.Submit_a_Resource';
import RECOMMEND_A_RESOURCE_LABEL from '@salesforce/label/c.Recommend_a_Resource';
import NEXT_LABEL from '@salesforce/label/c.Next';
import PREVIOUS_LABEL from '@salesforce/label/c.Previous';
import RECOMMEND_A_RESOURCE_MESSAGE_LABEL from '@salesforce/label/c.Recommend_a_resource_message';
import NO_ARTICLES_FOUND_LABEL from '@salesforce/label/c.No_Knowledge_Articles_Found';
import LOG_IN_OR_REGISTER_LABEL from "@salesforce/label/c.Log_In_or_Register";
import ALPHABETICALLY_ASCENDING from "@salesforce/label/c.Alphabetically_Ascending";
import ALPHABETICALLY_DESCENDING from "@salesforce/label/c.Alphabetically_Descending";
import DATE_ADDED_ASCENDING from "@salesforce/label/c.Date_Added_Ascending";
import DATE_ADDED_DESCENDING from "@salesforce/label/c.Date_Added_Descending";

export default class KhcResourceSearchResults extends LightningElement {

    // Labels
    backToResourceLibrary = BACK_TO_RESOURCE_LIBRARY_LABEL;
    resourcesLabel = RESOURCES_LABEL;
    resultsLabel = RESULTS_LABEL;
    listViewLabel = LIST_VIEW_LABEL;
    mapViewLabel = MAP_VIEW_LABEL;
    submitAResourceLabel = SUBMIT_A_RESOURCE_LABEL;
    recommendAResourceLabel = RECOMMEND_A_RESOURCE_LABEL;
    nextLabel = NEXT_LABEL;
    previousLabel = PREVIOUS_LABEL;
    recommendAResourceMessageLabel = RECOMMEND_A_RESOURCE_MESSAGE_LABEL;
    noArticlesFoundLabel = NO_ARTICLES_FOUND_LABEL;
    logInOrRegisterLabel = LOG_IN_OR_REGISTER_LABEL;
    alphabeticallyAscending = ALPHABETICALLY_ASCENDING;
    alphabeticallyDescending = ALPHABETICALLY_DESCENDING;
    dateAddedAscending = DATE_ADDED_ASCENDING;
    dateAddedDescending = DATE_ADDED_DESCENDING;

    // Data
    @api recordId;
    @api objectApiName;
    @api topicOptions;
    @api loggedInUser;
    @api selectedTopics;
    @api defaultFilters;
    knowledgeList;
    completeKnowledgeList;

    // Page State Attributes
    @api featured;
    @api referred;
    isGuest = isGuest;
    showSpinner = true;
    mapView = false;
    page = 1;
    totalPage = 0;
    showPagination = false;
    pageSize = 5;
    totalRecountCount = 0;
    endingRecord = 0;
    startingRecord = 1;
    filters = {
        type : ([]),
        featured : false,
        location : ([]),
        topics : ([]),
        favourites : false,
        referred : false,
        sortByField : '',
        sortOrder : ''
    }

    // Getters
    @api
    get favourite() {
        return this.filters.favourites;
    }
    get hasNext(){
        if( this.page < this.totalPage ) return true;
        return false;
    }

    get hasPrevious(){
        if( this.page != 1 ) return true;
        return false;
    }

    // Setters
    set favourite(value) {
        this.filters.favourites = value;
    }

    connectedCallback() {
        if( this.defaultFilters ){
            this.filters = Object.assign({}, this.defaultFilters );
        }else{
            this.filters.topics = this.selectedTopics;
            this.filters.featured = this.featured;
            this.filters.referred = this.referred;
        }
        this.getResourceList();
    }

    toggleView () {
        this.mapView = !this.mapView;
    }

    getResourceList(){
        getResources({
            filter: this.filters
        }).then(result=>{
            if(result){
                this.completeKnowledgeList = result;
                this.knowledgeList = this.completeKnowledgeList.slice(0,this.pageSize);
                this.totalRecountCount = result.length;
                this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
                this.page = 1;
                this.startingRecord = 1;
                this.endingRecord = (result.length < this.pageSize) ? result.length : this.pageSize;
                this.showPagination = this.totalPage > 1;

                //Mark Favorite / Referred
                result.forEach( knowledge => {
                    knowledge.isFavorite = false;
                    knowledge.isReferred = false;
                    if( knowledge.hasOwnProperty( 'Referral_Records__r' ) && knowledge.Referral_Records__r.length > 0 ){
                        knowledge.Referral_Records__r.forEach(function(rr){
                           if ( rr.Favourite__c ) {
                               knowledge.isFavorite = true;
                           }
                           if ( rr.Referred__c ) {
                               knowledge.isReferred = true;
                           }
                        });
                    }
                });
                this.error = undefined;

                if ( this.mapView ) {
                    this.resetMapMarkers();
                }

            } else if (error) {
                this.error = error;
                this.data = undefined;
            }

            this.showSpinner = false;
        }).catch(error=>{
            this.error = error;
        })
    }

    resetMapMarkers() {
        const map = this.template.querySelector('c-khc-resource-map-results');
        if ( map ) {
            map.setMarkers(this.knowledgeList);
        }
    }

    handleFilter(event){
        let filter = event.detail;
        filter.sortByField = this.filters.sortByField;
        filter.sortOrder = this.filters.sortOrder;
        this.filters = filter;
        this.getResourceList();
    }

    handleBackClick( event ){
        const backEvent = new CustomEvent( 'back'  );
        this.dispatchEvent( backEvent );
    }

    handleOpenArticle( event ){
        let detail = { knowledge : event.detail.knowledge };
        detail.filters = this.filters;
        const showResourceDetail = new CustomEvent( "showresource", { detail : detail } );
        this.dispatchEvent( showResourceDetail );
    }

    handleRefresh(){
        this.getResourceList();
    }

    handleOnSortSelect(event) {
        let selectedSort = event.detail.value;
        if( selectedSort ){
            let filter = this.filters == undefined ? {} : this.filters;
            let selectedSortArr = selectedSort.split( "-" );
            filter.sortByField = selectedSortArr[0];
            filter.sortOrder = selectedSortArr[1];
            this.filters = filter;
            this.getResourceList();
        } 
    }

    openRecommendResourceModal() {
        if ( this.isGuest ) {
            this.showGuestLoginModal();
            return;
        }

        let recommendResourceModal = this.template.querySelector('[data-modal-name="recommend-resource-modal"]');
        recommendResourceModal.show();
    }

    closeRecommendationModal() {
        let recommendResourceModal = this.template.querySelector('[data-modal-name="recommend-resource-modal"]');
        recommendResourceModal.hide();
    }

    showGuestLoginModal () {
        let guestLoginModal = this.template.querySelector('[data-modal-name="guest-login-modal"]');
        guestLoginModal.show();
    }

    //clicking on previous button this method will be called
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    //clicking on next button this method will be called
    nextHandler() {
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    //this method displays records page by page
    displayRecordPerPage(page){
        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);
        this.endingRecord = (this.endingRecord > this.totalRecountCount) ? this.totalRecountCount : this.endingRecord;
        this.knowledgeList = this.completeKnowledgeList.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;

        if ( this.mapView ) {
            this.resetMapMarkers();
        } else {
            this.scrollToTop();
        }

    }

    updateFavourite (event) {
        let updatedArticle = event.detail;
        this.completeKnowledgeList.forEach(function(k, idx){
           if ( updatedArticle.Id == k.Id )  {
               this.completeKnowledgeList[idx] = updatedArticle;
           }
        }.bind(this));
    }

    scrollToTop() {
        const scrollOptions = {
            left: 0,
            top: 0,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
    }
}