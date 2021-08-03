@isTest
public class EhrMedicationStatementSelectorTest {
    @TestSetup
    static void setupTestData(){
        List<Sobject> testRecords = new List<Sobject>();
        testRecords.add( KHC_TestUtility.insertMedication( 'Advil', false ) );
        testRecords.add( KHC_TestUtility.insertMedication( 'Zortress', false ) );
        INSERT testRecords;

        KHC_TestUtility.insertEhrMedicationStatement( testRecords[0].Id, null, true );
    }
    @isTest
    public static void selectByBlankPersonAccount(){
        EhrMedicationStatementSelector medicationStatemnetSelector = new EhrMedicationStatementSelector();
        List<HealthCloudGA__EhrMedicationStatement__c> medicationSatatements = medicationStatemnetSelector.selectByPersonAccount( null );
        System.assertEquals( 1, medicationSatatements.size(), 'There should be only one medication for this parent account.');
    }
}