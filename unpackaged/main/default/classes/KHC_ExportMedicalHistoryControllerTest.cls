/**
 * Tests for KHC_ExportMedicalHistoryController
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2020-08-13
 */
@IsTest
private class KHC_ExportMedicalHistoryControllerTest {
    private static final Id PERSON_ACCOUNT_RT_ID =
            Account.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('PersonAccount').recordTypeId;
    private static final String PATIENT_FIRST_NAME = 'Bob';
    private static final String PATIENT_LAST_NAME = 'Test';
    private static final String FATHER_NAME = 'Dad';
    private static final String FATHER_CONDITION_NAME = 'Chronic Grumpiness';
    private static final String FATHER_CONDITION_AGE;

    // To avoid hardcoding picklist values, just find the first active one
    static {
        List<PicklistEntry> ageAtDiagnosisValues =
                Family_Medical_History_Condition__c.fields.Age_at_diagnosis__c.getDescribe().getPicklistValues();
        for (PicklistEntry entry : ageAtDiagnosisValues) {
            if (entry.active) {
                FATHER_CONDITION_AGE = entry.value;
                break;
            }
        }
    }

    @TestSetup
    static void setup() {
        Account patient = new Account(
                RecordTypeId = PERSON_ACCOUNT_RT_ID,
                FirstName = PATIENT_FIRST_NAME,
                LastName = PATIENT_LAST_NAME,
            	Breast_Cancer_Status__c = 'Remission',
            	PersonEmail = 'test@email.com',
            	Phone = '0001112222',
            	Gender__pc = 'male',
            	Blood_Type__pc = 'AB+',
            	Height_ft__pc = 1,
            	Height_in__pc = 1
        );
        insert patient;

        Patient_Contact__c fmh = new Patient_Contact__c(
                Patient__c = patient.Id,
                Family_Member_Name__c = FATHER_NAME
        );
        insert fmh;

        Family_Medical_History_Condition__c fmhc = new Family_Medical_History_Condition__c(
                Family_Medical_History__c = fmh.Id,
                Condition_Name__c = FATHER_CONDITION_NAME,
                Age_at_diagnosis__c = FATHER_CONDITION_AGE
        );
        insert fmhc;
    }

    @IsTest
    static void whenPatientRecordAvailableThenLoadPatientData() {
        Account patient = getPatient();

        Test.startTest();

        Test.setCurrentPage(Page.KHC_ExportMedicalHistory);

        KHC_ExportMedicalHistoryController ctlr =
                new KHC_ExportMedicalHistoryController(new ApexPages.StandardController(patient));

        Test.stopTest();

        System.assertEquals(patient.Id, ctlr.patient.Id, 'The patient record should be loaded');

        List<Patient_Contact__c> history = getFamilyMedicalHistory();
        System.assertEquals(history.size(), ctlr.familyMedicalHistories.size(),
                'The correct number of history records should be loaded');
        System.assertEquals(history[0].Id, ctlr.familyMedicalHistories[0].Id,
                'The correct history record should be in the list');

        List<Family_Medical_History_Condition__c> conditions = getFamilyMedicalHistoryConditions();
        System.assertEquals(conditions.size(), ctlr.familyMedicalHistoryConditions.size(),
                'The correct number of condition records should have been loaded');
        System.assertEquals(conditions[0].Id, ctlr.familyMedicalHistoryConditions[0].Id,
                'The correct condition record should be in the list');

        Map<String,String> headers = ApexPages.currentPage().getHeaders();
        // TODO: Uncomment once rendering of VF page is set to PDF
//        System.assert(headers.containsKey('content-disposition'), 'The content-disposition header has been set');
//
//        String expectedFilename =
//                PATIENT_LAST_NAME + '_' + PATIENT_FIRST_NAME + '_' + Label.Export_Medical_History_Main_Heading + '.pdf';
//        System.assertEquals('attachment; filename=' + expectedFilename, headers.get('content-disposition'),
//                'The correct filename has been set in the headers');
    }

    @IsTest
    static void whenPatientRecordUnavailableThenThrowException() {
        Account missingPatient = new Account(Id = '001000000000000');

        Exception caughtException;

        Test.startTest();

        try {
            new KHC_ExportMedicalHistoryController(new ApexPages.StandardController(missingPatient));
        } catch (Exception e) {
            caughtException = e;
        }

        Test.stopTest();

        System.assertNotEquals(null, caughtException, 'An exception should have been thrown');
        System.assert(caughtException instanceof KHC_ExportMedicalHistoryController.MedicalHistoryControllerException,
                'It should be of the correct type: ' + caughtException.getTypeName());
        System.assertEquals(KHC_ExportMedicalHistoryController.UNABLE_TO_LOAD_ACCOUNT_ERROR_MSG,
                caughtException.getMessage(),
                'It should have the correct error message');
    }

    private static Account getPatient() {
        Account patient = [
                SELECT Id, FirstName, LastName
                FROM Account
                WHERE LastName = :PATIENT_LAST_NAME
        ];
        return patient;
    }

    private static List<Patient_Contact__c> getFamilyMedicalHistory() {
        return [
                SELECT Id
                FROM Patient_Contact__c
                WHERE Family_Member_Name__c = :FATHER_NAME
        ];
    }

    private static List<Family_Medical_History_Condition__c> getFamilyMedicalHistoryConditions() {
        return [
                SELECT Id
                FROM Family_Medical_History_Condition__c
                WHERE Condition_Name__c = :FATHER_CONDITION_NAME
        ];
    }
}