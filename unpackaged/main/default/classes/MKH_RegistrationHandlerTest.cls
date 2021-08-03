/**
 * Tests for MKH_RegistrationHandler
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2020-09-01
 */
@IsTest
private class MKH_RegistrationHandlerTest {
    private static final String EXISTING_PERSON_EMAIL = 'existing@example.com';
    private static final String EXISTING_USER_EMAIL = 'existinguser@example.com';

    @TestSetup
    static void setup() {
        Account person1 = MKH_TestDataFactory.createPersonAccount('Existing', 'Person', EXISTING_PERSON_EMAIL, false);
        Account person2 = MKH_TestDataFactory.createPersonAccount('Existing', 'User', EXISTING_USER_EMAIL, false);
        insert new Account[]{ person1, person2 };

        Id person2ContactId = [SELECT PersonContactId FROM Account WHERE Id = :person2.Id].PersonContactId;

        Contact c = [SELECT FirstName, LastName, Email FROM Contact WHERE Id = :person2ContactId];

        MKH_TestDataFactory.createCommunityUser(c, true, true);
    }

    @IsTest
    static void createUser_existingPersonAccount() {
        MKH_RegistrationHandler handler = new MKH_RegistrationHandler();

        Test.startTest();

        User result = handler.createUser(null, MKH_TestDataFactory.getUserData(EXISTING_PERSON_EMAIL));

        Test.stopTest();

        Account person = [
                SELECT Salutation, Suffix, Professional_Suffix__pc, PersonBirthdate, Deceased__pc, Gender__pc,
                        Employer__pc, Occupation__pc, PersonMailingStreet, PersonMailingCity, PersonMailingState,
                        PersonMailingCountry, PersonMailingPostalCode, Phone, PersonHomePhone, PersonMobilePhone,
                        Do_Not_Contact__pc, Postal_Opt_Out__pc, CRM_Org_ID__pc
                FROM Account
                WHERE PersonEmail = :EXISTING_PERSON_EMAIL
        ];

        Account expectedAccount = new Account(
                Id = person.Id,
                Salutation = 'MR',
                Suffix = 'III',
                Professional_Suffix__pc = 'MA',
                PersonBirthdate = Date.newInstance(1950,1,1),
                Deceased__pc = false,
                Employer__pc = 'TestCo',
                Occupation__pc = 'Information Technology (IT)',
                PersonMailingStreet = '1234 Test Street',
                PersonMailingCity = 'Testville',
                PersonMailingState = 'California',
                PersonMailingCountry = 'United States',
                PersonMailingPostalCode = '99999',
                Do_Not_Contact__pc = false,
                Postal_Opt_Out__pc = false,
                CRM_Org_ID__pc = MKH_TestDataFactory.getCustomAttributes().get('ContactId')
        );

        System.assertEquals(expectedAccount, person, 'The existing account should be updated with the data provided');

        Id personContactId = [SELECT PersonContactId FROM Account WHERE Id = :person.Id].PersonContactId;

        User expectedUser = new User(
                ContactId = personContactId,
                ProfileId = MKH_RegistrationHandler.COMMUNITY_PROFILE_ID,
                MyKomen_User_Id__c = '005000000000001aaa',
                Username = EXISTING_PERSON_EMAIL,
                Alias = EXISTING_PERSON_EMAIL.left(8),
                Email = EXISTING_PERSON_EMAIL,
                LastName = 'Name',
                FirstName = 'New',
                EmailEncodingKey = 'UTF-8',
                MiddleName = 'Middle',
                Street = '1111 Another Street',
                City = 'User City',
                State = 'California',
                Country = 'United States',
                PostalCode = '91919',
                CommunityNickname = 'Has.Everything',
                CompanyName = 'Testronix',
                Title = 'Quality Architect',
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago',
                LocaleSidKey = 'en_US'
        );

        System.assertEquals(expectedUser, result, 'The new user should be populated with the data provided');
    }

    @IsTest
    static void createUser_newPersonAccount() {
        String newEmail = 'new@example.com';

        MKH_RegistrationHandler handler = new MKH_RegistrationHandler();

        Test.startTest();

        User result = handler.createUser(null, MKH_TestDataFactory.getUserData(newEmail));

        Test.stopTest();

        Account person = [
                SELECT Salutation, Suffix, Professional_Suffix__pc, PersonBirthdate, Deceased__pc, Gender__pc,
                        Employer__pc, Occupation__pc, PersonMailingStreet, PersonMailingCity, PersonMailingState,
                        PersonMailingCountry, PersonMailingPostalCode, Phone, PersonHomePhone, PersonMobilePhone,
                        Do_Not_Contact__pc, Postal_Opt_Out__pc, FirstName, LastName, PersonEmail, CRM_Org_ID__pc
                FROM Account
                WHERE PersonEmail = :newEmail
        ];

        Account expectedAccount = new Account(
                Id = person.Id,
                Salutation = 'MR',
                Suffix = 'III',
                Professional_Suffix__pc = 'MA',
                PersonBirthdate = Date.newInstance(1950,1,1),
                Deceased__pc = false,
                Employer__pc = 'TestCo',
                Occupation__pc = 'Information Technology (IT)',
                PersonMailingStreet = '1234 Test Street',
                PersonMailingCity = 'Testville',
                PersonMailingState = 'California',
                PersonMailingCountry = 'United States',
                PersonMailingPostalCode = '99999',
                Do_Not_Contact__pc = false,
                Postal_Opt_Out__pc = false,
                FirstName = 'New',
                LastName = 'Name',
                PersonEmail = newEmail,
                CRM_Org_ID__pc = MKH_TestDataFactory.getCustomAttributes().get('ContactId')
        );

        System.assertEquals(expectedAccount, person, 'The new account should be created with the data provided');

        Id personContactId = [SELECT PersonContactId FROM Account WHERE Id = :person.Id].PersonContactId;

        User expectedUser = new User(
                ContactId = personContactId,
                ProfileId = MKH_RegistrationHandler.COMMUNITY_PROFILE_ID,
                MyKomen_User_Id__c = '005000000000001aaa',
                Username = newEmail,
                Alias = newEmail.left(8),
                Email = newEmail,
                LastName = 'Name',
                FirstName = 'New',
                EmailEncodingKey = 'UTF-8',
                MiddleName = 'Middle',
                Street = '1111 Another Street',
                City = 'User City',
                State = 'California',
                Country = 'United States',
                PostalCode = '91919',
                CommunityNickname = 'Has.Everything',
                CompanyName = 'Testronix',
                Title = 'Quality Architect',
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago',
                LocaleSidKey = 'en_US'
        );

        System.assertEquals(expectedUser, result, 'The new user should be populated with the data provided');
    }

    @IsTest
    static void createUser_newPersonAccountWithDuplicateWarning() {
        String newEmail = 'new2@example.com';

        MKH_RegistrationHandler handler = new MKH_RegistrationHandler();

        Auth.UserData userData = MKH_TestDataFactory.getUserData(newEmail);
        userData.firstName = 'Existing';
        userData.lastName = 'Person';

        Test.startTest();

        User result = handler.createUser(null, userData);

        Test.stopTest();

        Account person = [
                SELECT Salutation, Suffix, Professional_Suffix__pc, PersonBirthdate, Deceased__pc, Gender__pc,
                        Employer__pc, Occupation__pc, PersonMailingStreet, PersonMailingCity, PersonMailingState,
                        PersonMailingCountry, PersonMailingPostalCode, Phone, PersonHomePhone, PersonMobilePhone,
                        Do_Not_Contact__pc, Postal_Opt_Out__pc, FirstName, LastName, PersonEmail, CRM_Org_ID__pc
                FROM Account
                WHERE PersonEmail = :newEmail
        ];

        Account expectedAccount = new Account(
                Id = person.Id,
                Salutation = 'MR',
                Suffix = 'III',
                Professional_Suffix__pc = 'MA',
                PersonBirthdate = Date.newInstance(1950,1,1),
                Deceased__pc = false,
                Employer__pc = 'TestCo',
                Occupation__pc = 'Information Technology (IT)',
                PersonMailingStreet = '1234 Test Street',
                PersonMailingCity = 'Testville',
                PersonMailingState = 'California',
                PersonMailingCountry = 'United States',
                PersonMailingPostalCode = '99999',
                Do_Not_Contact__pc = false,
                Postal_Opt_Out__pc = false,
                FirstName = 'Existing',
                LastName = 'Person',
                PersonEmail = newEmail,
                CRM_Org_ID__pc = MKH_TestDataFactory.getCustomAttributes().get('ContactId')
        );

        System.assertEquals(expectedAccount, person, 'The new account should be created with the data provided');

        Id personContactId = [SELECT PersonContactId FROM Account WHERE Id = :person.Id].PersonContactId;

        User expectedUser = new User(
                ContactId = personContactId,
                ProfileId = MKH_RegistrationHandler.COMMUNITY_PROFILE_ID,
                MyKomen_User_Id__c = '005000000000001aaa',
                Username = newEmail,
                Alias = newEmail.left(8),
                Email = newEmail,
                LastName = 'Person',
                FirstName = 'Existing',
                EmailEncodingKey = 'UTF-8',
                MiddleName = 'Middle',
                Street = '1111 Another Street',
                City = 'User City',
                State = 'California',
                Country = 'United States',
                PostalCode = '91919',
                CommunityNickname = 'Has.Everything',
                CompanyName = 'Testronix',
                Title = 'Quality Architect',
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago',
                LocaleSidKey = 'en_US'
        );

        System.assertEquals(expectedUser, result, 'The new user should be populated with the data provided');
    }

    @IsTest
    static void updateUser() {
        User existingUser = [SELECT Id FROM User WHERE Email = :EXISTING_USER_EMAIL];

        MKH_RegistrationHandler handler = new MKH_RegistrationHandler();

        Test.startTest();

        handler.updateUser(existingUser.Id, null, MKH_TestDataFactory.getUserData(EXISTING_USER_EMAIL));

        Test.stopTest();

        Account person = [
                SELECT Salutation, Suffix, Professional_Suffix__pc, PersonBirthdate, Deceased__pc, Gender__pc,
                        Employer__pc, Occupation__pc, PersonMailingStreet, PersonMailingCity, PersonMailingState,
                        PersonMailingCountry, PersonMailingPostalCode, Phone, PersonHomePhone, PersonMobilePhone,
                        Do_Not_Contact__pc, Postal_Opt_Out__pc, CRM_Org_ID__pc
                FROM Account
                WHERE PersonEmail = :EXISTING_USER_EMAIL
        ];

        Account expectedAccount = new Account(
                Id = person.Id,
                Salutation = 'MR',
                Suffix = 'III',
                Professional_Suffix__pc = 'MA',
                PersonBirthdate = Date.newInstance(1950,1,1),
                Deceased__pc = false,
                Employer__pc = 'TestCo',
                Occupation__pc = 'Information Technology (IT)',
                PersonMailingStreet = '1234 Test Street',
                PersonMailingCity = 'Testville',
                PersonMailingState = 'California',
                PersonMailingCountry = 'United States',
                PersonMailingPostalCode = '99999',
                Do_Not_Contact__pc = false,
                Postal_Opt_Out__pc = false,
                CRM_Org_ID__pc = MKH_TestDataFactory.getCustomAttributes().get('ContactId')
        );

        System.assertEquals(expectedAccount, person, 'The existing account should be updated with the data provided');

        User updatedUser = [
                SELECT MyKomen_User_Id__c, Username, Alias, Email, LastName, FirstName, EmailEncodingKey, MiddleName,
                        Street, City, State, Country, PostalCode, CommunityNickname, CompanyName, Title,
                        LanguageLocaleKey, TimeZoneSidKey, LocaleSidKey
                FROM User
                WHERE Id = :existingUser.Id
        ];

        User expectedUser = new User(
                Id = updatedUser.Id,
                MyKomen_User_Id__c = '005000000000001aaa',
                Username = EXISTING_USER_EMAIL,
                Alias = EXISTING_USER_EMAIL.left(8),
                Email = EXISTING_USER_EMAIL,
                LastName = 'Name',
                FirstName = 'New',
                EmailEncodingKey = 'UTF-8',
                MiddleName = 'Middle',
                Street = '1111 Another Street',
                City = 'User City',
                State = 'California',
                Country = 'United States',
                PostalCode = '91919',
                CommunityNickname = 'Has.Everything',
                CompanyName = 'Testronix',
                Title = 'Quality Architect',
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago',
                LocaleSidKey = 'en_US'
        );

        System.assertEquals(expectedUser, updatedUser, 'The existing user should be updated with the data provided');
    }
}