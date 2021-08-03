/***************************************************************************************************************************************************************
* @author IVL Dev
* @date 18-July-2020
* @description Trigger is for Application object
***************************************************************************************************************************************************************/
trigger ApplicationTrigger on Application__c (before insert,before update,after insert,after update) {
    
    new TAP_ApplicationTrigger_Handler().run();
}