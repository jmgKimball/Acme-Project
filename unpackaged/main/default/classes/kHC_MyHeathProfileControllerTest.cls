/**
 * Tests for kHC_MyHeathProfileController
 *
 * @author Sabrina Perardt, Traction on Demand
 *
 * @date 2020-09-02
 */
@IsTest
private class kHC_MyHeathProfileControllerTest {
    private static final String PERSON_EMAIL = 'peggy@komen.org';

    @TestSetup
    static void setup() {
        Account person =
                MKH_TestDataFactory.createPersonAccount('Peggy', 'Peggerson', PERSON_EMAIL, false);
        person.Organ_Donor__pc = true;

        Medication__c medication = new Medication__c(Name = 'Advil', SetID__c= '1234567890');

        insert new SObject[]{ person, medication};

        HealthCloudGA__EhrMedicationStatement__c myMed = new HealthCloudGA__EhrMedicationStatement__c(
                Medication__c = medication.Id,
                HealthCloudGA__MedicationName__c = 'Advil',
                HealthCloudGA__Account__c = person.Id

        );
        insert myMed;
    }

    @IsTest
    static void getMyHealthProfileTest() {// TODO write test for negative result
        Account myAccount = getMyAccount();

        Test.startTest();

        List<Account> healthProfileInfo = kHC_MyHeathProfileController.getMyInformation(myAccount.Id);

        Test.stopTest();

        System.assertEquals(healthProfileInfo[0].HealthCloudGA__MedicationStatements__r[0].HealthCloudGA__MedicationName__c,
                'Advil',
                'Medication Name should be Advil'
        );
    }

    @IsTest
    static void updateAccountTest() { // TODO write test for negative result

        Account myAccount = getMyAccount();
        System.assertEquals(myAccount.Organ_Donor__pc, true,
                'This person should be organ donor before updating it');

        Contact myContact = getMyContact();
        System.assertEquals(myContact.Rhesus_Negative__c, false,
                'This person should be organ donor before updating it');

        Test.startTest();
        myAccount.Organ_Donor__pc = false;
        myContact.Rhesus_Negative__c = true;
        kHC_MyHeathProfileController.getBloodTypePicklistValues();
        kHC_MyHeathProfileController.getRelationShipValues();
        kHC_MyHeathProfileController.getInsurancesByMemberId(myContact.Id);
        kHC_MyHeathProfileController.getProvidersByPatientId(myContact.Id);
        kHC_MyHeathProfileController.updateAccount(myAccount, myContact);
        Test.stopTest();

        Account myAccountAfterUpdate = getMyAccount();
        Contact myContactAfterUpdate = getMyContact();
        System.assertEquals(myAccountAfterUpdate.Organ_Donor__pc, false,
                'This person should NOT be organ donor after update');
        System.assertEquals(myContactAfterUpdate.Rhesus_Negative__c, true,
                'This person should have Rhesus Negative equals true after update');
    }

    @IsTest
    static void getBreastHealthTopicTest() {
        List<String> breastHealthTopics = kHC_MyHeathProfileController.getBreastHealthTopic();
        system.assertNotEquals(0, breastHealthTopics.size());
    }

    private static Account getMyAccount() {
        return [SELECT Organ_Donor__pc FROM Account WHERE PersonEmail = :PERSON_EMAIL];
    }

    private static Contact getMyContact() {
        return [SELECT Rhesus_Negative__c FROM Contact WHERE Email = :PERSON_EMAIL];
    }
}