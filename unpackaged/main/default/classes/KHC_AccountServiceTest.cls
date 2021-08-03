/**
 * Tests for KHC_AccountService
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2020-09-22
 */
@isTest
private class KHC_AccountServiceTest {
    private static final String EMAIL = 'healthhistorytest@example.com';

    @TestSetup
    static void setup() {
        Account a = MKH_TestDataFactory.createPersonAccount('First', 'Last', EMAIL, true);
        Contact c = [SELECT FirstName, LastName, Email FROM Contact WHERE AccountId = :a.Id];
        MKH_TestDataFactory.createCommunityUser(c, true, true);
    }

    @IsTest
    static void getAccountIdForUser() {
        User u = getCommunityUser();

        Test.startTest();

        Id result = KHC_AccountService.getAccountIdForUser(u.Id);

        Test.stopTest();

        System.assertEquals(u.AccountId, result, 'The correct account id should be returned');
    }

    @IsTest
    static void getUserRecord() {
        User u = getCommunityUser();

        Test.startTest();

        User result = KHC_AccountService.getUserRecord(u.Id);

        Test.stopTest();

        System.assertEquals(u.ContactId, result.ContactId, 'The correct Contact id should be returned');
    }

    @IsTest
    static void getContactIdForUser() {
        User u = getCommunityUser();

        Test.startTest();

        Id result = KHC_AccountService.getContactIdForUser(u.Id);

        Test.stopTest();

        System.assertEquals(u.ContactId, result, 'The correct contact id should be returned');
    }

    private static User getCommunityUser() {
        return [SELECT Id, AccountId, ContactId FROM User WHERE Email = :EMAIL];
    }

    @IsTest
    static void correctPersonAccountState_AlreadyValid() {
        Account a = new Account(PersonMailingState = 'California', PersonOtherState = 'New York');

        KHC_AccountService.correctPersonAccountState(a);

        Account expected = new Account(PersonMailingState = 'California', PersonOtherState = 'New York');
        System.assertEquals(expected, a, 'No state values should have changed');
    }

    @IsTest
    static void correctPersonAccountState_ValidAsCode() {
        Account a = new Account(PersonMailingState = 'CA', PersonOtherState = 'New York');

        KHC_AccountService.correctPersonAccountState(a);

        Account expected = new Account(
                PersonMailingState = null,
                PersonMailingStateCode = 'CA',
                PersonOtherState = 'New York'
        );
        System.assertEquals(expected, a, 'The valid code value should be moved to the state code field');
    }

    @IsTest
    static void correctPersonAccountState_Invalid() {
        Account a = new Account(PersonMailingState = 'CA', PersonOtherState = 'BAD');

        KHC_AccountService.correctPersonAccountState(a);

        Account expected = new Account(
                PersonMailingState = null,
                PersonMailingStateCode = 'CA',
                PersonOtherState = null
        );
        System.assertEquals(expected, a, 'The invalid value should be removed from the state field');
    }

    @IsTest
    static void correctPersonAccountState_FieldNotQueried() {
        Account a = [SELECT PersonMailingState FROM Account WHERE PersonEmail = :EMAIL];

        KHC_AccountService.correctPersonAccountState(a);

        Account expected = new Account(Id = a.Id);
        System.assertEquals(expected, a, 'The method should run without error for records where state is not included');
    }

    @IsTest
    static void correctUserState() {
        User u = new User(State = 'AZ');

        KHC_AccountService.correctUserState(u);

        User expected = new User(State = null, StateCode = 'AZ');
        System.assertEquals(expected, u, 'The valid code should be moved to the state code field');
    }
}