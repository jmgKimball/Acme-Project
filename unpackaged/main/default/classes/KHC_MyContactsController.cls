/* * Controller class for My Contacts Component
 *
 * @author Nitin Chandwani, Traction on Demand
 * @date 2021-01-04
 */
public with sharing class KHC_MyContactsController {
    
    private static ContactContactRelationSelector contactContactRelationSelector = new ContactContactRelationSelector();
    private static ReciprocalRoleSelector reciprocalRoleSelector = new ReciprocalRoleSelector();
    public static final Set<String> CONTACT_ROLES = new Set<String>{ 'Caregiver', 'Family', 'Other' };

    @AuraEnabled
    public static List<HealthCloudGA__ContactContactRelation__c> getContacts(){
        User currUser = MyKomenHealthUtility.getLoggedInUserDetails();
        List<HealthCloudGA__ReciprocalRole__c> roles = reciprocalRoleSelector.selectRolesByNames( CONTACT_ROLES );
        Set<Id> roleIds = new Set<Id>();
        if( currUser != null && roles != null && !roles.isEmpty() ){
            for( HealthCloudGA__ReciprocalRole__c role : roles ){
                roleIds.add( role.Id );
            }
            return contactContactRelationSelector.selectByRelatedContactAndRoleIds( currUser.ContactId, roleIds );
        }
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static List<HealthCloudGA__ReciprocalRole__c> getRoles(){
        return reciprocalRoleSelector.selectRolesByNames( CONTACT_ROLES );
    }

    @AuraEnabled(cacheable=true)
    public static User getLoggedInUser(){
        return MyKomenHealthUtility.getLoggedInUserDetails();
    }
}