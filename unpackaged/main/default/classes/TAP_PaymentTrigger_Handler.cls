/****************************************************************************************************************************************************************
* @author IVL Dev
* @date 13-May-2020
* @description Handler for Payment trigger
****************************************************************************************************************************************************************/
public class TAP_PaymentTrigger_Handler extends TriggerHandler {
    
    private List<Payment__c> newPayments;
    private List<Payment__c> oldPayments;
    private Map<Id,Payment__c> newPaymentsMap;
    private Map<Id,Payment__c> oldPaymentsMap;
    
    public TAP_PaymentTrigger_Handler() {
        newPayments = Trigger.new;
        if(Trigger.old == null) {
            oldPayments = new List<Payment__c>();
        } else {
            oldPayments = Trigger.old;
        }
        newPaymentsMap = (Map<Id, Payment__c>) Trigger.newMap;
        if(Trigger.oldMap == null) {
            oldPaymentsMap = new Map<Id, Payment__c>();
        } else {
            oldPaymentsMap = (Map<Id, Payment__c>) Trigger.oldMap;
        }
    }
    
    /***********************************************************************************************
    *Context Overrides.Overrides the afterInsert method of TriggerHandler class
	*Method will be called afterInsert
    ************************************************************************************************/
    public override void afterInsert() {
        TAP_Payment_Helper.updateCarePrograms(newPayments);
    }
    /***********************************************************************************************
    *Context Overrides.Overrides the afterUpdate method of TriggerHandler class
	*Method will be called afterUpdate
    ************************************************************************************************/
    
    public override void afterUpdate() {
        syncAfterPeoplesoftUpdate();
    }

	/***********************************************************************************************
    * @description method to replicate supplier id of payment object on  PeopleSoft id 
    * of Account object 
	************************************************************************************************/    
    
    private void syncAfterPeoplesoftUpdate() {
        List<Payment__c> statusUpdatedPayments = new List<Payment__c>();
        for(Payment__c payment : newPayments){
            Payment__c oldPayment = oldPaymentsMap.get(payment.Id);
            if(payment.Payment_Status__c != oldPayment.Payment_Status__c) {
                statusUpdatedPayments.add(payment);
            }
        }
        TAP_Payment_Helper.syncAfterPeoplesoftPaymentUpdate(statusUpdatedPayments);
    }
}