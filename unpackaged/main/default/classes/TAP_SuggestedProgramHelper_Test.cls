@isTest
public class TAP_SuggestedProgramHelper_Test {
    @testSetup static void setup() {
        
        //Create common test accounts
        List<Account> testaccounts = TAP_TestDataFactory.createAccount(2,'Account'); 
        
        // Create common test care Program
        List<CareProgram> testCarePrograms = TAP_TestDataFactory.createCareProgram(3,'careProgram');

        // Create common test application
        List<Application__c> testapplication1 = TAP_TestDataFactory.createApplication(1,testaccounts[0].Id,testCarePrograms[0].Id);
        
        // Create common test application
        List<Application__c> testapplication2 = TAP_TestDataFactory.createApplication(1,testaccounts[0].Id,testCarePrograms[1].Id);
        
        // Create common test application
        List<Application__c> testapplication3 = TAP_TestDataFactory.createApplication(1,testaccounts[0].Id,testCarePrograms[2].Id);
        
        // Create common test EnrollmentEligibilityCriteria Income Based
        List<EnrollmentEligibilityCriteria> enrollmentEligibilityCriteriaIncomeBased = TAP_TestDataFactory.createEnrollmentEligibilityCriteria(1,'Income','TestIncomeBasedCriteria');
        
        // Create common test EnrollmentEligibilityCriteria Zip Based
        List<EnrollmentEligibilityCriteria> enrollmentEligibilityCriteriaZipBased = TAP_TestDataFactory.createEnrollmentEligibilityCriteria(1,'Zip','TestZipBasedCriteria');
        
        // Create common test EnrollmentEligibilityCriteria Income Based
        List<EnrollmentEligibilityCriteria> enrollmentEligibilityCriteriasUSAResidentBased = TAP_TestDataFactory.createEnrollmentEligibilityCriteria(1,'USA Resident','TestUSAResidentBasedCriteria');
        
        // Create common test CareProgramEligibilityRule With Income Based Criteria
        List<CareProgramEligibilityRule> careProgramRuleWithIncomeBasedCriteria = TAP_TestDataFactory.careProgramEligibilityRule(1,enrollmentEligibilityCriteriaIncomeBased[0].Id,testCarePrograms[0].Id);
        
        // Create common test CareProgramEligibilityRule With Zip Based Criteria
        List<CareProgramEligibilityRule> careProgramRuleWithZipBasedCriteria = TAP_TestDataFactory.careProgramEligibilityRule(1,enrollmentEligibilityCriteriaZipBased[0].Id,testCarePrograms[1].Id);
        
        // Create common test CareProgramEligibilityRule With USA Resident Based Criteria
        List<CareProgramEligibilityRule> careProgramRuleWithUSAResidentBasedCriteria = TAP_TestDataFactory.careProgramEligibilityRule(1,enrollmentEligibilityCriteriasUSAResidentBased[0].Id,testCarePrograms[2].Id);
        
        // Create common test CareProgramEligibilityRule With Income Based Criteria
        List<Eligibility_Detail__c> eligibilityDetailWithZipBasedCriteria =TAP_TestDataFactory.createEligibilityDetail('Income',enrollmentEligibilityCriteriaIncomeBased[0].Id,'NY','10001');
        
        // Create common test CareProgramEligibilityRule With Income Based Criteria
        List<Eligibility_Detail__c> eligibilityDetailIncomeBasedCriteria =TAP_TestDataFactory.createEligibilityDetail('Location',enrollmentEligibilityCriteriaZipBased[0].Id,'TX','73301');
        
        // Create common test CareProgramEligibilityRule With Income Based Criteria
        List<Eligibility_Detail__c> eligibilityDetailUSAResidentBasedCriteria =TAP_TestDataFactory.createEligibilityDetail('Income',enrollmentEligibilityCriteriasUSAResidentBased[0].Id,'CA','90002');   
    }
    
    @isTest 
    static void calculateSuggestedProgramsTest(){
        
        //SOQL to get Account
        List<Account> accounts = [SELECT Id,Payment_Date__c,PersonEmail FROM Account WHERE LastName ='Account0'];
        
        //SOQL to get Care Program
        List<CareProgram> careProgram = [Select Id FROM CareProgram WHERE NAME = 'careProgram0'];
        
        //SOQL to get Application
        List<Id> applicationId = new List<Id>();
        List<Application__c> applications = [SELECT ID,Status_Change_Date__c FROM Application__c WHERE Patient__c =:accounts[0].id];
        applicationId.add(applications[0].Id);
        
        test.startTest();
        Map<Id,List<Id>> mapOfCareProgramAndApplicaion = TAP_SuggestedProgramHelper.calculateSuggestedPrograms(applicationId);
        test.stopTest();
        
        List<Application__c> applicationList = [Select Id,Care_Program__c From Application__c where Id=:mapOfCareProgramAndApplicaion.Keyset()];
        system.assertEquals(1,mapOfCareProgramAndApplicaion.get(applicationId[0]).size());   
    }
    
    @isTest 
    static void suggestedProgramsTest(){
        //SOQL to get Account
        List<Account> accounts = [SELECT Id,Payment_Date__c,PersonEmail FROM Account WHERE LastName ='Account0'];
        
        //SOQL to get Applications  
        List<Application__c> applications = [SELECT ID,Status_Change_Date__c,Care_Program__c FROM Application__c WHERE Patient__c =:accounts[0].id];
 
        test.startTest();
        Map<Id,List<Id>> mapOfCareProgramAndApplicaion = TAP_SuggestedProgramHelper.calculateSuggestedPrograms(accounts);
        test.stopTest();
        
        List<Id> careProgramIds = new List<Id>();
        careProgramIds.addAll(mapOfCareProgramAndApplicaion.get(applications[0].id));
        
        //Asserts to check Care Programs related to application
        system.assertEquals(1,careProgramIds.size()); 
    }
    
    @isTest 
    static void deleteSuggestedCarePrograms(){
        
        //SOQL to get Account
        List<Account> accounts = [SELECT Id,Payment_Date__c,PersonEmail FROM Account WHERE LastName ='Account0'];
        
        //SOQL to get Applications
        List<Application__c> applications = [SELECT ID,Status_Change_Date__c FROM Application__c WHERE Patient__c =:accounts[0].id];
        
        test.startTest();
        TAP_SuggestedProgramHelper.deleteSuggestedCarePrograms(applications);
        test.stopTest();
        
        //List for suggested care Programs
        List<Suggested_Care_Program__c> listOfDeletedSuggestedCareProgram = [SELECT Id,Name from Suggested_Care_Program__c 
                                                                             WHERE Application__c IN :applications];
        //Asserts for checking suggested care Programs is null
        system.assertEquals(0,listOfDeletedSuggestedCareProgram.size());  
    }
    
    @isTest 
    static void isSelectedCareProgramSuggestedTest(){
        
        //SOQL to get Account
        List<Account> accounts = [SELECT Id,Payment_Date__c,PersonEmail FROM Account WHERE LastName ='Account0'];
        
        //SOQL to get Applications
        List<Application__c> applications = [SELECT ID,Status_Change_Date__c FROM Application__c WHERE Patient__c =:accounts[0].id];
        
        //SOQL to get Care Programs
        List<CareProgram> careProgram = [Select Id FROM CareProgram WHERE NAME = 'careProgram0'];
        
        test.startTest();
        Boolean iscareProgramInSuuggested = TAP_SuggestedProgramHelper.isSelectedCareProgramSuggested(applications[0].Id,careProgram[0].id);
        test.stopTest();
        system.assertEquals(true, iscareProgramInSuuggested);         
    }  
}