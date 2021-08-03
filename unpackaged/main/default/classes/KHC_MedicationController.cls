/**
 * Controller for KHC Medication component
 * 
 * @author Nitin Chandwani, Traction on Demand
 * @date 2020-09-03
 */
public without sharing class KHC_MedicationController {

    private static EhrMedicationStatementSelector medicationStatementSelector = new EhrMedicationStatementSelector();
    
    @AuraEnabled
    public static List<HealthCloudGA__EhrMedicationStatement__c> getMedications(){
        User currUser = MyKomenHealthUtility.getLoggedInUserDetails();
        if( currUser != null ){
            return medicationStatementSelector.selectByPersonAccount( currUser.AccountId );
        }
        return null;
            
    }

    @AuraEnabled
    public static User getLoggedInUserDetails(){
        User currUser = MyKomenHealthUtility.getLoggedInUserDetails();
        if( currUser != null ){
            return currUser;
        }
        return null;
    }
}