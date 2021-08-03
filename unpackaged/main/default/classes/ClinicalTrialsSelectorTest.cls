/**
 * Tests for ClinicalTrialsSelector
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2020-06-01
 */
@IsTest
private class ClinicalTrialsSelectorTest {

    @TestSetup
    static void setup() {
        ClinicalTrialsTestDataFactory.insertTrialsAndTrialPatients();
    }

    @IsTest
    static void selectAllVisible() {
        Test.startTest();

        List<Clinical_Trial__c> result = new ClinicalTrialsSelector().selectAllVisible(10);

        Test.stopTest();

        System.assertEquals(2, result.size());

        System.assertEquals(ClinicalTrialsTestDataFactory.TRIAL_1_NCTID, result[0].NCTId__c,
                'The first record should be the expected record');
        System.assertEquals(0, result[0].Clinical_Trial_Patients__r.size(), 'No patient records should be returned');

        System.assertEquals(ClinicalTrialsTestDataFactory.TRIAL_2_NCTID, result[1].NCTId__c,
                'The second record should be the expected record');
        System.assertEquals(1, result[1].Clinical_Trial_Patients__r.size(), 'One patient record should be returned');
    }

    @IsTest
    static void selectById() {
        Clinical_Trial__c trial3 = ClinicalTrialsTestDataFactory.getTrial3();

        Test.startTest();

        List<Clinical_Trial__c> result = new ClinicalTrialsSelector().selectById(new Set<Id>{ trial3.Id });

        Test.stopTest();

        System.assertEquals(1, result.size());

        System.assertEquals(ClinicalTrialsTestDataFactory.TRIAL_3_NCTID, result[0].NCTId__c,
                'The first record should be the expected record');
        System.assertEquals(0, result[0].Clinical_Trial_Patients__r.size(), 'No patient records should be returned');
    }

    @IsTest
    static void selectByIdWithChildren() {
        Clinical_Trial__c trial2 = ClinicalTrialsTestDataFactory.getTrial2();
        Clinical_Trial__c trial3 = ClinicalTrialsTestDataFactory.getTrial3();

        Test.startTest();

        List<Clinical_Trial__c> result =
                new ClinicalTrialsSelector().selectByIdWithChildren(new Set<Id>{ trial2.Id, trial3.Id });

        Test.stopTest();

        System.assertEquals(2, result.size());

        System.assertEquals(ClinicalTrialsTestDataFactory.TRIAL_2_NCTID, result[0].NCTId__c,
                'The second record should be the expected record');
        System.assertEquals(1, result[0].Clinical_Trial_Patients__r.size(), 'One patient record should be returned');

        System.assertEquals(ClinicalTrialsTestDataFactory.TRIAL_3_NCTID, result[1].NCTId__c,
                'The first record should be the expected record');
        System.assertEquals(0, result[1].Clinical_Trial_Patients__r.size(), 'No patient records should be returned');
    }
}