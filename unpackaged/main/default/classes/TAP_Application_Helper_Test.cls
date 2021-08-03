@isTest
public class TAP_Application_Helper_Test {
    @testSetup static void setup() {
        
        //List<User> createUser = TAP_TestDataFactory.createUser();
        
        //Create common test accounts
        List<Account> testaccounts = TAP_TestDataFactory.createAccount(2,'Account');
        
        // Create common test care Program
        List<CareProgram> testCarePrograms = TAP_TestDataFactory.createCareProgram(2,'careProgram');
        
        // Create common test application
        List<Application__c> testapplications = TAP_TestDataFactory.createApplication(1,testaccounts[0].Id,testCarePrograms[0].Id);
        // Create common test EnrollmentEligibilityCriteria
        List<EnrollmentEligibilityCriteria> enrollmentEligibilityCriterias = TAP_TestDataFactory.createEnrollmentEligibilityCriteria(1,'Income','TestIncomeCriteria');
        
        // Create common test CareProgramEligibilityRule
        List<CareProgramEligibilityRule> careProgramRules = TAP_TestDataFactory.careProgramEligibilityRule(1,enrollmentEligibilityCriterias[0].Id,testCarePrograms[0].Id);
        
        // Create common test CareProgramEligibilityRule
        List<Eligibility_Detail__c> eligibilityDetails =TAP_TestDataFactory.createEligibilityDetail('Income',enrollmentEligibilityCriterias[0].Id,'NY','10001'); 
        
    }
    
    @isTest static void calculateStatusDurationTest(){
        
        //SOQL to get Account
        List<Account> accounts = [SELECT Id,Payment_Date__c,PersonEmail FROM Account  WHERE LastName = 'Account0'];
        
        //SOQL to get Care Program
        List<CareProgram> careProgram = [Select Id FROM CareProgram WHERE Name = 'careProgram0'];
        
        //SOQL to get Application
        Application__c application = [SELECT ID,New_Status_Duration__c FROM Application__c WHERE Patient__c =:accounts[0].id];
        
        //Update Application
        application.Application_Status__c = TAP_Constants.APPLICATION_STATUS_IN_REVIEW;
        application.Status_Change_Date__c = date.newInstance(2020, 07,15);
        update application;
		
        //Update Application
        application.Application_Status__c = TAP_Constants.APPLICATION_STATUS_NEED_MORE_INFO;
        application.Status_Change_Date__c = date.newInstance(2020, 07,18);
        update application;
		
        //Update Application
        application.Application_Status__c = TAP_Constants.APPLICATION_STATUS_DEFERRED;
        application.Status_Change_Date__c = date.newInstance(2020, 07,20);
        update application;
        
        //Update Application
        application.Status_Change_Date__c = date.newInstance(2020, 07,25);
        application.Application_Status__c = TAP_Constants.APPLICATION_STATUS_APPROVED; 
        update application;

        test.startTest();
        TAP_Application_Helper.calculateStatusDuration(application,'new');
        test.stopTest(); 
        
        //SOQL to get Application
        Application__c applications = [SELECT ID,In_Review_Status_Duration__c,Need_More_Info_Status_Duration__c,Deferred_Status_Duration__c 
                                            FROM Application__c WHERE Patient__c =:accounts[0].id];
        
        //Asserts for Duration check
        system.assertEquals(true,applications.In_Review_Status_Duration__c != null);
        system.assertEquals(true,applications.Need_More_Info_Status_Duration__c != null);
        system.assertEquals(true,applications.Deferred_Status_Duration__c != null);   
    }
    
    @isTest static void updateIncomeGuidelinesCheck(){
        String incomeGuideLines ='No Income Guidelines On Care Program';
        List<Account> accounts = [SELECT Id,Payment_Date__c,PersonEmail FROM Account  WHERE LastName = 'Account0'];
        
        List<Application__c> applications = [SELECT ID,Care_Program__c,Poverty_Level__c FROM Application__c WHERE Patient__c =:accounts[0].id];
        test.startTest();
        TAP_Application_Helper.updateIncomeGuidelinesCheck(applications);
        test.stopTest();
        
        Application__c application = [SELECT Id,Care_Program__c,Poverty_Level__c,Applicant_within_income_guideline__c 
                                      FROM Application__c WHERE Id=:applications[0].Id];
        
        // system.debug('@@application'+application);
        system.assertEquals(incomeGuideLines, application.Applicant_within_income_guideline__c);  
    }
    
    @isTest static void getIncompleteReviewChecksTest(){
        
        String comments  = '(Invalid income proof, Patient is not in active Breast Cancer treatment, Income not withing income guidelines)';
        
        //SOQL to get Account
        List<Account> accounts = [SELECT Id,Payment_Date__c,PersonEmail FROM Account WHERE LastName = 'Account0'];
        
        //SOQL to get Application
        Application__c application = [SELECT ID,Care_Program__c FROM Application__c WHERE Patient__c =:accounts[0].id];
        application.Income_Verification_is_Valid__c = TAP_Constants.NO;
        application.Physician_confirms_patient_inactive_tre__c = TAP_Constants.NO;
        application.Applicant_within_income_guideline__c = TAP_Constants.NO;
        update application;
        
        test.startTest();
        List<String> reviewCheck = TAP_Application_Helper.getIncompleteReviewChecks(application.id);
        String returnComments = String.valueOf(reviewCheck);
        test.stopTest();
        
        //Asserts to checking rejection commentxs
        system.assertEquals(comments,returnComments);  
    }
    
    @isTest static void getIncompleteReviewCheckwithNoProofTest(){
        
        String comment  = '(Income details not provided)';
        
        List<Account> accounts = [SELECT Id,Payment_Date__c,PersonEmail FROM Account  WHERE LastName = 'Account0'];
       
        //SOQL to get Application   
        Application__c application = [SELECT ID,Care_Program__c FROM Application__c WHERE Patient__c =:accounts[0].id];
        application.Income_Verification_is_Valid__c = TAP_Constants.YES;
        application.Physician_confirms_patient_inactive_tre__c = TAP_Constants.YES;
		application.Applicant_within_income_guideline__c = TAP_Constants.UNKNOWN;
        update application;
        
        test.startTest();
        List<String> reviewCheckwithNoProof = TAP_Application_Helper.getIncompleteReviewChecks(application.id);
        test.stopTest();
        
        String returnComment = String.valueOf(reviewCheckwithNoProof);
        //Asserts forrejection comments
        system.assertEquals(comment,returnComment); 
    }   
    @isTest static void copyEmailIdFromAccountTest(){
        
        List<Account> accounts = [SELECT Id,Payment_Date__c,PersonEmail FROM Account];
        
        Map<Id,Application__c> oldApplicationsMap = New Map<Id,Application__c>();
        List<Application__c> applications = [SELECT ID,Patient__c,Care_Program__c FROM Application__c WHERE Patient__c =:accounts[0].id];
        oldApplicationsMap.put(applications[0].id,applications[0]);
        system.debug('@@oldApplicationsMap :: '+oldApplicationsMap);
        applications[0].Patient__c = accounts[1].Id;
        update applications[0];
        system.debug('@@updatedApplication::'+applications);
        
        test.startTest();
        TAP_Application_Helper.copyEmailIdFromAccount(applications,oldApplicationsMap);
        test.stopTest();
        
        Application__c application = [SELECT Id,Applicant_Email__c,Patient__c FROM Application__c WHERE Patient__c =:accounts[1].id];
        system.debug('@@application'+application);
        system.assertEquals(accounts[1].PersonEmail, application.Applicant_Email__c);
        
        
        
    }
}