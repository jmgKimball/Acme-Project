/**
 * Created by mlandels on 2021-03-18.
 */
// Salesforce
import {LightningElement, api, track} from 'lwc';

// Labels
import NO_ARTICLES_HAVE_LOCATIONS from '@salesforce/label/c.No_Articles_Have_Locations';

export default class KhcResourceMapResults extends LightningElement {
    LABELS = {
        noArticlesHaveLocations : NO_ARTICLES_HAVE_LOCATIONS
    }

    // Data
    @api
    knowledgeList;
    localResourceKnowledgeList = [];
    mapMarkers = [];
    hasMarkers = false;
    center;

    connectedCallback(){
        this.setMarkers(this.knowledgeList);
    }

    get mapOptions() {
        return {
            disableDefaultUI: true,
            zoomControl : true
        };
    }

    @api
    setMarkers(articles){
        let localResourceList = [];
        let markerData = [];
        let accountIds = [];

        this.mapMarkers = [];

        articles.forEach(function(k){
            if ( !accountIds.includes(k.Account__c) ) {
                accountIds.push(k.Account__c);
                if (k.Account_Billing_Address_Street__c &&
                    k.Account_Billing_Address_City__c &&
                    k.Account_Billing_Address_Country__c){
                    localResourceList.push(k);
                    markerData.push(
                        {
                            location : {
                                Street : k.Account_Billing_Address_Street__c,
                                City : k.Account_Billing_Address_City__c,
                                Country :k.Account_Billing_Address_Country__c
                            },
                            title : k.Account_Name__c,
                            description :  k.Account_Billing_Address_Street__c + ', ' +
                                            k.Account_Billing_Address_City__c + ', ' +
                                            k.Account_Billing_Address_Country__c
                        }
                    );
                }
            }
        });

        this.localResourceKnowledgeList = localResourceList;
        this.mapMarkers = markerData;
        this.hasMarkers = markerData.length;

        if ( markerData ) {
            this.center = markerData[0];
        }
    }
}