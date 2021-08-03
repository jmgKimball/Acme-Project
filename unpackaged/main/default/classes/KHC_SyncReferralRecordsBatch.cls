/**
@name       KHC_SyncReferralRecordsBatch
@date       6 May 2021
@description Batch class to update referral record when linked article is an old version
@author     NChandwani, Traction on Demand 
 */
public class KHC_SyncReferralRecordsBatch implements Database.Batchable<sObject> {

    public Set<Id> knowledgeIds = new Set<Id>();

    public Database.QueryLocator start( Database.BatchableContext bc ){
        String query = ' SELECT Id, Knowledge_Article_Referred__c, Knowledge_Article_Referred__r.KnowledgeArticleId ';
        query += 'FROM Referral_Record__c ';
        query += 'WHERE Knowledge_Article_Referred__r.IsLatestVersion = FALSE ';

        if( knowledgeIds != null && !knowledgeIds.isEmpty() ){
            query+= 'AND Knowledge_Article_Referred__c IN: knowledgeIds ';
        }
        return Database.getQueryLocator( query );
    }

    public void execute( Database.BatchableContext bc, List<Referral_Record__c> refRecords ){
        Map<Id, List<Referral_Record__c>> knowledgeWithReferrals = new Map<Id, List<Referral_Record__c>>();
        for( Referral_Record__c referralRecord : refRecords){
            if( !knowledgeWithReferrals.containsKey( referralRecord.Knowledge_Article_Referred__r.KnowledgeArticleId ) ){
                knowledgeWithReferrals.put( referralRecord.Knowledge_Article_Referred__r.KnowledgeArticleId, new List<Referral_Record__c>() );
            }
            knowledgeWithReferrals.get( referralRecord.Knowledge_Article_Referred__r.KnowledgeArticleId ).add( referralRecord );
        }
        if( !knowledgeWithReferrals.isEmpty() ){
            List<Referral_Record__c> syncReferrals = new List<Referral_Record__c>();
            for( Knowledge__kav latestKnowledge : [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE IsLatestVersion = TRUE AND KnowledgeArticleId IN: knowledgeWithReferrals.keySet() AND PublishStatus = 'Online'] ){
                if( knowledgeWithReferrals.containsKey( latestKnowledge.KnowledgeArticleId ) ){
                    for( Referral_Record__c referralRecord : knowledgeWithReferrals.get( latestKnowledge.KnowledgeArticleId )){
                        referralRecord.Knowledge_Article_Referred__c = latestKnowledge.Id;
                        syncReferrals.add( referralRecord );
                    }
                    if( !syncReferrals.isEmpty() ){
                        UPDATE syncReferrals;
                    }
                }
            }
        }
    }

    public void finish( Database.BatchableContext bc ){
        
    }
}