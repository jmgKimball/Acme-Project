/**
 * Created by vupneja on 3/16/2021.
 */

public with sharing class KHC_ResourceSearchController {

    private static Id knowledgeRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('Knowledge').getRecordTypeId();

    //Nchandwani, 19 March 2021: Filter Knowledge records
    @AuraEnabled
    public static List<Knowledge__kav> getResources( ResourceFilterWrapper filter ){

        User currUser;
        Id currentLoggedAccount;
        Boolean isGuestUser = MyKomenHealthUtility.isGuestUser();

        if ( !isGuestUser ) {
            currUser = MyKomenHealthUtility.getLoggedInUserDetails();
            currentLoggedAccount = currUser.AccountId;
        }

        Set<String> topics = new Set<String>();
        Set<String> types = new Set<String>();
        Set<String> locations = new Set<String>();
        Set<Id> knowledgeIds = new Set<Id>();
        Set<Id> favKnowledgeIds = new Set<Id>();
        Set<Id> referredKnowledgeIds = new Set<Id>();

        String query = 'SELECT Id, Title, Summary, Resource_Type__c, Community_Topics__c, Phone__c, Email__c, Featured__c';
        query += ', Account__c';
        query += ', Account_Name__c';
        query += ', Account_Billing_Address_Street__c';
        query += ', Account_Billing_Address_City__c';
        query += ', Account_Billing_Address_State__c';
        query += ', Account_Billing_Address_Country__c';
        query += ', Account_Billing_Address_Zip__c';
        query += ', Komen_Site_URL__c';
        query += ', Body__c';
        if ( !isGuestUser ) {
            // Query favorites
            query += ', (SELECT Id, Favourite__c, Referred__c FROM ' +
                        'Referral_Records__r WHERE ' +
                        'Patient__c = :currentLoggedAccount AND ' +
                        '(Favourite__c = TRUE OR ' +
                        'Referred__c = TRUE)) ';
        }
        query += ' FROM Knowledge__kav ';

        String filterClause = '';
        //Create Filter String
        if( filter != null ){
            //Filter by resource Type
            if( filter.type != null && !filter.type.isEmpty() ){
                types = new Set<String>( filter.type );
                filterClause += 'Resource_Type__c IN: types ';
            }

            if(filter.featured == true) {
                filterClause += String.isNotBlank( filterClause ) ? 'AND ' : '';
                filterClause += 'Featured__c = TRUE ';
            }

            //Check if favorite/referred is selected
            if(filter.favourites == true || filter.referred == true ){

                //Query Referral_Record__c and create a set of knowledge which matches the criterias
                for( Referral_Record__c referralRecord : getReferralRecords( currentLoggedAccount ) ){
                    if( filter.favourites == true && referralRecord.Favourite__c ){
                        favKnowledgeIds.add( referralRecord.Knowledge_Article_Referred__c );
                    }

                    if( filter.referred == true && referralRecord.Referred__c ){
                        referredKnowledgeIds.add( referralRecord.Knowledge_Article_Referred__c );
                    }
                }
                //Add and criteria for featured, favorite, referred
                if( filter.favourites == true ){
                    filterClause += String.isNotBlank( filterClause ) ? 'AND ' : '';
                    filterClause += 'Id IN: favKnowledgeIds ';
                }

                if( filter.referred == true ){
                    filterClause += String.isNotBlank( filterClause ) ? 'AND ' : '';
                    filterClause += 'Id IN: referredKnowledgeIds ';
                }

                if( !knowledgeIds.isEmpty() ){
                    filterClause += String.isNotBlank( filterClause ) ? 'AND ' : '';
                    filterClause += 'Id IN: knowledgeIds ';
                }
            }

            //Filter by Topics
            if( filter.topics != null && !filter.topics.isEmpty() ){
                String topicsClause = '';
                for(string t : filter.topics) {
                    topicsClause += ',\'' + t + '\'';
                }
                topicsClause = topicsClause.substring(1, topicsClause.length() - 1);
                topicsClause = topicsClause + '\'';

                filterClause += String.isNotBlank( filterClause ) ? 'AND ' : '';
                filterClause += 'Community_Topics__c INCLUDES (' + topicsClause + ') ';
            }

            //Filter by Location
            if( filter.location != null && !filter.location.isEmpty() ){
                locations = new Set<String>( filter.location );
                filterClause += String.isNotBlank( filterClause ) ? 'AND ' : '';
                filterClause += 'Account_Billing_Address_State__c IN: locations ';
            }

            //by specific Id
            if( filter.articleId != null ){
                knowledgeIds.add( filter.articleId );
                filterClause += String.isNotBlank( filterClause ) ? 'AND ' : '';
                filterClause += 'Id IN: knowledgeIds ';
            }
        }

        if( String.isNotBlank( filterClause ) ){
            query += ' WHERE ' + filterClause;
            query += ' AND ArchivedById = NULL';
        } else {
            query += ' WHERE ArchivedById = NULL';
        }
        query += ' AND RecordTypeId != NULL';
        query += ' AND RecordTypeId = :knowledgeRecordTypeId';
        query += ' AND IsLatestVersion = TRUE';
        query += ' AND PublishStatus = \'Online\'';

        query += applySort( filter );
        return Database.query( query );
    }

    //Sort by specified field
    private static String applySort( ResourceFilterWrapper filter ){
        if ( filter == null ) {
            return '';
        }
        if( String.isNotBlank( filter.sortByField ) &&  String.isNotBlank( filter.sortOrder ) ){
            return ' ORDER BY ' + filter.sortByField + ' ' + filter.sortOrder;
        }
        return '';
    } 

    //Get Referral records by logged in user
    private static List<Referral_Record__c> getReferralRecords( Id currentLoggedAccount ){
        return [SELECT Favourite__c, Featured__c,
                Referred__c, Knowledge_Article_Referred__c
                FROM Referral_Record__c
                WHERE Patient__c =: currentLoggedAccount];
    }

    //Wrapper class for Knowledge Filter
    public class ResourceFilterWrapper{
        @AuraEnabled
        public Id articleId {get;set;}

        @AuraEnabled
        public List<String> type {get;set;}

        @AuraEnabled
        public boolean featured {get;set;}

        @AuraEnabled
        public List<String> location {get;set;}

        @AuraEnabled
        public List<String> topics {get;set;}

        @AuraEnabled
        public boolean favourites{get;set;}

        @AuraEnabled
        public boolean referred{get;set;}

        @AuraEnabled
        public String sortByField{get;set;}

        @AuraEnabled
        public String sortOrder{get;set;}
    }
}