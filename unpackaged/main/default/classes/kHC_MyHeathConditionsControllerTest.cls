/**
 * Created by vupneja on 9/18/2020.
 */


@isTest
public with sharing class kHC_MyHeathConditionsControllerTest {
    private static final String PERSON_EMAIL = 'peggy@komen.org';
    @TestSetup
    static void setup() {
        Account person1 = MKH_TestDataFactory.createPersonAccount('Peggy', 'Peggerson', 'peggy@komen.org', true);
        person1.Organ_Donor__pc = true;
        update person1;

        List<RecordType> recordTypes = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'HealthCloudGA__EhrCondition__c'];
        Schema.SobjectType.HealthCloudGA__EhrCondition__c.getRecordTypeInfosByName().get('Breast Cancer').getRecordTypeId();
        HealthCloudGA__EhrCondition__c myCondition = new HealthCloudGA__EhrCondition__c(Breast_Cancer_Sub_Type__c='TNBC (ER-/PR-/HER2-)', HealthCloudGA__Account__c = person1.Id,
                                                                                            Breast_Cancer_Type__c ='Invasive Lobular Carcinoma', Stage_at_Diagnosis__c ='Stage-I',
                                                                                            Condition_Name__c ='Breast Cancer', HealthCloudGA__IsAbated__c =true,
                                                                                            HealthCloudGA__Notes__c='Breast Cancer', RecordTypeId = Schema.SobjectType.HealthCloudGA__EhrCondition__c.getRecordTypeInfosByName().get('Breast Cancer').getRecordTypeId());
                                                                                            //recordtype.id =([SELECT Id, Name, DeveloperName
                                                                                              //              FROM RecordType WHERE SObjectType = 'HealthCloudGA__EhrCondition__c' limit 1].id));
        insert myCondition;

        HealthCloudGA__EhrCondition__c myConditionChronic = new HealthCloudGA__EhrCondition__c(HealthCloudGA__Account__c = person1.Id,
                                                                                            Condition_Name__c ='Skin Problem', HealthCloudGA__IsAbated__c =true,
                                                                                            HealthCloudGA__Notes__c='Skin Problem', RecordTypeId =  Schema.SobjectType.HealthCloudGA__EhrCondition__c.getRecordTypeInfosByName().get('Chronic Condition').getRecordTypeId());
        //recordtype.id =([SELECT Id, Name, DeveloperName
        //              FROM RecordType WHERE SObjectType = 'HealthCloudGA__EhrCondition__c' limit 1].id));
        insert myConditionChronic;
    }

    private static Account getMyAccount() {
        return [SELECT Organ_Donor__pc FROM Account WHERE PersonEmail = :PERSON_EMAIL];
    }

    @isTest
    static void getMyHealthConditionTest(){
        Account myAccount = getMyAccount();
        //List<RecordType> recordTypes = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'HealthCloudGA__EhrCondition__c'];

        Test.startTest();
        list<RecordType> getRecordTypes = kHC_MyHeathConditionsController.getConditionRecordType();
        List<HealthCloudGA__EhrCondition__c> getConditions = kHC_MyHeathConditionsController.getBCancerConditions(myAccount.Id);
        List<HealthCloudGA__EhrCondition__c> getChronicConditions = kHC_MyHeathConditionsController.getChronicConditions(myAccount.Id);
        Test.stopTest();

        System.assertEquals(getConditions[0].Condition_Name__c,'Breast Cancer',  'Condition_Name should be Breast Cancer');
        System.assertEquals(getChronicConditions[0].Condition_Name__c,'Skin Problem',  'Condition_Name should be Skin Problem');
    }

    private static List<HealthCloudGA__EhrCondition__c> getCondition() {
        Account myAccount = getMyAccount();
        return [SELECT Id, HealthCloudGA__Account__c FROM HealthCloudGA__EhrCondition__c
        WHERE HealthCloudGA__Account__c =: myAccount.Id LIMIT 1];
    }

    @IsTest
    static void getConditionTest() {
        Account myAccount = getMyAccount();
        HealthCloudGA__EhrCondition__c cond = getCondition()[0];
        Test.startTest();
        List<HealthCloudGA__EhrCondition__c> conditions = kHC_MyHeathConditionsController.getCondition(cond.Id, myAccount.Id);
        Test.stopTest();
        System.assertEquals(1, conditions.size());
        System.assertEquals(cond.Id, conditions[0].Id);
        System.assertEquals(myAccount.Id, conditions[0].HealthCloudGA__Account__c);
    }

}