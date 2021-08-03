@isTest
public class TAP_ApplicationTrigger_Handler_Test { 
    @testSetup static void setup() {
        
        // Create common test User
        List<User> testUser = TAP_TestDataFactory.createUser();
        
        //Create common test accounts
        List<Account> testaccounts = TAP_TestDataFactory.createAccount(2,'Account');
        
        // Create common test care Program
        List<CareProgram> testCarePrograms = TAP_TestDataFactory.createCareProgram(2,'careProgram');
        
        // Create common test application
        List<Application__c> testapplications = TAP_TestDataFactory.createApplication(1,testaccounts[0].Id,testCarePrograms[0].Id);    
    }
    
    @isTest static void applicationTest(){
        
        //SOQL to get Account
        List<Account> accounts = [SELECT Id,Payment_Date__c,PersonEmail FROM Account WHERE LastName = 'Account0'];
        
        //SOQL to get Care Program
        List<CareProgram> careProgram = [Select Id FROM CareProgram WHERE Name = 'careProgram0'];
        
        //SOQL to get Application
        List<Application__c> application = [SELECT ID,Status_Change_Date__c,Applicant_within_income_guideline__c FROM Application__c WHERE Patient__c =:accounts[0].id];
        
        //Assert for checking Status Change Date
        system.assertEquals(system.today(), application[0].Status_Change_Date__c);
        
        //query to get Suggested Care Program
        List<Suggested_Care_Program__c> suggestedCareProgram = [SELECT Id,Name,Application__c FROM Suggested_Care_Program__c WHERE Application__c =:application[0].Id];
        
        //Assert for checking application on Suggested Care Programs
        system.assertEquals('No Income Guidelines On Care Program', application[0].Applicant_within_income_guideline__c);
        
        //Update Application
        application[0].Application_Status__c =TAP_Constants.APPLICATION_STATUS_IN_REVIEW;
        update application;
        
        //query to get Application
        List<Application__c> applicationToUse = [SELECT ID,Status_Change_Date__c,New_Status_Duration__c FROM Application__c WHERE Patient__c =:accounts[0].Id];
        //Asserts for checking 
        system.assertEquals(system.today(), applicationToUse[0].Status_Change_Date__c);
        
        //Update Applucation status
        application[0].Application_Status__c =TAP_Constants.APPLICATION_STATUS_APPROVED;
        update application;
        
        // List of Suggested Care Programs
        List<Suggested_Care_Program__c> suggestedCarePrograms = [select Id from Suggested_Care_Program__c where Id =:suggestedCareProgram[0].Id];
        //Asserts for checking Suggested Care Programs get deleted or not
        system.assertEquals(0,suggestedCarePrograms.size());
    }  
}