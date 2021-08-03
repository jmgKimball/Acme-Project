/* * Controller class for Immunization( My Immunizations ) Component
 *
 * @author Nitin Chandwani, Traction on Demand
 * @date 2020-10-01
 */
public with sharing class KHC_ImmunizationsController {

    private static ImmunizationSelector immunizationSelector = new ImmunizationSelector();

    @AuraEnabled
    public static List<HealthCloudGA__EhrImmunization__c> getImmunizations(){
        User currUser = MyKomenHealthUtility.getLoggedInUserDetails();
        if( currUser != null ){
            return immunizationSelector.getImmunizationsByAccountId( currUser.AccountId );
        }
        return null;
    }

}