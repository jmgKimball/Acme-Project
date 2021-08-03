@isTest
public class TAP_Application_Ctlr_Test {
    @testSetup static void setup() {
        
        // Create common test User
        List<User> testUser = TAP_TestDataFactory.createUser();
        
        //Create common test accounts
        List<Account> testaccounts = TAP_TestDataFactory.createAccount(2,'Account');
        
        // Create common test care Program
        List<CareProgram> testCarePrograms = TAP_TestDataFactory.createCareProgram(2,'careProgram');
        
        // Create common test application
        List<Application__c> testapplications = TAP_TestDataFactory.createApplication(2,testaccounts[0].Id,testCarePrograms[0].Id);   
    }
    
    @isTest static void initialValueTest(){
  
        //SOQL to get Account
        List<Account> accounts = [SELECT Id,Payment_Date__c,PersonEmail FROM Account WHERE LastName = 'Account0'];
        
        //SOQL to get Care Program
        List<CareProgram> careProgram = [SELECT Id FROM CareProgram  WHERE Name = 'careProgram0'];
        
        //SOQL to get Application
        Application__c application = [SELECT ID FROM Application__c WHERE Patient__c =:accounts[0].id LIMIT 1];
        
        Test.startTest();
        String Status = TAP_Application_ctlr.initialValue(application.Id);
        Test.stopTest();
        
        //Assert for checking status
        system.assertEquals('New',status);
    }
    
    @isTest static void loadProgramsTest(){
        
        //SOQL to get Account
        List<Account> accounts = [SELECT Id,Payment_Date__c,PersonEmail FROM Account WHERE LastName = 'Account0'];
        
        //SOQL to get Care Program
        List<CareProgram> careProgram = [SELECT Id FROM CareProgram WHERE Name = 'careProgram0'];
        
        //SOQL to get Application
        Application__c application = [SELECT ID FROM Application__c WHERE Patient__c =:accounts[0].id LIMIT 1];
        
        Test.startTest();
        Map<String,List<CareProgram>> careProgramMap = TAP_Application_ctlr.loadPrograms(application.Id);
        Test.stopTest();
        
        //Assert for checking size of care Program
        system.assertEquals(3,careProgramMap.size());  
    }
    
    @isTest static void relatedApplicationlistTest(){
        
        //SOQL to get Account
        List<Account> accounts = [SELECT Id,Payment_Date__c,PersonEmail FROM Account WHERE LastName = 'Account0'];
        
        //SOQL to get Care Program
        List<CareProgram> careProgram = [SELECT Id FROM CareProgram WHERE  Name = 'careProgram0'];
        
        //SOQL to get Application
        Application__c application = [SELECT ID FROM Application__c WHERE Patient__c =:accounts[0].id LIMIT 1];
        
        test.startTest();
        List<Application__c> apps= TAP_Application_ctlr.relatedApplicationlist(application.Id);
        test.stopTest();
        
        //List of Application
        List<Application__c> otherApplication = [SELECT ID FROM Application__c WHERE Id != :application.Id];
        
        //Assert for checking application other than current application
        system.assertEquals(1,otherApplication.size());    
    }
    
    @isTest static  void calculateRejectionCommentTest(){
        
        String rejectionComment ='<html><body><ul><li>Patient is not in active Breast Cancer treatment</li></ul></body></html>';
        
        //SOQL to get Account
        List<Account> accounts = [SELECT Id,Payment_Date__c,PersonEmail FROM Account WHERE LastName = 'Account0'];
        
        //SOQL to get Application
        Application__c application = [SELECT ID FROM Application__c WHERE Patient__c =:accounts[0].id LIMIT 1];
        application.Income_Verification_is_Valid__c = TAP_Constants.YES;
        application.Physician_confirms_patient_inactive_tre__c = TAP_Constants.NO;
        application.Applicant_within_income_guideline__c = TAP_Constants.YES;
        update application;
        
        test.startTest();
        String rejectionComments =  TAP_Application_ctlr.calculateRejectionComment(application.Id);  
        test.stopTest();
        
        //Assert for checking rejection comments
        system.assertEquals(rejectionComment, rejectionComments);
    }
    
    @isTest static void checkAccessTest(){
        
        test.startTest();
        Map<String,Boolean> hasEditAccessToApplicationMap = TAP_Application_ctlr.checkAccessOnApplication(); 
        test.stopTest();
        
        // Checking User have dit access on application or not
        system.assertEquals(true, hasEditAccessToApplicationMap.get('hasEditAccess'));   
    }

    @isTest static void checkEditTest(){
        //SOQL to get Account
        List<Account> accounts = [SELECT Id,Payment_Date__c,PersonEmail FROM Account WHERE LastName = 'Account0'];
        
        //SOQL to get Care Program
        List<CareProgram> careProgram = [Select Id FROM CareProgram WHERE Name = 'careProgram0'];
        
        //SOQL to get Application
        List<Application__c> application = [SELECT ID,Application_Status__c FROM Application__c WHERE Patient__c =:accounts[0].id];
        application[0].Application_Status__c = TAP_Constants.APPLICATION_STATUS_APPROVED;
        update application;
        
        test.startTest();
        Map<String,Boolean> hasEditAccessToApplicationMap = TAP_Application_ctlr.checkAccessesOnApplication(application[0].Id); 
        test.stopTest();
        
        //Asserts for checking access
        system.assertEquals(true, hasEditAccessToApplicationMap.get('hasEditAccess'));
        system.assertEquals(true, hasEditAccessToApplicationMap.get('isAdmin'));
        
    }
    
    
    @isTest static void isCareProgramSuggestedTest(){
        
        ///SOQL to get Account
        List<Account> accounts = [SELECT Id,Payment_Date__c,PersonEmail FROM Account WHERE LastName = 'Account0'];
        
        //SOQL to get Care Program
        List<CareProgram> careProgram = [Select Id FROM CareProgram WHERE Name = 'careProgram0'];
        
        //SOQL to get Application
        List<Application__c> application = [SELECT ID FROM Application__c WHERE Patient__c =:accounts[0].id LIMIT 1];

        test.startTest();
        Boolean isCareProgramSuggested = TAP_Application_ctlr.isCareProgramSuggested(application[0].Id,careProgram[0].Id); 
        test.stopTest();
        
        //Asserts for checking care program is in Suggested Care Program
        system.assertEquals(true, isCareProgramSuggested);
    }
}