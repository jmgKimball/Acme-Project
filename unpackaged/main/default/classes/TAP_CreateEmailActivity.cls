/***************************************************************************************************************************************************************
* @author IVL Dev
* @date 22-May-2020
* @description class is an implementation for Inbound Email Service.
***************************************************************************************************************************************************************/

public without sharing class TAP_CreateEmailActivity implements Messaging.InboundEmailHandler {
    
    /*******************************************************************************************************
    * @description method checks subject line of incoming mail. If it contains application number then 
    * incoming email is stored as EmailMessage on Application
    * @param email  of InboundEmail and envelope of InboundEnvelope
    * @return InboundEmailResult
    ********************************************************************************************************/
    
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        List<Application__c> applications = new List<Application__c>();
        if(String.isNotBlank(email.subject)) {
            Integer index = email.subject.indexOf('#');
            if(index >= 0 ) {
                String applicationName = email.subject.substring(index+1,index+9);
                applications= [SELECT Id, Name FROM Application__c WHERE Name = :applicationName];
                
            }
            
        }
        Id relatedId = null;
        if(applications.size() > 0) {
            relatedId = applications[0].Id;
        } else {
            TAP_Inbox__c inbox = createTAPInbox(email,envelope);
            relatedId = inbox.Id;
        }
        createEmailMessage(email,relatedId);
        return result;
    }
    
      /*******************************************************************************************************
    * @description checks whether Inbound email 
    * @param email  of InboundEmail and relationId of TAPInbox Id
    ********************************************************************************************************/
       
    public static void copyEmailsfromInbox(TAP_Inbox__c inboxRec){
        List <EmailMessage> inboxEmails=[Select htmlBody,TextBody,subject,toAddress,fromAddress,HasAttachment,ccAddress,FromName
                                         From EMailMessage Where relatedToId =:inboxRec.Id];
        if(inboxEmails.size() > 0){
            List <EmailMessage> copiedEmails = new List<EmailMessage>();
            for(EMailMessage inboxEmail : inboxEmails ){
                copiedEmails.add(createEmailMessage (inboxEmail,inboxRec));
            }
            Database.insert(copiedEmails);
            List<ContentDocumentLink> docLinks = [SELECT Id,LinkedEntityId,ContentDocumentId 
                                                FROM ContentDocumentLink Where LinkedEntityId = :inboxRec.Id];
            if(docLinks.size() > 0) {
                List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
                for(EMailMessage inboxEmail : copiedEmails ){
                    contentDocumentLinks.addAll(createAttachment(inboxEmail,inboxRec));
                }
                Database.insert(contentDocumentLinks,false);
            }
        }
    }

    /*******************************************************************************************************
    * @description  Method creates Email message through Inbound email to message
    * @param email  of InboundEmail and relationId to which record it is related to
    ********************************************************************************************************/
    
    public void createEmailMessage(Messaging.InboundEmail email,Id relationId) {
        EMailMessage emailMessage = populateEmailMessage(email);
        if(email.toAddresses != null){
        	emailMessage.toAddress = String.join(email.toAddresses,',');
        }
        if(email.ccAddresses != null) {
            emailMessage.ccAddress = String.join(email.ccAddresses,',');
        }
        emailMessage.relatedToId = relationId;
        emailMessage.MessageDate = System.now();
        Database.insert(emailMessage);
        createAttachment(email,relationId);
    }
    
    /************************************************************************************************
    * @description method returns email message received as inbound email related to the tap inbox 
    * record
    * @param email of EMailMessage and inbox of TAP Inbox 
    * @return new EMailMessage
	*************************************************************************************************/
    public static EMailMessage createEmailMessage(EMailMessage email,TAP_Inbox__c inbox) {
        EMailMessage emailMessage = populateEmailMessage(email);
        emailMessage.toAddress = email.toAddress;
        emailMessage.ccAddress = email.ccAddress;
        emailMessage.relatedToId = inbox.Application__c;
        return emailMessage;
    }

    /************************************************************************************************
    * @description method creates attachment under acontentDocumentLink for email of Tap Inbox record.
    * @param email  of EMailMessage.ContentDocumentId and TAPInboxRec of TAP Inbox
    * @return List of newly populated ContentDocumentLinks
	*************************************************************************************************/
    
    public static List<ContentDocumentLink> createAttachment(EMailMessage email, TAP_Inbox__c inboxRec) {

        List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>();
        if (docLinks.size() > 0) {
          for (ContentDocumentLink docLink : docLinks) {
            ContentDocumentLink contentDocumentLink = createContentLink(docLink.ContentDocumentId,inboxRec.Application__c);
            if(contentDocumentLink != null) {
                docLinks.add(contentDocumentLink);
            }
            contentDocumentLink = createContentLink(docLink.ContentDocumentId,email.Id);
            if(contentDocumentLink != null) {
                docLinks.add(contentDocumentLink);
            }
          }
        }
        return docLinks;
    }

    /*******************************************************************************************************
    * @description method saves attachemt of Inbound email, maintains versions,populate related Id and links
    * with Content DocumentLink
    * @param email  of InboundEmail and relationId of TAPInbox Id
	*********************************************************************************************************/
    
    public void createAttachment(Messaging.InboundEmail email, Id relatedId) {
        if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
            List<ContentVersion> contentVersions = new List<ContentVersion>();
            for (integer i = 0 ; i < email.binaryAttachments.size() ; i++) {
                ContentVersion contentVersion = createContentVersion(email.binaryAttachments[i].body,
                                                                        email.binaryAttachments[i].filename);
                
                if(contentVersion != null) {
                    contentVersions.add(contentVersion);
                }
            }
            Database.insert(contentVersions,false);
            List<ContentDocumentLink> contentDocLinks = new List<ContentDocumentLink>();
            for(ContentVersion contentVersion : contentVersions) {
                ContentDocumentLink contentDocLink = createContentLink(contentVersion,relatedId);
                if(contentDocLink != null) {
                    contentDocLinks.add(contentDocLink);
                }
            }
            Database.insert(contentDocLinks,false);
        }
    }
    
    /************************************************************************************************
    * @description checks whether Inbound email 
    * @param inputBlob  of Blob and filename  
	*************************************************************************************************/
    
    public static ContentVersion createContentVersion(Blob inputBlob,String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = inputBlob;
        cv.Title = filename;
        cv.PathOnClient = filename;
        try {
            return cv;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    
    /************************************************************************************************
    * @description method returns Content Document Version and Id
    * @param contentVersion  of ContentVersion and recordId of contentVersion.ContentDocumentId  
	*************************************************************************************************/
    
    public static ContentDocumentLink createContentLink(ContentVersion contentVersion, String recordId) {
        String contentVersionId = contentVersion.Id;
        if (contentVersionId == null || recordId == null) { 
            return null; 
        }
        Id contentDocId = [SELECT ContentDocumentId 
                            FROM ContentVersion 
                            WHERE Id =: contentVersionId
                            ].ContentDocumentId;

        return createContentLink(contentDocId,recordId);
      }
    
    
    /************************************************************************************************
    * @description method handles exception while creating Contentdocument Link.
    * @param contentDocId  of contentVersion.ContentDocumentId and recordId of TAP Inbox Id 
	*************************************************************************************************/
    
    public static ContentDocumentLink createContentLink(String contentDocId, String recordId) {
        if (contentDocId == null || recordId == null) { 
            return null; 
        }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = contentDocId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';
        try {
          return cdl;
        } catch(DMLException e) {
          System.debug(e);
          return null;
        }
    }

    private static EMailMessage populateEmailMessage(Messaging.InboundEmail inboundEmail) {
        return populateEmailMessage(inboundEmail,null);
    }

    private static EMailMessage populateEmailMessage(EMailMessage email) {
        return populateEmailMessage(null,email);
    }

    private static EMailMessage populateEmailMessage(Messaging.InboundEmail inboundEmail,EMailMessage email) {
        EMailMessage emailMessage = new EMailMessage();
        if(inboundEmail != null) {
            emailMessage.htmlBody = inboundEmail.htmlBody;
            emailMessage.TextBody = inboundEmail.plainTextBody;
            emailMessage.subject = inboundEmail.subject;
            emailMessage.fromAddress = inboundEmail.fromAddress;
            emailMessage.fromName = inboundEmail.FromName;
        } else {
            emailMessage.htmlBody = email.htmlBody;
            emailMessage.TextBody = email.TextBody;
            emailMessage.subject = email.subject;
            emailMessage.fromAddress = email.fromAddress;
            emailMessage.fromName = email.FromName;
        }
        emailMessage.Status = '3';
        emailMessage.Incoming = true;
        return emailMessage;
    }
    
    private TAP_Inbox__c createTAPInbox(Messaging.InboundEmail email,Messaging.InboundEnvelope envelope) {
        TAP_Inbox__c kEmail = new TAP_Inbox__c();
        kEmail.First_Name__c = email.fromname.substring(0,email.fromname.indexOf(' '));
        kEmail.Last_Name__c = email.fromname.substring(email.fromname.indexOf(' '));
        kEmail.From_Email__c = envelope.fromAddress;
        kEmail.Email_Body__c = email.htmlBody;
        kEmail.Subject__c  = email.subject;
        kEmail.Status__c  = TAP_Constants.TAP_INBOX_STATUS_PENDING;
        insert kEmail;
        return kEmail;
    }
}