@isTest
public class KHC_SearchProviderControllerTest {
    private static String TEST_EMAIL = 'name@example.com';

    //TODO: Update test class to accomodate changes for caseTeamMember
    @isTest
    public static void searchProviderWithBlank(){
        Test.setMock(HttpCalloutMock.class, new KHC_HttpCalloutMock());
        String resp = KHC_SearchProviderController.searchProvider('{}');
        System.assertEquals( null, resp, 'Return value should be null for blank filters.');
    }
    @isTest
    public static void searchProviderWithOnlyCity(){
        Test.setMock(HttpCalloutMock.class, new KHC_HttpCalloutMock());
        KHC_ProviderService.NpiSearchWrapper filterValues = new  KHC_ProviderService.NpiSearchWrapper();
        filterValues.city = 'Baltimore';
        String resp = KHC_SearchProviderController.searchProvider( JSON.serialize(filterValues) );
        System.assertNotEquals( null, resp, 'Return value should have response.');
        System.assert( resp.contains( '"number": ' + KHC_HttpCalloutMock.NPI_ID), 'Response must contain related NPSP Id' );
    }
    @isTest
    public static void searchProviderWithAllFilters(){
        Test.setMock(HttpCalloutMock.class, new KHC_HttpCalloutMock());
        KHC_ProviderService.NpiSearchWrapper filterValues = new  KHC_ProviderService.NpiSearchWrapper();
        filterValues.city = 'Baltimore';
        filterValues.state = 'MD';
        filterValues.zipCode = '12345';
        filterValues.providerLastName = 'test';
        filterValues.providerfirstName = 'test';
        String resp = filterValues.skip = '60';
        KHC_SearchProviderController.searchProvider( JSON.serialize(filterValues) );
        System.assertNotEquals( null, resp, 'Return value should have response.');
    }

    @isTest
    public static void upsertProviderBlank(){
        String recordId =  KHC_SearchProviderController.upsertNpiContactByNpiId( null );
        System.assertEquals( null, recordId, 'Contact record should not be created.');
    }

    @isTest
    public static void upsertProviderNew(){
        Contact con = new Contact();
        con.LastName = 'Test Provider';
        con.NPI_ID__c = '12345678';
        con.Email = TEST_EMAIL;
        String recordId =  KHC_SearchProviderController.upsertNpiContactByNpiId( con );
        List<Contact> contacts = [SELECT Id FROM Contact WHERE NPI_ID__c = :con.NPI_ID__c ];
        System.assertEquals( contacts[0].Id, recordId, 'Contact record should be created with the specified NPI Id.');
    }
    @isTest
    public static void upsertProviderExisting(){
        Contact con = new Contact();
        con.LastName = 'Test Provider';
        con.NPI_ID__c = '12345678';
        con.Email = TEST_EMAIL;
        String recordId =  KHC_SearchProviderController.upsertNpiContactByNpiId( con );
        List<Contact> contacts = [SELECT Id FROM Contact WHERE NPI_ID__c = :con.NPI_ID__c ];
        System.assertEquals( contacts[0].Id, recordId, 'Contact record should be created with the specified NPI Id.');
        Contact con2 = new Contact();
        con2.LastName = 'Test Provider 2';
        con2.NPI_ID__c = '12345678';
        con2.Email = TEST_EMAIL;
        String recordId2 =  KHC_SearchProviderController.upsertNpiContactByNpiId( con2 );
        contacts = [SELECT Id FROM Contact WHERE NPI_ID__c = :con.NPI_ID__c ];
        System.assertEquals( contacts.size(), 1, 'Only one Contact record should be returned with the specified NPI Id.');
        System.assertEquals( contacts[0].Id, recordId, 'Same Contact record should be returned with the specified NPI Id.');
    }

    @isTest
    public static void createProviderAndConConRel(){
        Contact con = new Contact();
        con.LastName = 'Test Provider';
        con.NPI_ID__c = '12345678';
        con.Email = TEST_EMAIL;
        String resp =  KHC_SearchProviderController.createProviderAndConConRel( con, true );
        List<Contact> contacts = [SELECT Id FROM Contact WHERE NPI_ID__c = :con.NPI_ID__c ];
    }

    @isTest
    public static void createAndGetProvider(){
        Contact con = new Contact();
        con.LastName = 'Test Provider';
        con.NPI_ID__c = '12345678';
        con.Email = TEST_EMAIL;
        String resp =  KHC_SearchProviderController.createProviderAndConConRel( con, true );
        List<Contact> contacts = [SELECT Id FROM Contact WHERE NPI_ID__c = :con.NPI_ID__c ];
        List<HealthCloudGA__ContactContactRelation__c> conConRels = KHC_SearchProviderController.getProviders();
    }

}