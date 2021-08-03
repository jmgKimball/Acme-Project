/****************************************************************************************************************************************************************
* @author IVL Dev
* @date 18-Jul-2020
* @description Handler for Account trigger.
****************************************************************************************************************************************************************/
public class TAP_AccountTrigger_Handler extends TriggerHandler {

    private List<Account> newAccounts;
    private List<Account> oldAccounts;
    private Map<Id,Account> newAccountsMap;
    private Map<Id,Account> oldAccountsMap;
    
    public TAP_AccountTrigger_Handler() {
        newAccounts = Trigger.new;
        if(Trigger.old == null) {
            oldAccounts = new List<Account>();
        } else {
            oldAccounts = Trigger.old;
        }
        newAccountsMap = (Map<Id, Account>) Trigger.newMap;
        if(Trigger.oldMap == null) {
            oldAccountsMap = new Map<Id, Account>();
        } else {
            oldAccountsMap = (Map<Id, Account>) Trigger.oldMap;
        }
    }
    /*********************************************************************************
	*Context Overrides.Overrides the beforeInsert method of TriggerHandler class.
	*Method will be called beforeInsert.
	*********************************************************************************/ 
    public override void beforeInsert() {
        copyApplicantBirthDate();
    }
    /*********************************************************************************
	*Context Overrides.Overrides the beforeUpdate method of TriggerHandler class.
	*Method will be called beforeUpdate.
	*********************************************************************************/ 
    
    public override void beforeUpdate() {
        copyApplicantBirthDate();
    }
    
    /*********************************************************************************
	*Context Overrides.Overrides the afterUpdate method of TriggerHandler class.
	*Method will be called afterUpdate.
	*********************************************************************************/ 
    
    public override void afterUpdate() {
        updatesOnAddressChange();
    }
    
    private void updatesOnAddressChange() {
        List<Account> addressChangeAccounts = new List<Account>();
        for(Account account : newAccounts) {
            if(account.PersonMailingStateCode != oldAccountsMap.get(account.id).PersonMailingStateCode || 
              account.PersonMailingPostalCode != oldAccountsMap.get(account.id).PersonMailingPostalCode || 
              account.PersonMailingCountryCode != oldAccountsMap.get(account.id).PersonMailingCountryCode) {
                addressChangeAccounts.add(account);
            }
        }
        if(addressChangeAccounts.size() > 0) {
            TAP_SuggestedProgramHelper.calculateSuggestedPrograms(addressChangeAccounts);
            TAP_CareProgram_Helper.updatePovertyLevelForApplicant(addressChangeAccounts);
        }
    }
    
    private void copyApplicantBirthDate() {
        for(Account account : newAccounts) {
            if(account.PersonBirthdate <> null){
            	account.Applicant_Birth_Date__c = String.valueOf(account.PersonBirthdate);    
            }
        }
    }
}