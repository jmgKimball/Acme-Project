@isTest
public class TAP_AccountTrigger_Handler_Test {
    @testSetup static void setup() {
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

    @isTest static void accountTest(){
        Decimal level = 0.0 ;
        //query to get EnrollmentEligibilityCriteria
        EnrollmentEligibilityCriteria criteria = [SELECT Id,Criteria_Type__c,Status FROM EnrollmentEligibilityCriteria WHERE Criteria_Type__c = 'Income'];
        
        //query to get Eligibility Detalis
        List<Eligibility_Detail__c> eligibilityDetails = [SELECT Id,Per_Person_Incremental_Amount__c,Single_Person_Income_Limit__c,State__c,Is_Active__c FROM Eligibility_Detail__c 
                                                          WHERE Eligibility_Criteria__c=:criteria.Id];
        //query to get Account
        List<Account> accounts = [SELECT Id,Name,Payment_Date__c FROM Account WHERE LastName = 'Account0'];
       
        //query to get Application
        Application__c application = [SELECT ID,Care_Program__c FROM Application__c WHERE Patient__c =:accounts[0].Id];
        
        //query to get CareProgram
        CareProgram careProgram = [SELECT ID,Payout_Amount__c FROM CareProgram WHERE Name = 'careProgram0'];
        
        test.startTest();
        
        //query to get Account
        List<Account> account = [SELECT Id,Applicant_Birth_Date__c,PersonBirthdate,Payment_Date__c FROM Account WHERE Id =:accounts[0].Id];
        
        //check PersonBirthdate is same as Applicant Birth Date
        system.assertEquals(account[0].Applicant_Birth_Date__c,String.valueOf(account[0].PersonBirthdate));
        
        //update Account address
        account[0].PersonMailingStateCode = 'NY';
        accounts[0].PersonMailingPostalCode = '10001';
        update account;

        //query to get Suggested Care Program
        List<Suggested_Care_Program__c> suggestedCareProgram = [SELECT Id,Name,Application__c FROM Suggested_Care_Program__c 
                                                                WHERE Application__c = :application.id];
        
        //check Suggested Care Program size is greater than 0
        system.assert(suggestedCareProgram.size()>0);
        system.assertEquals(suggestedCareProgram[0].Application__c, application.Id);
        
        //query to get application
        List<application__c> applications = [SELECT ID,Care_Program__c,Poverty_Level__c FROM Application__c WHERE Patient__c =:accounts[0].Id];
        //Asserts to check  poverty level odf application
        system.assertEquals(184,Integer.valueOf(applications[0].Poverty_Level__c)); 
        test.stopTest();
    }
}