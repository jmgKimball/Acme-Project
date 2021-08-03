/**
 * Tests for ClinicalTrialLocationsSelector
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2020-06-01
 */
@IsTest
private class ClinicalTrialLocationsSelectorTest {
    private static final Double USER_LATITUDE = 49.2780972;
    private static final Double USER_LONGITUDE = -122.9220773;

    @TestSetup
    static void setup() {
        ClinicalTrialsTestDataFactory.insertTrialsAndLocations();
    }

    @IsTest
    static void selectByTrialId() {
        Clinical_Trial__c trial = ClinicalTrialsTestDataFactory.getTrial();

        Test.startTest();

        List<Clinical_Trial_Location__c> result =
                new ClinicalTrialLocationsSelector().selectByTrialId(new Set<Id>{ trial.Id });

        Test.stopTest();

        System.assertEquals(1, result.size(), 'One record should be returned');
        System.assertEquals(ClinicalTrialsTestDataFactory.LOC_1_KEY, result[0].Trial_Location_Key__c,
                'The location should be the record with the expected facility value');
    }

    @IsTest
    static void selectByTrialIdWithDistance() {
        Clinical_Trial__c trial2 = ClinicalTrialsTestDataFactory.getTrial2();
        Clinical_Trial__c trial3 = ClinicalTrialsTestDataFactory.getTrial3();

        Test.startTest();

        List<Clinical_Trial_Location__c> result = new ClinicalTrialLocationsSelector()
                .selectByTrialIdWithDistance(new Set<Id>{ trial2.Id, trial3.Id }, USER_LATITUDE, USER_LONGITUDE);

        Test.stopTest();

        System.assertEquals(2, result.size(), 'Two records should be returned');

        System.assertEquals(ClinicalTrialsTestDataFactory.LOC_2_KEY, result[0].Trial_Location_Key__c,
                'The first location should have the expected value');
        System.assertNotEquals(null, result[0].get('dist'), 'The distance value should be populated');

        System.assertEquals(ClinicalTrialsTestDataFactory.LOC_3_KEY, result[1].Trial_Location_Key__c,
                'The second location should have the expected value');
        System.assertEquals(null, result[1].get('dist'), 'The distance value should be null');
    }

    @IsTest
    static void selectByDistance() {
        Test.startTest();

        List<Clinical_Trial_Location__c> result = new ClinicalTrialLocationsSelector()
                .selectVisibleByDistance(USER_LATITUDE, USER_LONGITUDE, 20);

        Test.stopTest();

        System.assertEquals(1, result.size(), 'Two records should be returned');

        System.assertEquals(ClinicalTrialsTestDataFactory.LOC_1_KEY, result[0].Trial_Location_Key__c,
                'The first location should have the expected value');
        System.assertNotEquals(null, result[0].get('dist'), 'The distance value should be populated');
    }

    @IsTest
    static void selectAllVisibleWithDistance() {
        Test.startTest();

        List<Clinical_Trial_Location__c> result = new ClinicalTrialLocationsSelector()
                .selectAllVisibleWithDistance(USER_LATITUDE, USER_LONGITUDE);

        Test.stopTest();

        System.assertEquals(2, result.size(), 'Two records should be returned');

        System.assertEquals(ClinicalTrialsTestDataFactory.LOC_1_KEY, result[0].Trial_Location_Key__c,
                'The first location should have the expected value');
        System.assertNotEquals(null, result[0].get('dist'), 'The distance value should be populated');

        System.assertEquals(ClinicalTrialsTestDataFactory.LOC_2_KEY, result[1].Trial_Location_Key__c,
                'The second location should have the expected value');
        System.assertNotEquals(null, result[1].get('dist'), 'The distance value should be populated');
    }
}