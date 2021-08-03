@IsTest
private class KHC_MyInsuranceControllerTest {
    private static final String PERSON_ACCOUNT_LAST_NAME = 'Insurance';
    private static final String SUBSCRIBER_FIRST_NAME = 'Peggy';

    @TestSetup
    static void setup() {
        insert MKH_TestDataFactory.createPersonAccount(
                'Test',
                PERSON_ACCOUNT_LAST_NAME,
                'testInsurance@test.com',
                false
        );
    }

    @IsTest
    static void getPicklistValuesTest() {
        Map<String, List<String>> myPicklists = KHC_MyInsuranceController.getPicklistValues();

        List<String> insuranceProviders = myPicklists.get('Insurance_Provider__c');
        System.assertEquals(false, insuranceProviders.isEmpty(),
                'Insurance provider list should have at least 1 provider');
    }

    @IsTest
    static void insertInsuranceTest() {
        Account acc = getPersonAccount();

        Insurance__c myInsurance = createTestInsuranceRecord();

        KHC_MyInsuranceController.insertInsurance(acc.Id, myInsurance);

        Test.startTest();
        List<Insurance__c> insertedInsurance = [SELECT Subscriber_First_Name__c, Member__c FROM Insurance__c];
        Test.stopTest();

        System.assertEquals(SUBSCRIBER_FIRST_NAME, insertedInsurance.get(0).Subscriber_First_Name__c,
                'Subscriber first name should be Peggy');
    }

    @IsTest
    static void deleteInsuranceTest() {
        Account acc = getPersonAccount();

        Insurance__c myInsurance = createTestInsuranceRecord();

        KHC_MyInsuranceController.insertInsurance(acc.Id, myInsurance);

        Test.startTest();

        KHC_MyInsuranceController.deleteInsurance(myInsurance);

        List<Insurance__c> insurance = [SELECT Subscriber_First_Name__c, Member__c FROM Insurance__c];
        Test.stopTest();

        System.assertEquals(0, insurance.size(), 'Should not have any insurance');
    }

    @IsTest
    static void getInsuranceListTest() {
        Account acc = getPersonAccount();

        Insurance__c myInsurance = createTestInsuranceRecord();

        KHC_MyInsuranceController.insertInsurance(acc.Id, myInsurance);

        Test.startTest();
        List<Insurance__c> insuranceList = KHC_MyInsuranceController.getMyInsuranceProvider(acc.Id);
        Test.stopTest();

        System.assertEquals(SUBSCRIBER_FIRST_NAME, insuranceList.get(0).Subscriber_First_Name__c,
                'Subscriber first name should be Peggy');
    }

    @IsTest
    static void getAccountDataTest() {
        Account personAccount = getPersonAccount();

        KHC_MyInsuranceController.KHC_MyInsuranceControllerResponse response;

        Test.startTest();
        response = KHC_MyInsuranceController.getAccountData(personAccount.Id);
        Test.stopTest();

        System.assert(response != null, 'Response object was null');

        Account responseAccount = response.personAccount;
        System.assert(responseAccount != null, 'Response account was null');
        System.assertEquals(personAccount.Id, responseAccount.Id, 'Account Id was unexpected');
    }

    @IsTest
    static void updateAccountDataTest() {
        Account personAccount = getPersonAccount();

        personAccount.Is_Insured__pc = 'Yes';

        KHC_MyInsuranceController.KHC_MyInsuranceControllerResponse response;

        Test.startTest();
        response = KHC_MyInsuranceController.updateAccountData(personAccount);
        Test.stopTest();

        System.assert(response != null, 'Response object was null');
        System.assertEquals(true, response.isSuccess, 'Response did not indicate successful update');

        List<Account> postUpdateAccountList = [SELECT Id, Is_Insured__pc FROM Account WHERE Id = :personAccount.Id];
        System.assertEquals(1, postUpdateAccountList.size(), 'Size of response list was unexpected');
        System.assertEquals('Yes', postUpdateAccountList[0].Is_Insured__pc, 'Account was not updated');
    }

    private static Account getPersonAccount() {
        return [SELECT Id FROM Account WHERE LastName = :PERSON_ACCOUNT_LAST_NAME];
    }

    private static Insurance__c createTestInsuranceRecord() {
        return new Insurance__c ( Uninsured__c = false,Subscriber_Date_of_Birth__c = Date.today(),
                Member_Number__c = '11111', Subscriber_Number__c = '1111',
                Subscriber_Last_Name__c = 'InsuranceLN', Subscriber_First_Name__c = SUBSCRIBER_FIRST_NAME,
                Insurance_Provider__c = 'Humana'
        );
    }
}