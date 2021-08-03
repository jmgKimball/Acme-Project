@isTest
public class TAP_Payment_Helper_Test {
    @testSetup static void setup() {
        //Create common test accounts
        List<Account> testaccounts = TAP_TestDataFactory.createAccount(3,'Account'); 
        
        // Create common test care Program
        List<CareProgram> testCarePrograms = TAP_TestDataFactory.createCareProgram(2,'careProgram');
        List<CareProgram> testCarePrograms1 = TAP_TestDataFactory.createCareProgram1(2,'careProgram1');
        List<CareProgram> testCarePrograms2 = TAP_TestDataFactory.createCareProgram2(1,'careProgram2');
       
        
        // Create common test application
        List<Application__c> testapplications = TAP_TestDataFactory.createApplication(2,testaccounts[0].Id,testCarePrograms[0].Id);    
        List<Application__c> testapplications1 = TAP_TestDataFactory.createApplication(2,testaccounts[1].Id,testCarePrograms[1].Id); 
        List<Application__c> testapplications2 = TAP_TestDataFactory.createApplication(2,testaccounts[2].Id,testCarePrograms2[0].Id);
        
        
        // Create payment related to application and care program
       List<Payment__c> testpayments = TAP_TestDataFactory.createPayments(testaccounts[0].Id, testapplications[0].Id, testCarePrograms[0].Id);
       List<Payment__c> testpayments1 = TAP_TestDataFactory.createPayments(testaccounts[1].Id, testapplications1[0].Id, testCarePrograms1[0].Id);
      
    }
   
    @isTest static void updatePaymentStatusTest(){

        Map<Id,Application__c> oldApplicationsMap = new Map<Id,Application__c>();

         //SOQL to get Account
        Account account = [SELECT Id,Payment_Date__c FROM Account WHERE LastName ='Account0'];

        //SOQL to get Care Program
        List<CareProgram> careProgram = [SELECT ID,Payout_Amount__c FROM CareProgram WHERE Name = 'careProgram0'];

        //SOQL to get Application
        List<Application__c> applications = [SELECT ID, Application_Status__c,Care_Program__c FROM Application__c WHERE Patient__c =:account.Id];
        //system.debug('applications :: ' + applications);
        oldApplicationsMap.put(applications[0].Id,applications[0]);
        applications[0].Application_Status__c = TAP_Constants.APPLICATION_STATUS_APPROVED;
        update applications;
        
              

        test.startTest();
        TAP_Payment_Helper.updatePaymentStatus(applications, oldApplicationsMap);
        test.stopTest();
        
      //  List<Payment__c> payments = [Select Id,Application__c,Account__c,Payment_Status__c,Care_Program__c,Amount__c From Payment__c where Application__c =:applications[0].id];
      //  System.assert(payments.size()>0);
      //  system.assertEquals(account.id, payments[0].Account__c);   
    }
    
    // add by sachin
    @isTest static void updatePaymentStatusTest1(){

        Map<Id,Application__c> oldApplicationsMap = new Map<Id,Application__c>();

         //SOQL to get Account
        Account account = [SELECT Id,Payment_Date__c FROM Account WHERE LastName ='Account1'];

        //SOQL to get Care Program
        List<CareProgram> careProgram = [SELECT ID,Payout_Amount__c FROM CareProgram WHERE Name = 'careProgram1'];

        //SOQL to get Application
        List<Application__c> applications = [SELECT ID, Application_Status__c,Care_Program__c FROM Application__c WHERE Patient__c =:account.Id];
       // system.debug('applications :: ' + applications);
        oldApplicationsMap.put(applications[0].Id,applications[0]);
        applications[0].Application_Status__c = TAP_Constants.APPLICATION_STATUS_APPROVED;
        update applications;
        
              

        test.startTest();
        TAP_Payment_Helper.updatePaymentStatus(applications, oldApplicationsMap);
        test.stopTest();
        
        
    }
    
      // add by sachin
    @isTest static void updatePaymentStatusTest2(){

        Map<Id,Application__c> oldApplicationsMap = new Map<Id,Application__c>();

         //SOQL to get Account
        Account account = [SELECT Id,Payment_Date__c FROM Account WHERE LastName ='Account2'];

        //SOQL to get Care Program
        List<CareProgram> careProgram = [SELECT ID,Payout_Amount__c FROM CareProgram WHERE Name = 'careProgram2'];

        //SOQL to get Application
        List<Application__c> applications = [SELECT ID, Application_Status__c,Care_Program__c FROM Application__c WHERE Patient__c =:account.Id];
       // system.debug('applications :: ' + applications);
        oldApplicationsMap.put(applications[0].Id,applications[0]);
        applications[0].Application_Status__c = TAP_Constants.APPLICATION_STATUS_APPROVED;
        update applications;
        
              

        test.startTest();
        TAP_Payment_Helper.updatePaymentStatus(applications, oldApplicationsMap);
        test.stopTest();
        
        
    }
    
   
    
    @isTest static void syncAfterPeoplesoftPaymentUpdateTest(){
        
        //SOQL to get Account
        Account account = [SELECT Id,Payment_Date__c FROM Account WHERE LastName ='Account0' LImit 1];
        
        //SOQL to get Care Program
        List<CareProgram> careProgram = [SELECT ID,Payout_Amount__c FROM CareProgram WHERE Name ='careProgram0' ];
        
        //SOQL to get Application
        List<Application__c> applications = [SELECT ID, Application_Status__c,Care_Program__c FROM Application__c WHERE Patient__c =:account.Id];
        applications[0].Application_Status__c = TAP_Constants.APPLICATION_STATUS_APPROVED;
        update applications;
        
        //SOQL to get Payment
        List<Payment__c> payments = [Select Id,Application__c,Account__c,Supplier_ID__c,Payment_Date__c,Payment_Status__c From Payment__c where Application__c =:applications[0].id];
        payments[0].Supplier_ID__c = TAP_Constants.PAYMENT_SUPPLIER_ID;
        payments[0].Payment_Status__c =TAP_Constants.PAYMENT_STATUS_PAID;
        update payments;
		
		test.startTest();
        TAP_Payment_Helper.syncAfterPeoplesoftPaymentUpdate(payments);
        test.stopTest(); 
        
        Account accounts = [SELECT Id,Payment_Date__c,PeopleSoft_Id__c FROM Account WHERE LastName ='Account0'];
        system.assertEquals(payments[0].Supplier_ID__c, accounts.PeopleSoft_Id__c);   
    }
    
    @isTest static void updateCareProgramsTest(){
        //SOQL to get Account
        Account account = [SELECT Id,Payment_Date__c FROM Account WHERE LastName ='Account0'];
        
        //SOQL to get Care Program
        List<CareProgram> careProgram = [SELECT ID,Payout_Amount__c FROM CareProgram ];
        
        //SOQL to get Application
        List<Application__c> applications = [SELECT ID, Application_Status__c,Care_Program__c FROM Application__c WHERE Patient__c =:account.Id];
        applications[0].Application_Status__c = TAP_Constants.APPLICATION_STATUS_APPROVED;
        update applications;
        
        List<Payment__c> payments = [Select Id,Care_Program__c,Application__c,Supplier_ID__c,Payment_Status__c,Payment_Date__c,Account__c,Amount__c
                                     From Payment__c where Application__c =:applications[0].id];
        
        test.startTest();
        TAP_Payment_Helper.syncAfterPeoplesoftPaymentUpdate(payments);
        test.stopTest(); 
        
        //SOQL to get Care Program
        CareProgram careProgramForMonthlyBalance = [SELECT ID,Payout_Amount__c,Current_Monthly_Payout__c FROM CareProgram 
                                                    WHERE Id =: payments[0].Care_Program__c];
        
        //Asserts for checking payment Amount and Current MonthlyP ayout
        system.assertEquals(payments[0].Amount__c, careProgramForMonthlyBalance.Current_Monthly_Payout__c);
    }
}