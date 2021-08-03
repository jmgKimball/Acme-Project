// Salesforce
import {LightningElement, api, wire, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import isGuest from '@salesforce/user/isGuest';

// Apex
import getMyReferrals from '@salesforce/apex/KHC_ResourceLibraryCtrl.getMyReferrals';
import getMyFavorites from '@salesforce/apex/KHC_ResourceLibraryCtrl.getMyFavorites';
import getOtherResources from '@salesforce/apex/KHC_ResourceLibraryCtrl.getOtherResources';
import getResources from '@salesforce/apex/KHC_ResourceSearchController.getResources';

// Labels
import RESOURCE_LIBRARY_LABEL from '@salesforce/label/c.Resource_Library';
import FIND_RESOURCE_LABEL from '@salesforce/label/c.FIND_RESOURCES';
import RECOMMENDED_BUISNESS_SUPPORT_LABEL from '@salesforce/label/c.Komen_recommended_business_support_message';
import RESOURCE_TOPIC_LABEL from '@salesforce/label/c.Resource_Topic';
import SELECT_TOPICS_LABEL from '@salesforce/label/c.Select_Topics';
import SEARCH_RESOURCE_LABEL from '@salesforce/label/c.Search_resource';
import MY_REFFERALS_LABEL from '@salesforce/label/c.MY_REFFERALS';
import MY_FAVORITES_LABEL from '@salesforce/label/c.MY_FAVORITES';
import RECOMMENDED_RESOURCE_LABEL from '@salesforce/label/c.Recommended_Resource_Message';
import VIEW_ALL_REFERRALS_LABEL from '@salesforce/label/c.View_All_Referrals';
import VIEW_ALL_FAVORITES_LABEL from '@salesforce/label/c.View_All_Favorites';
import RESOURCE_FAVORITED_BY_YOU_LABEL from '@salesforce/label/c.Resources_favorited_by_you';
import OTHER_RECOMMENDATIONS_LABEL from '@salesforce/label/c.OTHER_RECOMMENDATIONS';
import RECOMMENDATIONS_BASED_ON_LABEL from '@salesforce/label/c.Recommendations_based_on_your';
import PROFILE_LABEL from '@salesforce/label/c.profile';
import VIEW_ALL_ITEMS_LABEL from '@salesforce/label/c.View_All_Items';
import ERROR_LABEL from "@salesforce/label/c.Error";
import NO_OTHER_RECOMMENDATIONS_LABEL from '@salesforce/label/c.No_Other_Recommendations';
import NO_FAVORITE_ARTICLES_LABEL from '@salesforce/label/c.No_Favorite_Articles';
import NO_REFERRED_LABEL from "@salesforce/label/c.No_Referred_Articles";
import DISMISS_RESOURCE_RECOMMENDATION_LABEL from '@salesforce/label/c.Dismiss_Resource_Recommendation'

export default class KhcResourceSearch extends NavigationMixin(LightningElement) {
    // Labels
    headerText = RESOURCE_LIBRARY_LABEL;
    findResourceLabel = FIND_RESOURCE_LABEL;
    recommendedBusinsessSupportLabel = RECOMMENDED_BUISNESS_SUPPORT_LABEL;
    resourceTopicLabel = RESOURCE_TOPIC_LABEL;
    selectTopicsLabel = SELECT_TOPICS_LABEL;
    searchResourceLabel = SEARCH_RESOURCE_LABEL;
    myRefferalsLabel = MY_REFFERALS_LABEL;
    myFavoritesLabel = MY_FAVORITES_LABEL;
    recommendedResourceLabel = RECOMMENDED_RESOURCE_LABEL;
    viewAllReferralsLabel = VIEW_ALL_REFERRALS_LABEL;
    viewAllFavoritesLabel = VIEW_ALL_FAVORITES_LABEL;
    resourceFavoritedByYouLabel = RESOURCE_FAVORITED_BY_YOU_LABEL;
    otherRecommendationLabel = OTHER_RECOMMENDATIONS_LABEL;
    recommendationBasedOnLabel = RECOMMENDATIONS_BASED_ON_LABEL;
    profileLabel = PROFILE_LABEL;
    viewAllItemsLabel = VIEW_ALL_ITEMS_LABEL;
    noOtherRecommendationsLabel = NO_OTHER_RECOMMENDATIONS_LABEL;
    noFavoriteArticlesLabel = NO_FAVORITE_ARTICLES_LABEL;
    noReferredArticlesLabel = NO_REFERRED_LABEL;
    dismissResourceRecommendationLabel = DISMISS_RESOURCE_RECOMMENDATION_LABEL;

    // Data
    @api
    topicOptions;
    selectedTopics;
    referredArticles;
    hasReferredArticles;
    favoriteArticles;
    otherArticles;
    isReferred;

    @track
    knowledgeArticleIdToDismiss;

    // Page State Attributes
    isGuest = isGuest;

    connectedCallback(){
        if ( !isGuest ) {
            this.getMyReferrals();
            this.getMyFavorites();
            this.getOtherResources();
        }
    }

    handleTopicChange( event ){
        let selectedTopics = '';
        if( event.detail.hasOwnProperty( "selectedOptions" ) ){
            selectedTopics = event.detail.selectedOptions;
            this.selectedTopics = selectedTopics;
        }
    }

    handleSearchByTopic(){
        let filters = {};
        filters.topics = this.selectedTopics;
        this.dispatchEvent( new CustomEvent('search', {detail: filters} ));
    }

    handleViewAllReferralClick(){
        let filters = {};
        filters.referred = true;
        this.dispatchEvent( new CustomEvent('search', {detail: filters} ));
    }

    handleViewAllFavClick(){
        let filters = {};
        filters.favourites = true;
        this.dispatchEvent( new CustomEvent('search', {detail: filters} ));
    }

    handleViewAll(){
        this.dispatchEvent( new CustomEvent( 'search' ) );
    }

    handleProfileClick(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: Id,
                actionName: 'view'
            }
        });
    }

    handleOpenArticle( event ){
        let refRecord = event.detail.referralRecord;
        if( refRecord ){
            let filters = {};
            filters.articleId = event.detail.referralRecord.Knowledge_Article_Referred__c;
            
            getResources({
                filter: filters
            }).then( result =>{
                if( result && result.length > 0 ){
                    result[0].isFavorite = refRecord.Favourite__c;
                    result[0].referralRecordId = refRecord.Id;
                    const showResourceDetail = new CustomEvent( "showresource", { detail : result[0] } );
                    this.dispatchEvent( showResourceDetail );
                }
            }).catch( error =>{
                this.showToastMessage( ERROR_LABEL, error, 'error' );
            });
        }else {
            const showResourceDetail = new CustomEvent( "showresource", { detail : event.detail.knowledge } );
            this.dispatchEvent( showResourceDetail );
        }
        
    }

    getMyReferrals(){
        getMyReferrals()
            .then( result =>{
                if( result){
                    this.referredArticles = result;
                    this.hasReferredArticles = result.length > 0;
                }
            }).catch( error =>{
                this.showToastMessage( ERROR_LABEL, error, 'error' );
            });
    }

    getMyFavorites(){
        getMyFavorites()
            .then( result =>{
                if( result && result.length ){
                    this.favoriteArticles = result;
                }
            }).catch( error =>{
                this.showToastMessage( ERROR_LABEL, error, 'error' );
         });
    }

    getOtherResources(){
        getOtherResources()
            .then( result =>{
                if( result && result.length ){
                    this.otherArticles = result;
                }
            }).catch( error =>{
                this.showToastMessage( ERROR_LABEL, error, 'error' );
        });
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

    openReferralDismissalModal(event) {
        this.knowledgeArticleIdToDismiss = event.target.dataset.knowledgeArticleReferredId;
        const modal = this.template.querySelector("c-mk-modal");
        modal.show();
    }

    handleReferralDismissed (event) {
        const modal = this.template.querySelector("c-mk-modal");
        modal.hide();
        this.getMyReferrals();
    }
}