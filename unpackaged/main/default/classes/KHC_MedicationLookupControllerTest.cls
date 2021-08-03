/**
 * Test class for Medication Lookup Controller
 * 
 * @author Nitin Chandwani, Traction on Demand
 * @date 2020-09-10
 */
@isTest
public class KHC_MedicationLookupControllerTest {
    private static final string MEDICATION_ADVIL = 'Advil';
    @isTest
    public static void testSearchMedications(){
        Test.setMock(HttpCalloutMock.class, new KHC_HttpCalloutMock());
        List<KHC_MedicationLookupController.DrugWrap> resp = KHC_MedicationLookupController.getAllMedications( MEDICATION_ADVIL );
        System.assertNotEquals( null, resp, 'Return value should have response.');
    }
    @isTest
    public static void testUpsertMedications(){
        Test.setMock(HttpCalloutMock.class, new KHC_HttpCalloutMock());
        List<KHC_MedicationLookupController.DrugWrap> resp = KHC_MedicationLookupController.getAllMedications(MEDICATION_ADVIL);
        System.assertNotEquals( null, resp, 'Return value should have response.');
        Medication__c medication = new Medication__c( Med_Name__c = MEDICATION_ADVIL );
        Id medicationId = KHC_MedicationLookupController.upsertMedication( medication );
        System.assertEquals( medicationId, [SELECT Id FROM Medication__c WHERE Med_Name__c =: MEDICATION_ADVIL LIMIT 1].Id, 'Medication created should be same.');
    }
    @isTest
    public static void testUpsertExistingMedications(){
        Test.setMock(HttpCalloutMock.class, new KHC_HttpCalloutMock());
        List<KHC_MedicationLookupController.DrugWrap> resp = KHC_MedicationLookupController.getAllMedications(MEDICATION_ADVIL);
        System.assertNotEquals( null, resp, 'Return value should have response.');
        Medication__c medication = new Medication__c( Med_Name__c = MEDICATION_ADVIL );
        Id medicationId = KHC_MedicationLookupController.upsertMedication( medication );
        System.assertEquals( medicationId, [SELECT Id FROM Medication__c WHERE Med_Name__c =: MEDICATION_ADVIL  LIMIT 1].Id, 'Medication created should be same.');
        //Calling method with same medication
        Id medicationId2 = KHC_MedicationLookupController.upsertMedication( medication );
        System.assertEquals( medicationId, medicationId2, 'Medication should not be created again.');
    }
}