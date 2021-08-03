/***************************************************************************************************************************************************************
* @author IVL Dev
* @date 21-July-2020
* @description 
***************************************************************************************************************************************************************/
public class TAP_TAPInboxTrigger_Handler extends TriggerHandler {

    private List<TAP_Inbox__c> newInboxes;
    private Map<Id,TAP_Inbox__c> oldInboxesMap;
    
    public TAP_TAPInboxTrigger_Handler() {
        newInboxes = Trigger.new;
        system.debug('newInboxes :: ' + newInboxes);
        system.debug('Trigger.oldMap :: ' + Trigger.oldMap);
        if(Trigger.oldMap == null) {
            oldInboxesMap = new Map<Id, TAP_Inbox__c>();
            system.debug('oldInboxesMapOLDNULL :: ' + oldInboxesMap);
        } else {
            oldInboxesMap = (Map<Id, TAP_Inbox__c>) Trigger.oldMap;
            system.debug('oldInboxesMapOLDNOTNULL :: ' + oldInboxesMap);
        }
      
    }
    
    /***********************************************************************************************
    *Context Overrides.Overrides the beforeUpdate method of TriggerHandler class
	*Method will be called beforeUpdate
    ************************************************************************************************/
    
    public override void beforeUpdate() {
        updateStatus();
    }
    
    /***********************************************************************************************
    *Context Overrides.Overrides the afterUpdate method of TriggerHandler class
	*Method will be called afterUpdate
    ************************************************************************************************/
    
    public override void afterUpdate() {
        copyContentToApplication();
    }
    
    private void updateStatus() {
        for(TAP_Inbox__c inbox : newInboxes) {
            if(inbox.Application__c != null && inbox.Application__c != oldInboxesMap.get(inbox.Id).Application__c 
               && inbox.Status__c == TAP_Constants.TAP_INBOX_STATUS_PENDING) {
                inbox.Status__c = TAP_Constants.TAP_INBOX_STATUS_PROCESSED;
            }
        }
    }
    
    private void copyContentToApplication() {
        for(TAP_Inbox__c inbox : newInboxes) {
            if(inbox.Application__c != null && inbox.Application__c != oldInboxesMap.get(inbox.Id).Application__c) {
                TAP_CreateEmailActivity.copyEmailsfromInbox(inbox);
            }
        }
    }
}