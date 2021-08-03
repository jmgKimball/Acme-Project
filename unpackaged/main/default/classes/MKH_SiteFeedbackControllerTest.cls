/**
 * Tests for MKH_SiteFeedbackController
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2020-11-13
 */
@IsTest
private class MKH_SiteFeedbackControllerTest {
    @IsTest
    static void insertFeedback() {
        final Id userId = UserInfo.getUserId();
        final Boolean isPositive = true;
        final String page = '/example';
        final String comments = 'This page is great';

        MKH_SiteFeedbackController.Feedback feedback = new MKH_SiteFeedbackController.Feedback();
        feedback.user = userId;
        feedback.positive = isPositive;
        feedback.page = page;
        feedback.comments = comments;

        Test.startTest();

        MKH_SiteFeedbackController.insertFeedback(feedback);

        Test.stopTest();

        List<Site_Feedback__c> result = [SELECT Id, User__c, Positive__c, Page__c, Comments__c FROM Site_Feedback__c];
        System.assertEquals(1, result.size(), 'One record should have been inserted');

        Site_Feedback__c actual = result[0];
        Site_Feedback__c expected = new Site_Feedback__c(
                Id = actual.Id,
                User__c = userId,
                Positive__c = isPositive,
                Page__c = page,
                Comments__c = comments
        );

        System.assertEquals(expected, actual, 'The record should have the expected values');
    }
}