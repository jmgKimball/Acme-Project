/**
 * Test class for Medication Controller
 * 
 * @author Nitin Chandwani, Traction on Demand
 * @date 2020-09-10
 */
@isTest
public class KHC_MedicationControllerTest {
    @TestSetup
    static void setupTestData(){
        List<Sobject> testRecords = new List<Sobject>();
        testRecords.add( KHC_TestUtility.insertMedication( 'Advil', false ) );
        testRecords.add( KHC_TestUtility.insertMedication( 'Zortress', false ) );
        INSERT testRecords;

        KHC_TestUtility.insertEhrMedicationStatement( testRecords[0].Id, null, true );
    }

    @isTest
    public static void testGetMedications(){
        List<HealthCloudGA__EhrMedicationStatement__c> medicationStatements = KHC_MedicationController.getMedications();
        System.assertEquals( 1, medicationStatements.size(), 'There should be only one medication returned.');
    }

    @isTest
    public static void testGetLoggedInUserDetails(){
        User loggedInUser = KHC_MedicationController.getLoggedInUserDetails();
        System.assertEquals( UserInfo.getUserId(), loggedInUser.Id, 'User retuned mus have the same Id.');
    }
}