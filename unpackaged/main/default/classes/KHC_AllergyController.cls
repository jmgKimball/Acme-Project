/* * Controller class for AllergyIntolerance( My Allergies ) Component
 *
 * @author Vikrant Upneja, Traction on Demand
 * @date 2021-01-15
 */
public with sharing class KHC_AllergyController {

    private static AllergyIntoleranceSelector allergyIntoleranceSelector = new AllergyIntoleranceSelector();

    @AuraEnabled
    public static List<HealthCloudGA__EhrAllergyIntolerance__c> getAllergies(){
        User currUser = MyKomenHealthUtility.getLoggedInUserDetails();
        if( currUser != null ){
            return allergyIntoleranceSelector.selectAllergiesIntolerancesByAccId( currUser.AccountId );
        }
        return null;
    }
}