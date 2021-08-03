/****************************************************************************************************************************************************************
* @author IVL Dev
* @date 18-July-2020
* @description Helper of Payment Trigger Handler.
****************************************************************************************************************************************************************/
public without sharing class TAP_Payment_Helper {

    /***********************************************************************************************
    * @description create or update payment information
    * @param List<Application__c> applications of Application  
    * @param Map<Id,Application__c> oldApplicationsMap of Application
    ************************************************************************************************/
    public static void updatePaymentStatus(List<Application__c> applications,Map<Id,Application__c> oldApplicationsMap){
       
        List<Payment__c> upsertPayments = new List<Payment__C>();
        List<Application__c> applicationList = [SELECT ID,Care_Program__c,Care_Program__r.Payout_Amount__c,Application_Status__c,Patient__c,
                                                (SELECT id, Amount__c, Care_Program__c,Payment_Status__c FROM Payments__r) 
                                                FROM Application__c WHERE ID in :applications];
       // system.debug('applicationlist :: ' + applicationList);
        for (Application__c application : applicationList){
           //  system.debug('application id :: ' + application.Id);
            Application__c oldApplication =oldApplicationsMap.get(application.Id);
           // system.debug('oldApplication :: ' + oldApplication);
           // if condition to check oldApplication is not null is added by Sachin
          
            if(oldApplication != null){
                if ((application.Application_Status__c != oldApplication.Application_Status__c || application.Care_Program__c != oldApplication.Care_Program__c) && application.Application_Status__c == TAP_Constants.APPLICATION_STATUS_APPROVED){
                    
                    if(application.Payments__r != null && application.Payments__r.size() > 0){
                        upsertPayments.add(populatePayment(application.Payments__r.get(0),application,
                                                           application.Care_Program__r.Payout_Amount__c));
                    }else{
                        Payment__c payment = populatePayment(new Payment__c(),application,
                                                             application.Care_Program__r.Payout_Amount__c);
                        upsertPayments.add(payment);   
                    }
                }  
            }
        }
        if(upsertPayments.size() > 0) {
            Database.upsert(upsertPayments, false);
        }
    }
    
    /***********************************************************************************************
    * @description method to replicate the info after Peoplesoft updates Payments details
    * @param List<Payment__c> payments of Payment      
    ************************************************************************************************/
    
    public static void syncAfterPeoplesoftPaymentUpdate(List<Payment__c> payments) {
        
        List<Account> accounts = new List<Account>();
        List<Application__c> applications = new List<Application__c>();
        for(Payment__c payment : payments) {
            if(payment.Supplier_ID__c != null) {
                Account account = new Account(id=payment.Account__c);
                account.PeopleSoft_Id__c = payment.Supplier_ID__c;
                if(payment.Payment_Status__c == TAP_Constants.PAYMENT_STATUS_PAID) {
                	account.Payment_Date__c = payment.Payment_Date__c;
            	}
                accounts.add(account);
            }
            applications.add(new Application__c(id = payment.Application__c, Payment_Status__c = payment.Payment_Status__c,
                                                           Payment_Date__c = payment.Payment_Date__c));
        }
        if(accounts.size() > 0) {
            Database.update(accounts,false);
        }
        if(applications.size() > 0) {
            Database.update(applications,false);
        }
    }
    /***********************************************************************************************
	* @description method to replicate Amount of payment object on  Current Monthly Payout  of 
	* careProgram object
    * @param payments list of Payments    
    ************************************************************************************************/
     
    public static void updateCarePrograms(List<Payment__c> payments) {
        List<Id> careProgramIds = new List<Id>();
        Map<Id, CareProgram> careProgramsMap = new Map<Id, CareProgram>();
        for(Payment__c payment : payments) {
            careProgramIds.add(payment.Care_Program__c);
        }
        
        careProgramsMap = new Map<Id, CareProgram>([SELECT Id, Current_Monthly_Payout__c FROM CareProgram WHERE Id in :careProgramIds]);
        
        for(Payment__c payment : payments) {
            CareProgram careProgram = careProgramsMap.get(payment.Care_Program__c);
            if(careProgram.Current_Monthly_Payout__c <> null && payment.Amount__c <> null){
                careProgram.Current_Monthly_Payout__c = careProgram.Current_Monthly_Payout__c + payment.Amount__c;    
            }else{
                if(payment.Amount__c <> null){
                	careProgram.Current_Monthly_Payout__c =  payment.Amount__c;    
                }
            }
        }

        if(careProgramsMap.size() > 0) {
            Database.update(careProgramsMap.values(), false);
        }
    }

    private static Payment__c populatePayment(Payment__c payment,Application__c application,Decimal amount) {
        payment.Application__c = application.Id;
        payment.Account__c = application.Patient__c;
        payment.Payment_Status__c = TAP_Constants.PAYMENT_STATUS_PENDING;
        payment.Care_Program__c = application.Care_Program__c;
        payment.Amount__c = amount;
        return payment;
    }
}