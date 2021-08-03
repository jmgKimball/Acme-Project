/**
 * Tests for ClinicalTrialPatientsSelector
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2020-06-01
 */
@IsTest
private class ClinicalTrialPatientsSelectorTest {
    @TestSetup
    static void setup() {
        ClinicalTrialsTestDataFactory.insertTrialsAndTrialPatients();
    }

    @IsTest
    static void selectByTrialIdAndUserId() {
        Clinical_Trial__c trial = ClinicalTrialsTestDataFactory.getTrial();
        Clinical_Trial__c trial2 = ClinicalTrialsTestDataFactory.getTrial2();
        Set<Id> trialIds = new Set<Id>{ trial.Id, trial2.Id };

        Test.startTest();

        List<Clinical_Trial_Patient__c> result = new ClinicalTrialPatientsSelector()
                .selectByTrialIdAndUserId(trialIds, new Set<Id>{ UserInfo.getUserId() });

        Test.stopTest();

        System.assertEquals(1, result.size(), 'One record should be returned');
        System.assertEquals(trial2.Id, result[0].Clinical_Trial__c,
                'It should be the record associated with clinical trial 2');
    }
}