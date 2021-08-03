/**
 * Methods for generating test data used by MyKomen Health tests
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2020-09-01
 */
public with sharing class MKH_TestDataFactory {
    private static final Id MYKOMEN_HEALTH_COMMUNITY_PROFILE_ID =
            [SELECT Id FROM Profile WHERE Name = 'Patient Community Login'].Id;
    private static final Id PERSON_ACCOUNT_RT_ID =
            Account.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('PersonAccount').recordTypeId;

    public static Account createPersonAccount(String firstName, String lastName, String email, Boolean doInsert) {
        Account person = new Account(
                RecordTypeId = PERSON_ACCOUNT_RT_ID,
                FirstName = firstName,
                LastName = lastName,
                PersonEmail = email
        );

        if(doInsert) {
            insert person;
        }

        return person;
    }

    public static User createCommunityUser(Contact con, Boolean isActive, Boolean doInsert) {
        User u = new User(
                IsActive = isActive,
                ProfileId = MYKOMEN_HEALTH_COMMUNITY_PROFILE_ID,
                Email = con.Email,
                Username = con.Email + Crypto.getRandomInteger(),
                ReceivesAdminInfoEmails = true,
                ReceivesInfoEmails = true,
                ContactId = con.Id,
                LastName = con.LastName,
                FirstName = con.FirstName,
                Alias = con.FirstName.left(1) + con.LastName.left(7),
                CommunityNickname = con.FirstName + '.' + con.LastName,
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago',
                EmailEncodingKey = 'UTF-8'
        );

        if (doInsert) {
            insert u;
        }

        return u;
    }

    public static Auth.UserData getUserData(String email) {
        return new Auth.UserData(
                '00D000000000001aaa005000000000001aaa',
                'New',
                'Name',
                'New Name',
                email,
                null,
                email,
                'en_US',
                'Salesforce',
                null,
                buildAttributeMap()
        );
    }

    private static Map<String, String> buildAttributeMap() {
        Map<String, String> result = new Map<String, String>();

        // Simulate what happens due to a bug with the SFDC handling of custom attributes
        // Because attributeMap is a flat map of string to string, but custom attributes are placed under a key
        // 'custom_attributes' in this map, SFDC converts them to a string, resulting in the output being the toString
        // version of the data
        // To work around this, in the Connected App Plugin we convert all custom fields to JSON and store them under a
        // single 'json' key
        Map<String, String> customAttributes = new Map<String, String>{
                'json' => JSON.serialize(getCustomAttributes())
        };
        result.put('custom_attributes', customAttributes.toString());

        return result;
    }

    /**
     * This returns a static attribute map, taken from the MK_ConnectedAppPluginTest in the NPSP org as a representation
     * of what attributes will be sent from that org during the SSO process
     *
     * @return Custom Attribute Map
     */
    public static Map<String, String> getCustomAttributes() {
        return new Map<String, String>{
                'ContactId' => '003000000000001',
                'MiddleName' => 'Middle',
                'Street' => '1111 Another Street',
                'City' => 'User City',
                'State' => 'California',
                'Country' => 'United States',
                'PostalCode' => '91919',
                'CommunityNickname' => 'Has.Everything',
                'CompanyName' => 'Testronix',
                'Title' => 'Quality Architect',
                'LanguageLocaleKey' => 'en_US',
                'TimeZoneSidKey' => 'America/Chicago',
                'LocaleSidKey' => 'en_US',
                'Id' => '003000000000001',
                'Salutation' => 'MR',
                'Suffix__c' => 'III',
                'Professional_Suffix__c' => 'MA',
                'Birthdate' => '1950-01-01 00:00:00',
                'Deceased__c' => 'false',
                'Gender__c' => 'Male',
                'Ethnicity__c' => 'Asian',
                'LP_Ethnicity__c' => 'Not Identified',
                'Employer__c' => 'TestCo',
                'Occupation__c' => 'Information Technology (IT)',
                'MailingStreet' => '1234 Test Street',
                'MailingCity' => 'Testville',
                'MailingState' => 'California',
                'MailingCountry' => 'United States',
                'MailingPostalCode' => '99999',
                'Phone' => '123 456 7890',
                'npe01__WorkPhone__c' => '111 222 3333',
                'HomePhone' => '444 555 6666',
                'MobilePhone' => '777 888 9999',
                'npe01__PreferredPhone__c' => 'Mobile',
                'Do_Not_Contact__c' => 'false',
                'Email_Opt_Out_Date__c' => '2020-01-01 00:00:00',
                'Postal_Mail_Opt_Out__c' => 'false',
                'AccountId' => '001000000000001'
        };
    }
}