@istest
public class TAP_EmailUtility_Test {
     @testSetup static void setup() {
        //Create common test accounts
        List<Account> testaccounts = TAP_TestDataFactory.createAccount(2,'Account');  
        // Create common test care Program
        List<CareProgram> testCarePrograms = TAP_TestDataFactory.createCareProgram(2,'careProgram');
        // Create common test application
        List<Application__c> testapplications = TAP_TestDataFactory.createApplication(1,testaccounts[0].Id,testCarePrograms[0].Id);
        // Create common test User
        List<User> testUser = TAP_TestDataFactory.createUser();
    }
    
    
    @isTest static void testInvocableClass(){
        Test.startTest();
        //get the  test account by using a SOQL query
        List<Account> accounts = [SELECT Id,Payment_Date__c,PersonEmail FROM Account WHERE LastName = 'Account0'];

        //get the  test account by using a SOQL query
        CareProgram careProgram = [SELECT ID FROM CareProgram WHERE Name='careProgram0' LIMIT 1];
        //get the  test account by using a SOQL query
        List<Application__c> application = [SELECT ID FROM Application__c WHERE Patient__c =:accounts[0].id];
        
        //SOQL query to get EmailTemplate
        EmailTemplate templates = [SELECT Id,DeveloperName,Body,HtmlValue from EmailTemplate Where DeveloperName ='Application_Rejected'];
       
        List<TAP_EmailUtility.EmailRequest> listOfRequestedValue = new List<TAP_EmailUtility.EmailRequest>();
        TAP_EmailUtility.EmailRequest request = new TAP_EmailUtility.EmailRequest();
        request.appId = application[0].Id;
        request.emailTemplateName = templates.DeveloperName;
        listOfRequestedValue.add(request);
        TAP_EmailUtility.sendEmail(listOfRequestedValue);
        Test.stopTest();
        //SOQL query to get EmailMessage
        List<EmailMessage> emailMessages = [Select Id from EmailMessage Where emailTemplateId =: templates.Id];
        // Assert to check size of email
        system.assert(emailMessages.size()>0);
    }
}