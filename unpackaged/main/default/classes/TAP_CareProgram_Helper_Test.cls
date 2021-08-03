@isTest
public class TAP_CareProgram_Helper_Test {
    @testSetup static void setup() {
        
        //List<User> createUser = TAP_TestDataFactory.createUser();
        
        //Create common test accounts
        List<Account> testaccounts = TAP_TestDataFactory.createAccount(2,'Account'); 
        
        // Create common test care Program
        List<CareProgram> testCarePrograms = TAP_TestDataFactory.createCareProgram(2,'careProgram');
        
        // Create Care Program With Criteria and details
        //List<CareProgram> careProgramWithCriteria = TAP_TestDataFactory.createCareProgramWithCriteriaDetails();
        List<CareProgram> careProgramWithCriteria = TAP_TestDataFactory.createCareProgram(2,'careProgram');
        
        // Create common test application
        List<Application__c> testapplications = TAP_TestDataFactory.createApplication(1,testaccounts[0].Id,testCarePrograms[0].Id);
        
        // Create common test EnrollmentEligibilityCriteria
        List<EnrollmentEligibilityCriteria> enrollmentEligibilityCriterias = TAP_TestDataFactory.createEnrollmentEligibilityCriteria(1,'Income','TestIncomeCriteria');
        
        // Create common test CareProgramEligibilityRule
        List<CareProgramEligibilityRule> careProgramRules = TAP_TestDataFactory.careProgramEligibilityRule(1,enrollmentEligibilityCriterias[0].Id,testCarePrograms[0].Id);
        
        // Create common test CareProgramEligibilityRule
        List<Eligibility_Detail__c> eligibilityDetails =TAP_TestDataFactory.createEligibilityDetail('Income',enrollmentEligibilityCriterias[0].Id,'NJ','07001'); 
        
    }
    
    @isTest static void calculatePovertyLevelForApplicationTest(){
        //SOQL to get Account
        List<Account> accounts = [SELECT Id,Payment_Date__c,PersonEmail FROM Account WHERE  LastName = 'Account0'];
        
        //SOQL to get Care Program
        List<CareProgram> careProgram = [Select Id FROM CareProgram WHERE Name = 'careProgram0'];
        
        //SOQL to get Application
        Application__c application = [SELECT ID,Status_Change_Date__c,Total_annual_Household_Income__c,No_of_People_in_the_Household__c
                                      FROM Application__c WHERE Patient__c =:accounts[0].id];
        
        List<EnrollmentEligibilityCriteria> enrollmentEligibilityCriteria = [SELECT Id FROM EnrollmentEligibilityCriteria WHERE Name ='TestIncomeCriteria'];
        
        //SOQL to get ligibility_Detail__c
        List<Eligibility_Detail__c> eligibilityDetailsList = [SELECT Eligibility_Criteria__c,State__c,Per_Person_Incremental_Amount__c,Single_Person_Income_Limit__c
                                                               FROM Eligibility_Detail__c WHERE Eligibility_Criteria__c = :enrollmentEligibilityCriteria[0].Id];
        system.debug('@@eligibilityDetailsList'+eligibilityDetailsList);
        test.startTest();
        Integer povertLevel = TAP_CareProgram_Helper.calculatePovertyLevelForApplication( application);
        test.stopTest();
        system.debug('@@povertLevel'+povertLevel);
        
        
    }
    
     @isTest static void calculatePovertyLevelForApplicantTest(){
        //SOQL to get Account
        List<Account> accounts = [SELECT Id,Payment_Date__c,PersonEmail FROM Account WHERE LastName = 'Account0'];
        
        //SOQL to get Care Program
        List<CareProgram> careProgram = [Select Id FROM CareProgram WHERE Name = 'careProgram0'];
        
        //SOQL to get Application
        Application__c application = [SELECT ID,Status_Change_Date__c,Total_annual_Household_Income__c,No_of_People_in_the_Household__c
                                      FROM Application__c WHERE Patient__c =:accounts[0].id];
        
        List<EnrollmentEligibilityCriteria> enrollmentEligibilityCriteria = [SELECT Id FROM EnrollmentEligibilityCriteria WHERE Name ='TestIncomeCriteria'];
        
        //SOQL to get ligibility_Detail__c
        List<Eligibility_Detail__c> eligibilityDetailsList = [SELECT Eligibility_Criteria__c,State__c,Per_Person_Incremental_Amount__c,Single_Person_Income_Limit__c
                                                               FROM Eligibility_Detail__c WHERE Eligibility_Criteria__c = :enrollmentEligibilityCriteria[0].Id];
        //system.debug('@@eligibilityDetailsList'+eligibilityDetailsList);
        test.startTest();
        TAP_CareProgram_Helper.updatePovertyLevelForApplicant(accounts);
        test.stopTest();
         Application__c applications = [SELECT ID,Status_Change_Date__c,Poverty_Level__c,Total_annual_Household_Income__c,No_of_People_in_the_Household__c
                                      FROM Application__c WHERE Patient__c =:accounts[0].id];
        system.debug('@@application '+applications);
        
        
    }

}