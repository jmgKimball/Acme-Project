/**
 * Search Provider Controller
 * 
 * @author Nitin Chandwani, Traction on Demand
 * @date 2020-08-19
 */
public with sharing class KHC_SearchProviderController {
    
    private static ContactContactRelationSelector contactContactRelationSelector = new ContactContactRelationSelector();
    private static ReciprocalRoleSelector reciprocalRoleSelector = new ReciprocalRoleSelector();
    private static final string ROLE_NAME = 'Provider';
    private static final Id PROVIDER_RELATION_RT_ID =
            HealthCloudGA__ContactContactRelation__c.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Provider_Relationship').recordTypeId;

    @AuraEnabled
    public static List<HealthCloudGA__ContactContactRelation__c> getProviders(){
        User loggedInUser = MyKomenHealthUtility.getLoggedInUserDetails();
        return contactContactRelationSelector.selectByContactAndRole( loggedInUser.contactId, getProviderRoleId() );
    }

    //Method to insert contact and Contact-Contact Relation
    @AuraEnabled
    public static string createProviderAndConConRel( Contact provider, Boolean isActive ){
        User loggedInUser = MyKomenHealthUtility.getLoggedInUserDetails();
        Savepoint sp = Database.setSavepoint();
        try{
            String contactId = upsertNpiContactByNpiId( provider );
            if( String.isNotBlank( contactId ) ){
                HealthCloudGA__ContactContactRelation__c conConRel = new HealthCloudGA__ContactContactRelation__c();
                conConRel.RecordTypeId = PROVIDER_RELATION_RT_ID;
                conConRel.HealthCloudGA__Active__c = true;
                conConRel.HealthCloudGA__RelatedContact__c = loggedInUser.contactId;
                conConRel.HealthCloudGA__Role__c = getProviderRoleId();
                conConRel.Provider__c = contactId;
                conConRel.HealthCloudGA__Active__c = isActive;
                INSERT conConRel;
                return 'Success';
            }
        }catch( DmlException excep ){
            Database.rollback(sp);
            return excep.getMessage();
        }
        return null;
    }

    //Insert Contact by NPI Id
    public static string upsertNpiContactByNpiId( Contact provider ){
        if( provider != null ){
            Contact existingProvider = KHC_ProviderService.getContactByNpiId( String.valueOf( provider.get('NPI_ID__c') ) );
            if( existingProvider == null ){
                provider.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Provider').getRecordTypeId();
                INSERT provider;
            }else{
                provider = existingProvider;
            }
            return provider.Id;
        }
        return null;
    }
    
    public static Id getProviderRoleId(){
        List<HealthCloudGA__ReciprocalRole__c> roles = reciprocalRoleSelector.selectRoleByName( ROLE_NAME );
        if( roles != null && !roles.isEmpty() ){
            return roles[0].Id;
        }
        return null;
    }


    //Search Provider from NPI Registry
    @AuraEnabled(cacheable=true)
    public static String searchProvider(  String filterValueStr ){
        KHC_ProviderService.NpiSearchWrapper filterValue = (KHC_ProviderService.NpiSearchWrapper)JSON.deserializeStrict( filterValueStr, KHC_ProviderService.NpiSearchWrapper.class );
        Boolean isValid =  KHC_ProviderService.validateRequest( filterValue ) ;
        if( isValid ){
            return KHC_ProviderService.getNpiRegistery( filterValue );
        }
        return null;
    }
}