/**
 * Server-side controller for Site Feedback component.
 * Necessary to prevent granting read access to site feedback records to anonymous or community users
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2020-11-13
 */
public without sharing class MKH_SiteFeedbackController {

    @AuraEnabled
    public static void insertFeedback(Feedback feedback) {
        insert new Site_Feedback__c(
                User__c = feedback.user,
                Page__c = feedback.page,
                Positive__c = feedback.positive,
                Comments__c = feedback.comments
        );
    }

    public class Feedback {
        @AuraEnabled
        public Id user { get; set; }
        @AuraEnabled
        public String page { get; set; }
        @AuraEnabled
        public Boolean positive { get; set; }
        @AuraEnabled
        public String comments { get; set; }
    }
}