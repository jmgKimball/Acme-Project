@isTest
public class TAP_PaymentTrigger_Handler_Test {
    @testSetup static void setup() {
        
        // Create common test User
        List<User> testUser = TAP_TestDataFactory.createUser();
        
        //Create common test accounts
        List<Account> testaccounts = TAP_TestDataFactory.createAccount(2,'Account'); 
        
        // Create common test Care Programs
        List<CareProgram> testCarePrograms = TAP_TestDataFactory.createCareProgram(2,'careProgram');
        
        // Create common test applications
        List<Application__c> testapplications = TAP_TestDataFactory.createApplication(1,testaccounts[0].Id,testCarePrograms[0].Id);   
    }
    
    @isTest static void creatPaymentTest(){
        // List<User> userList =[Select Id,Name FROM User WHERE Alias =:TAP_Constants.MISSION_ALIAS];
        //system.debug('@@user'+userList);
        test.startTest();
        //SOQL to get Account
        Account account = [SELECT Id,Payment_Date__c FROM Account WHERE LastName ='Account0'];
        
        //SOQL to get Care Program
        List<CareProgram> careProgram = [SELECT ID,Payout_Amount__c FROM CareProgram WHERE Name='careProgram0'];
        
        //SOQL to get Application
        Application__c application = [SELECT ID, Application_Status__c,Care_Program__c FROM Application__c WHERE Patient__c =:account.Id];
        application.Application_Status__c = TAP_Constants.APPLICATION_STATUS_APPROVED;
        update application;
        
        List<Payment__c> payments = [Select Id,Application__c,Account__c,Supplier_ID__c,Payment_Date__c,Payment_Status__c From Payment__c where Application__c =:application.id];
        System.assert(payments.size()>0);
        system.assertEquals(account.id, payments[0].Account__c);
        
        Payment__c payment  = [SELECT Id,Application__c,Supplier_ID__c,Payment_Date__c,Payment_Status__c From Payment__c where Id =:payments[0].id];
        payment.Payment_Date__c = date.newInstance(2020, 07, 22);
        payment.Supplier_ID__c = TAP_Constants.PAYMENT_SUPPLIER_ID;
        payment.Payment_Status__c =TAP_Constants.PAYMENT_STATUS_PAID;
        update payment;
        
        Account accounts = [SELECT Id,Payment_Date__c,PeopleSoft_Id__c FROM Account WHERE LastName ='Account0' LImit 1];
        system.assertEquals(payment.Supplier_ID__c, accounts.PeopleSoft_Id__c);
        test.stopTest();
    }
}