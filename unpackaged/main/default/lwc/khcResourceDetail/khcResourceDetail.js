// Salesforce
import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import isGuest from '@salesforce/user/isGuest';

// Labels
import VISIT_WEBSITE_LABEL from '@salesforce/label/c.Visit_Website';
import REPORT_AN_ISSUE_LABEL from "@salesforce/label/c.Report_an_Issue";
import BACK_TO_RESOURCE_LIBRARY_LABEL from '@salesforce/label/c.Back_to_Resource_Library';
import FAVORITE_LABEL from "@salesforce/label/c.Favorite";
import EMAIL_LABEL from "@salesforce/label/c.Email";
import LOG_IN_OR_REGISTER_LABEL from "@salesforce/label/c.Log_In_or_Register";

// Utils
import { toggleReferralRecordFavourite } from "c/khcResourceLibraryUtils";

export default class KhcResourceDetail extends LightningElement {
    // Labels
    visitWebsiteLabel = VISIT_WEBSITE_LABEL;
    reportAnIssueLabel = REPORT_AN_ISSUE_LABEL;
    backToResourceLibrary = BACK_TO_RESOURCE_LIBRARY_LABEL;
    favoriteLabel = FAVORITE_LABEL;
    logInOrRegisterLabel = LOG_IN_OR_REGISTER_LABEL;

    // Data
    @api knowledge;
    @api filters;
    @api loggedInUser;

    // Page State Attributes
    isGuest = isGuest;
    phoneNumberMarkupString;
    emailToMarkupString;
    emailLabel = EMAIL_LABEL;

    connectedCallback() {
        if( this.knowledge ){
            if( this.knowledge.referralRecord ){
                this.phoneNumberMarkupString = this.knowledge.referralRecord.Knowledge_Article_Referred__r.Phone__c ? 'tel:' + this.knowledge.referralRecord.Knowledge_Article_Referred__r.Phone__c : null;
                this.emailToMarkupString = this.knowledge.referralRecord.Knowledge_Article_Referred__r.Email__c ? 'mailto:' + this.knowledge.referralRecord.Knowledge_Article_Referred__r.Email__c : null;
            }else{
                this.phoneNumberMarkupString = this.knowledge.Phone__c ? 'tel:' + this.knowledge.Phone__c : null;
                this.emailToMarkupString = this.knowledge.Email__c ? 'mailto:' + this.knowledge.Email__c : null;
            }
        }
        
    }

    renderedCallback(){
        let favorites = this.template.querySelectorAll('[data-favorite="true"]');
        if( favorites ){
            favorites.forEach(element => {
                element.classList.add( 'khc-active' );
            });
        }
    }

    get isLocalResource(){
        if( this.knowledge &&
            this.knowledge.Resource_Type__c == 'Local' ){
                return true;
            }
        return false;
    }

    get isWebResource(){
        if( this.knowledge &&
            this.knowledge.Resource_Type__c == 'Web' ){
                return true;
            }
        return false;
    }

    get isArticleResource(){
        if( this.knowledge &&
            this.knowledge.Resource_Type__c != 'Web' && 
            this.knowledge.Resource_Type__c != 'Local' ) {
            return true;
        }
        return false;
    }

    handleBackClick(){
        this.dispatchEvent( new CustomEvent( "back", { detail : this.filters } ) );
    }

    openReportResourceModal() {
        let reportResourceModal = this.template.querySelector('[data-modal-name="report-resource-modal"]');
        reportResourceModal.show();
    }

    handleReportIssueSuccess () {
        let reportResourceModal = this.template.querySelector('[data-modal-name="report-resource-modal"]');
        reportResourceModal.hide();
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