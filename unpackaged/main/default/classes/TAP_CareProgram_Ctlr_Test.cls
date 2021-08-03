@isTest
public class TAP_CareProgram_Ctlr_Test {
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
    }

    @isTest static void loadProgramDetails(){
        
        //List of CarePrograms
        CareProgram careProgram = [SELECT ID,Payout_Amount__c FROM CareProgram WHERE Name = 'careProgram0'];
        
        test.startTest();
        Map<String,Integer> loadProgramDetailsMap = TAP_CareProgram_Ctlr.loadProgramDetails(careProgram.id);
        test.stopTest();
       
        //List of EnrollmentEligibilityCriteria
        List<EnrollmentEligibilityCriteria> enrollmentEligibilityCriteria = [SELECT Id FROM EnrollmentEligibilityCriteria WHERE Name ='TestIncomeCriteria'];
        system.assertEquals(1, enrollmentEligibilityCriteria.size());
        
        //List of CareProgramEligibilityRule
        List<CareProgramEligibilityRule> careProgramRule = [SELECT Id FROM CareProgramEligibilityRule WHERE CareProgramId =:careProgram.Id];
        system.assertEquals(1, careProgramRule.size());
        
        //List of Eligibility Details
        List<Eligibility_Detail__c> eligibilityDetail =  [SELECT Id FROM Eligibility_Detail__c WHERE Eligibility_Criteria__c =:enrollmentEligibilityCriteria[0].Id];
        system.assertEquals(0, eligibilityDetail.size());   
    }
}