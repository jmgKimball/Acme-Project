/****************************************************************************************************************************************************************
* @author IVL Dev
* @date 12-May-2020
* @description Handler is for Application Trigger
****************************************************************************************************************************************************************/
public class TAP_ApplicationTrigger_Handler extends TriggerHandler {
    
    private List<Application__c> newApplications;
    private List<Application__c> oldApplications;
    private Map<Id,Application__c> newApplicationsMap;
    private Map<Id,Application__c> oldApplicationsMap;
    
    public TAP_ApplicationTrigger_Handler() {
        newApplications = Trigger.new;
        if(Trigger.old == null) {
            oldApplications = new List<Application__c>();
        } else {
            oldApplications = Trigger.old;
        }
        newApplicationsMap = (Map<Id, Application__c>) Trigger.newMap;
        if(Trigger.oldMap == null) {
            oldApplicationsMap = new Map<Id, Application__c>();
        } else {
            oldApplicationsMap = (Map<Id, Application__c>) Trigger.oldMap;
        }
    }
    
   /*********************************************************************************
	*Context Overrides.Overrides the beforeInsert method of TriggerHandler class.
	*Methods from Application Helper will be called beforeInsert.
	*********************************************************************************/ 
    public override void beforeInsert() {
        updateApplicationStatusDuration();
        calculateIncomeBasedAttributes();
        TAP_Application_Helper.copyEmailIdFromAccount(newApplications,oldApplicationsMap);
    }
    
    /*********************************************************************************
    *Context Overrides.Overrides the before update method of TriggerHandler class.
	*Methods from Application Helper will be called  before Update.
    *********************************************************************************/	 
    
    public override void beforeUpdate() {
        updateApplicationStatusDuration();
        calculateIncomeBasedAttributes();
        TAP_Application_Helper.copyEmailIdFromAccount(newApplications,oldApplicationsMap);
    }
   /*********************************************************************************
    *Context Overrides.Overrides the afterInsert method of TriggerHandler class.
	*Methods from Application Helper will be called after Insert.
    *********************************************************************************/
    
    public override void afterInsert() {
        TAP_SuggestedProgramHelper.calculateSuggestedPrograms(new List<Id>(newApplicationsMap.keySet()));
      
    }
    
   /*********************************************************************************
    *Context Overrides.Overrides the afterUpdate method of TriggerHandler class.
	*Methods from Application Helper will be called after Update.
    *********************************************************************************/    
    
    public override void afterUpdate() {
        TAP_SuggestedProgramHelper.calculateSuggestedPrograms(new List<Id>(newApplicationsMap.keySet()));
        TAP_Payment_Helper.updatePaymentStatus(newApplications,oldApplicationsMap);
        deleteSuggestedCarePrograms();
    }
    
 
    
    
    private void deleteSuggestedCarePrograms() {
        List<Application__c> approvedApplications = new List<Application__c>();
        for(Application__c application : newApplications) {
            if(application.Application_Status__c != oldApplicationsMap.get(application.Id).Application_Status__c) {
                if(application.Application_Status__c == TAP_Constants.APPLICATION_STATUS_APPROVED 
                   && oldApplicationsMap.get(application.Id).Application_Status__c != TAP_Constants.APPLICATION_STATUS_APPROVED) {
                    approvedApplications.add(application);
                }
            }
        }
        
        if (approvedApplications.size() > 0) {
            TAP_SuggestedProgramHelper.deleteSuggestedCarePrograms(approvedApplications);  
        }
    }
    
    private void calculateIncomeBasedAttributes(){
        for(Application__c application : newApplications){
            if(oldApplicationsMap.size() > 0) {
                Application__c oldApplication = oldApplicationsMap.get(application.Id);
                if (application.Total_annual_Household_Income__c != oldApplication.Total_annual_Household_Income__c
                    || application.No_of_People_in_the_Household__c != oldApplication.No_of_People_in_the_Household__c 
                    || application.Care_Program__c != oldApplication.Care_Program__c) {
                        application.Poverty_Level__c = TAP_CareProgram_Helper.calculatePovertyLevelForApplication(application);
                        TAP_Application_Helper.updateIncomeGuidelinesCheck(newApplications);
                    }
            } else {
                application.Poverty_Level__c = TAP_CareProgram_Helper.calculatePovertyLevelForApplication(application);
                TAP_Application_Helper.updateIncomeGuidelinesCheck(newApplications);
            }
        }
    }
    
    private void updateApplicationStatusDuration() {
        for(Application__c application : newApplications){
            if(oldApplicationsMap != null && oldApplicationsMap.get(application.Id) != null) {
                TAP_Application_Helper.calculateStatusDuration(application,oldApplicationsMap.get(application.Id).Application_Status__c);
            } else {
                TAP_Application_Helper.setStatusChangeDate(application);
            }
        }
    }
    
}