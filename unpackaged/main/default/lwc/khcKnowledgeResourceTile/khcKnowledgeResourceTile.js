// Salesforce
import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import isGuest from '@salesforce/user/isGuest';

// Utils
import { toggleReferralRecordFavourite } from "c/khcResourceLibraryUtils";

// Labels
import VISIT_WEBSITE_LABEL from '@salesforce/label/c.Visit_Website';
import ERROR_LABEL from "@salesforce/label/c.Error";
import FAVORITE_LABEL from "@salesforce/label/c.Favorite";
import EMAIL_LABEL from "@salesforce/label/c.Email";
import LOG_IN_OR_REGISTER_LABEL from "@salesforce/label/c.Log_In_or_Register";

export default class KhcKnowledgeResourceTile extends NavigationMixin(LightningElement) {
    // Labels
    visitWebsiteLabel = VISIT_WEBSITE_LABEL;
    favoriteLabel = FAVORITE_LABEL;
    emailLabel = EMAIL_LABEL;
    logInOrRegisterLabel = LOG_IN_OR_REGISTER_LABEL;

    // Data
    @api loggedInUser;
    @api referalRecord;
    @api knowledge;
    @api isCompact;

    compactRecord;

    // Page State Attributes
    isGuest = isGuest;
    phoneNumberMarkupString;
    emailToMarkupString;

    connectedCallback(){
        let compactRecord = {};
        if( this.isCompact && this.knowledge ){
            compactRecord.UrlName = this.knowledge.UrlName;
            compactRecord.Title = this.knowledge.Title;
            compactRecord.Street = this.knowledge.Account_Billing_Address_Street__c;
            compactRecord.City = this.knowledge.Account_Billing_Address_City__c;
            compactRecord.State = this.knowledge.Account_Billing_Address_State__c;
            compactRecord.Country = this.knowledge.Account_Billing_Address_Country__c;
            compactRecord.Zip = this.knowledge.Account_Billing_Address_Zip__c;
            compactRecord.AccountName = this.knowledge.Account_Name__c;
            compactRecord.Phone = this.knowledge.Phone__c;
        }else if( this.referalRecord ) {
            compactRecord.UrlName = this.referalRecord.Knowledge_Article_Referred__r.UrlName;
            compactRecord.Title = this.referalRecord.Knowledge_Article_Referred__r.Title;
            compactRecord.Street = this.referalRecord.Knowledge_Article_Referred__r.Account_Billing_Address_Street__c;
            compactRecord.City = this.referalRecord.Knowledge_Article_Referred__r.Account_Billing_Address_City__c;
            compactRecord.State = this.referalRecord.Knowledge_Article_Referred__r.Account_Billing_Address_State__c;
            compactRecord.Country = this.referalRecord.Knowledge_Article_Referred__r.Account_Billing_Address_Country__c;
            compactRecord.Zip = this.referalRecord.Knowledge_Article_Referred__r.Account_Billing_Address_Zip__c;
            compactRecord.AccountName = this.referalRecord.Knowledge_Article_Referred__r.Account_Name__c;
            compactRecord.Summary = this.referalRecord.Knowledge_Article_Referred__r.Summary;
        }
        this.compactRecord = compactRecord;
    }

    renderedCallback(){
        this.phoneNumberMarkupString = this.knowledge && this.knowledge.Phone__c ? 'tel:' + this.knowledge.Phone__c : null;
        this.emailToMarkupString = this.knowledge && this.knowledge.Email__c ? 'mailto:' + this.knowledge.Email__c : null;
        let favorites = this.template.querySelectorAll('[data-favorite="true"]');
        if( favorites ){
            favorites.forEach(element => {
                element.classList.add( 'khc-active' );
            });
        }
    }

    get showCompact(){
        if( this.referalRecord || this.isCompact) return true;
        return false;
    }

    get showDetailed(){
        if( this.knowledge && ( this.isCompact == undefined || this.isCompact == false ) ) return true;
        return false;
    }
    get isLocalResource(){
        if( this.referalRecord &&
            this.referalRecord.Knowledge_Article_Referred__r.Resource_Type__c == 'Local' ){
                return true;
            }
        if( this.knowledge &&
            this.knowledge.Resource_Type__c == 'Local' ){
                return true;
            }
        return false;
    }

    get isWebResource(){
        if( this.referalRecord &&
            this.referalRecord.Knowledge_Article_Referred__r.Resource_Type__c == 'Web' ){
                return true;
            }
        if( this.knowledge &&
            this.knowledge.Resource_Type__c == 'Web' ){
                return true;
            }
        return false;
    }

    get isArticleResource(){
        if( this.referalRecord &&
            this.referalRecord.Knowledge_Article_Referred__r.Resource_Type__c != 'Web' && 
            this.referalRecord.Knowledge_Article_Referred__r.Resource_Type__c != 'Local' ) {
            return true;
        }
        if( this.knowledge &&
            this.knowledge.Resource_Type__c != 'Web' && 
            this.knowledge.Resource_Type__c != 'Local' ) {
            return true;
        }
        return false;
    }

    handleNavigateToArticle(event){
        const navigateToArticle = new CustomEvent( "open", { detail : { knowledge : this.knowledge, referralRecord : this.referalRecord} } );
        this.dispatchEvent( navigateToArticle );
    }

    handleRefresh(){
        const refreshArticles = new CustomEvent( "refresh" );
        this.dispatchEvent( refreshArticles );
    }

    toggleFavourite(event){
        if ( this.isGuest ) {
            this.showGuestLoginModal();
            return;
        }

        toggleReferralRecordFavourite(this.loggedInUser.AccountId, event.target.dataset.favorite, this.knowledge.Id, this.knowledge.Featured__c)
            .then(result => {
                this.processReferralRecordUpdate(result ? true : false);
            })
            .catch(error => {
                this.showToastMessage( ERROR_LABEL, error, 'error' );
            });
    }

    processReferralRecordUpdate( isFavourite ){
        let tempKnowledge = {...this.knowledge};
        tempKnowledge.isFavorite = isFavourite;
        this.knowledge = tempKnowledge;
        if ( !isFavourite ) {
            let favorites = this.template.querySelectorAll('[data-favorite="true"]');
            if( favorites ){
                favorites.forEach(element => {
                    element.classList.remove( 'khc-active' );
                });
            }
        }
        this.sendFavourite(tempKnowledge);
    }

    sendFavourite ( tempKnowledge ) {
        this.dispatchEvent(new CustomEvent("favourite", {detail: tempKnowledge}));
    }

    showGuestLoginModal () {
        let guestLoginModal = this.template.querySelector('[data-modal-name="guest-login-modal"]');
        guestLoginModal.show();
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