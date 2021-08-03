/****************************************************************************************************************************************************************
* @author IVL Dev
* @date  17-June-2020,
* @description class to send email based on application status.
****************************************************************************************************************************************************************/

public without sharing class TAP_EmailUtility {
    
    /**********************************************************************************************************************************************************
    * @description send email as per the status of Application and email send in English or Spanish languages depend upon Preferred Language of Patient
    * @param  List of emailRequests  of EmailRequest wrapper class
    ***********************************************************************************************************************************************************/
    
    @InvocableMethod
    public static void sendEmail(List<EmailRequest> emailRequests){
        Map<Id,String> applicationTemplateMap = new Map<Id,String>();
        List<String> templateNames = new List<String>();
        OrgWideEmailAddress ordWideId = [SELECT  Id  FROM OrgWideEmailAddress where Address='treatmentassistance@komen.org'];
        for(EmailRequest emailRequest: emailRequests) {
            applicationTemplateMap.put(emailRequest.appId, emailRequest.emailTemplateName);
            templateNames.add(emailRequest.emailTemplateName);
            templateNames.add(emailRequest.emailTemplateName + '_Spanish');
        }
        List<Application__c> applications = [Select Id,Application_Status__c,Patient__c,
                                             Patient__r.PersonEmail,Patient__r.Name,
                                             Patient__r.Preferred_Language__c,
                                             Patient__r.personContactId
                                             From application__c Where Id IN :applicationTemplateMap.keySet()];
        List<EmailTemplate> templates = [SELECT Id,DeveloperName,Body,HtmlValue from EmailTemplate WHERE DeveloperName IN :templateNames];
        Map<String,Id> templateMap = new Map<String,Id>();
        for(EmailTemplate template : templates) {
            templateMap.put(template.DeveloperName, template.Id);
        }
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        for(Application__c application: applications) {
            if(application.Patient__c != null && application.Patient__r.personContactId != null){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTargetObjectId(application.Patient__r.personContactId);
                message.setSaveAsActivity(true);
                if(application.Patient__r.Preferred_Language__c == 'Spanish' 
                   && templateMap.get(applicationTemplateMap.get(application.Id) +'_Spanish') != null) {
                       message.setTemplateID(templateMap.get(applicationTemplateMap.get(application.Id) +'_Spanish'));
                   }else {
                       message.setTemplateID(templateMap.get(applicationTemplateMap.get(application.Id)));
                   }
                message.setWhatId(application.Id);
                
                message.setOrgWideEmailAddressId(ordWideId.Id);
                messages.add(message);
            }
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        }
    }
    
    /*******************************************************************************************************
    * @description Wrapper class created for sending different parameter to class
    * @ (@invocableVariable) annotation to identify variables used by invocable methods in custom classes
    ********************************************************************************************************/
    
    public class EmailRequest {
        @InvocableVariable(Label = 'Application Id' Required = true)
        public String appId;
        
        @InvocableVariable(Label = 'Email Template Unique Name' Required = true)
        public String emailTemplateName;
    }
}