@isTest
public class TAP_TAPInboxTrigger_Handler_Test {
    
     @testSetup static void setup() {
         //Create common test accounts
         List<Account> testaccounts = TAP_TestDataFactory.createAccount(2,'Account'); 
         // Create common test care Program
         List<CareProgram> testCarePrograms = TAP_TestDataFactory.createCareProgram(2,'careProgram');
         // Create common test application
         List<Application__c> testapplications = TAP_TestDataFactory.createApplication(1,testaccounts[0].Id,testCarePrograms[0].Id);
         List<Application__c> testapplications1 = TAP_TestDataFactory.createApplication(1,testaccounts[1].Id,testCarePrograms[1].Id);
       
         system.debug('test application id :: ' + testapplications[0].id);
        // Create common Inbox records
         List<TAP_Inbox__c> testInboxes = new List<TAP_Inbox__c>();
         for(Integer i=0;i<1;i++) {
             testInboxes.add(new TAP_Inbox__c(First_Name__c = 'User'+i, Last_Name__c = 'LName' + i, Subject__c =  'New Application Request', Status__c = 'Pending', Application__c = testapplications[0].id));
         }
         insert testInboxes;   
         
         system.debug('textInboxes :: ' + testInboxes);
         
         List<TAP_Inbox__c> testInboxes1 = new List<TAP_Inbox__c>();
         for(Integer i=0;i<1;i++) {
             testInboxes1.add(new TAP_Inbox__c(First_Name__c = 'UFN'+i, Last_Name__c = 'ULN' + i, Subject__c =  'New Application Request', Status__c = 'Pending'));
         }
         insert testInboxes1; 
         
                
       
    }
    
    @isTest
    static void TestMethod1(){
        TAP_Inbox__c objTI = [SELECT Id, First_Name__c, Last_Name__c, Subject__c, Email_Body__c, From_Email__c, Status__c, Application__c FROM TAP_Inbox__c where First_Name__c ='User0']; 
        system.assertEquals(objTI.First_Name__c,'User0');
        system.assertEquals(objTI.Status__c,'Pending');
        objTI.Subject__c = 'New App Request';
        objTI.Status__c = TAP_Constants.TAP_INBOX_STATUS_PENDING;
        update objTI;
    }
    
     @isTest
    static void TestMethod2(){
        Account objAc = [select Id from Account where LastName = 'Account1'];
        Application__c objApp = [select id from Application__c where Patient__c =: objAc.Id];
        TAP_Inbox__c objTI = [SELECT Id, First_Name__c, Last_Name__c, Subject__c, Email_Body__c, From_Email__c, Status__c, Application__c FROM TAP_Inbox__c where First_Name__c ='UFN0']; 
        system.assertEquals(objTI.First_Name__c,'UFN0');
        system.assertEquals(objTI.Status__c,'Pending');
        objTI.Subject__c = 'New App Request';
        objTI.Status__c = TAP_Constants.TAP_INBOX_STATUS_PENDING;
        objTI.Application__c = objApp.Id;
        update objTI;
    }

}