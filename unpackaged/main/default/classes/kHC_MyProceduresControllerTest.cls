/**
 * Created by vupneja on 10/9/2020.
 */

@isTest
public with sharing class kHC_MyProceduresControllerTest {
    private static final String PERSON_EMAIL = 'peggy@komen.org';

    @TestSetup
    static void setup() {
        String picklistValue = 'Lumpectomy';
        List<String> picklistValues = getPickListValuesIntoList();
        if(picklistValues.size() > 0) {
            picklistValue = picklistValues[0];
        }
        Account person1 = MKH_TestDataFactory.createPersonAccount('Peggy', 'Peggerson', 'peggy@komen.org', true);

        HealthCloudGA__EHRProcedure__c myProcedure = new HealthCloudGA__EHRProcedure__c(HealthCloudGA__Account__c = person1.Id,
                Procedure_Type__c = picklistValue, HealthCloudGA__PerformedDateTime__c =  DateTime.now());
        insert myProcedure;
    }

     private static List<String> getPickListValuesIntoList(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = HealthCloudGA__EHRProcedure__c.Procedure_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }
        return pickListValuesList;
    }

    private static Account getMyAccount() {
        return [SELECT Organ_Donor__pc FROM Account WHERE PersonEmail = :PERSON_EMAIL];
    }


    @IsTest
    static void getMyProcedureTest() {

        String picklistValue = 'Lumpectomy';
        List<String> picklistValues = getPickListValuesIntoList();
        if(picklistValues.size() > 0) {
            picklistValue = picklistValues[0];
        }

        Account myAccount = getMyAccount();

        Test.startTest();
        List<HealthCloudGA__EHRProcedure__c> procedureInfo = kHC_MyProceduresController.getProcedures(myAccount.Id);
        Test.stopTest();

        System.assertEquals(procedureInfo[0].Procedure_Type__c, picklistValue, 'Procedure should be ' + picklistValue);
    }

    private static List<HealthCloudGA__EHRProcedure__c> getProcedure() {
        Account account = getMyAccount();
        return [
                SELECT Procedure_Type__c, HealthCloudGA__PerformedDateTime__c, HealthCloudGA__Account__c, Id
                FROM HealthCloudGA__EHRProcedure__c
                WHERE HealthCloudGA__Account__c = :account.Id
                LIMIT 1
        ];
    }

    @IsTest
    static void getEditProcedureTest() {
        String picklistValue = 'Lumpectomy';
        List<String> picklistValues = getPickListValuesIntoList();
        if(picklistValues.size() > 0) {
            picklistValue = picklistValues[0];
        }

        Account account = getMyAccount();
        HealthCloudGA__EHRProcedure__c procedure = getProcedure()[0];

        List<HealthCloudGA__EHRProcedure__c> editProcedure = kHC_MyProceduresController.getEditProcedure(account.Id, procedure.Id);
        System.assertEquals(1, editProcedure.size());
        System.assertEquals(account.Id, editProcedure[0].HealthCloudGA__Account__c);
        System.assertEquals(procedure.Id, editProcedure[0].Id); 
    }
}