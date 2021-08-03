@isTest
public class TAP_CreateEmailActivity_Test {
    @testSetup static void setup() {
        //Create common test accounts
       List<Account> testaccounts = TAP_TestDataFactory.createAccount(2,'Account');  
        // Create common test care Program
        List<CareProgram> testCarePrograms = TAP_TestDataFactory.createCareProgram(2,'careProgram');
        // Create common test application
        List<Application__c> testapplications = TAP_TestDataFactory.createApplication(1,testaccounts[0].Id,testCarePrograms[0].Id);
        //create common test TAP Inbox
        List<TAP_Inbox__c> tapInboxs = TAP_TestDataFactory.createtapInbox(1,testapplications[0].Id,'TAP Inbox');
        //create common test EmailMessage
        EmailMessage inboxEmail = TAP_TestDataFactory.createEmailMessage(tapInboxs[0].Id);
        // Create common test User
        List<User> testUser = TAP_TestDataFactory.createUser();
    }
    
    @isTest static void handleInboundEmailTest(){
        Id relatedId = null;
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        List<Account> accounts = [SELECT Id,Payment_Date__c,PersonEmail FROM Account WHERE LastName ='Account0'];
        //get the  test account by using a SOQL query
        CareProgram careProgram = [SELECT ID FROM CareProgram WHERE Name='careProgram0' LIMIT 1];
        //get the  test account by using a SOQL query
        List<Application__c> application = [SELECT ID,Name FROM Application__c WHERE Patient__c =:accounts[0].id];
        
        email.subject = '#'+application[0].Name;
        email.fromAddress = TAP_Constants.EMAIL_FROM_ADDRESS;
        email.plainTextBody = TAP_Constants.EMAIL_TEXT_BODY;
        
        test.startTest();
        TAP_CreateEmailActivity emailActivity= new TAP_CreateEmailActivity();
        emailActivity.handleInboundEmail(email, envelope);
        test.stopTest();
        
        Messaging.InboundEmailResult result = emailActivity.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);
    }
    
    @isTest static void copyEmailsfromInboxTest(){
        // get the  test account by using a SOQL query
        List<Account> accounts = [SELECT Id,Payment_Date__c,PersonEmail FROM Account WHERE LastName ='Account0'];
        //get the  test Care Program by using a SOQL query
        CareProgram careProgram = [SELECT ID FROM CareProgram WHERE Name='careProgram0'];
        //get the  test Application by using a SOQL query
        List<Application__c> application = [SELECT ID,Name FROM Application__c WHERE Patient__c =:accounts[0].id];
        //get the  test TAP Inbox by using a SOQL query
        TAP_Inbox__c tapInbox = [SELECT ID,Name,Application__c FROM TAP_Inbox__c WHERE Application__c =:application[0].Id];
       // get the  test Application by using a SOQL query
       
        EmailMessage inboxEmail =[SELECT htmlBody,TextBody,subject,toAddress,fromAddress,ccAddress,
                                  FromName FROM EmailMessage WHERE relatedToId =:tapInbox.Id];
        
        
        ContentVersion contentVersion=new Contentversion();
        contentVersion.title='ABC';
        contentVersion.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        contentVersion.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert contentVersion;
        
        ContentVersion testContentVersion = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :contentVersion.Id];
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(ContentDocumentId=testContentVersion.ContentDocumentId,LinkedEntityId =tapInbox.Id);
        insert contentDocumentLink;
        
        test.startTest();
        TAP_CreateEmailActivity.copyEmailsfromInbox(tapInbox);
        test.stopTest();
        
        List<ContentDocumentLink> docLinks = [SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink Where LinkedEntityId = :tapInbox.Id];
        system.assert(docLinks.size()>0);
    }
    
    @isTest static void createEmailMessageTest(){
        List<Account> accounts = [SELECT Id,Payment_Date__c,PersonEmail FROM Account WHERE LastName ='Account0'];
        List<Application__c> application = [SELECT ID,Name FROM Application__c WHERE Patient__c =:accounts[0].id];
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = TAP_Constants.EMAIL_SUBJECT;
        email.plainTextBody = TAP_Constants.EMAIL_TEXT_BODY;
        email.fromAddress = TAP_Constants.EMAIL_FROM_ADDRESS;
        
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
   
        TAP_CreateEmailActivity emailActivity= new TAP_CreateEmailActivity();
        emailActivity.createEmailMessage(email,application[0].Id);
        
        List<ContentDocumentLink> docLinks = [SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink Where LinkedEntityId = :application[0].Id];
        system.assert(docLinks.size()>0);
        
    }
    @isTest static void createEmailMessageWithInboxIdTest(){
        //get the  test account by using a SOQL query
        List<Account> accounts = [SELECT Id,Payment_Date__c,PersonEmail FROM Account WHERE LastName ='Account0'];
        //get the  test application by using a SOQL query
        List<Application__c> application = [SELECT ID,Name FROM Application__c WHERE Patient__c =:accounts[0].id];
        //get the  test TAP Inbox by using a SOQL query
        TAP_Inbox__c tapInboxs = [SELECT Id,Application__c FROM TAP_Inbox__c WHERE Last_Name__c ='TAP Inbox0'];
        //get the  test EmailMessage by using a SOQL query
        EmailMessage inboxEmail = [SELECT Id,HtmlBody,TextBody,Subject,toAddress,ccAddress,FromName,
                                   FromAddress,relatedToId FROM EmailMessage WHERE relatedToId =:tapInboxs.Id];
        
        test.startTest();
        TAP_CreateEmailActivity.createEmailMessage(inboxEmail,tapInboxs);
        test.stopTest();
        system.assert(true);
        List<EmailMessage> emailMessages = [Select Id,relatedToId,HtmlBody from EmailMessage Where relatedToId =: application[0].Id];
        system.assertEquals(tapInboxs.Application__c,emailMessages[0].relatedToId);
    }

   @isTest static void handleInboundEmailforTapInboxTest(){
        Id relatedId = null;
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        envelope.fromAddress =TAP_Constants.EMAIL_FROM_ADDRESS; 
        email.fromName =TAP_Constants.EMAIL_FROM_NAME;
        email.subject = TAP_Constants.EMAIL_SUBJECT;
        email.fromAddress = 'asf@gmail.com';
        email.htmlBody =TAP_Constants.EMAIL_HTML_BODY;
        email.plainTextBody = TAP_Constants.EMAIL_TEXT_BODY;
        
        TAP_CreateEmailActivity emailActivity= new TAP_CreateEmailActivity();
        emailActivity.handleInboundEmail(email, envelope);
        
        Messaging.InboundEmailResult result = emailActivity.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true); 
    }
}