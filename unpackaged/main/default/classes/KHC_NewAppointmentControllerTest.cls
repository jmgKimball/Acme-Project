/**
 * @description Test class for KHC_NewAppointmentController
 * @author Amos Ko
 * @date 2021-03-22
*/

@IsTest
private class KHC_NewAppointmentControllerTest {
    private static final String TITLE = 'New Appointment Test Provider';
    private static final String STRING_APPOINTMENT_DATE = '2050-5-11';
    private static final Date APPOINTMENT_DATE = KHC_NewAppointmentController.stringToDateObject(STRING_APPOINTMENT_DATE);
    private static final String STRING_APPOINTMENT_TIME = '15:45:00';
    private static final Time APPOINTMENT_TIME = KHC_NewAppointmentController.stringToTimeObject(STRING_APPOINTMENT_TIME);
    private static final String APPOINTMENT_TYPE_TREATMENT = 'Treatment';
    private static final String APPOINTMENT_DESCRIPTION = 'Testing';
    private static final String REMINDER_DAYS = '1';

    private static final String INVALID_DATE_FORMAT = 'VERY BAD';
    private static final String INVALID_DATE_WITH_CORRECT_FORMAT = 'VERY-BAD-TEST';
    private static final String INVALID_TIME_FORMAT = 'For Testing purposes';
    private static final String INVALID_TIME_WITH_CORRECT_FORMAT = 'For:Testing:purposes';


    @IsTest
    static void testValidEncounter() {

        Test.startTest();
        KHC_NewAppointmentController.createNewAppointment(
                TITLE, STRING_APPOINTMENT_DATE, STRING_APPOINTMENT_TIME, APPOINTMENT_TYPE_TREATMENT,
                APPOINTMENT_DESCRIPTION, REMINDER_DAYS);
        Test.stopTest();

        List<HealthCloudGA__EhrEncounter__c> encounter = [
                SELECT Title__c, Appointment_Date__c, Appointment_Time__c,
                        Appointment_Type__c
                FROM HealthCloudGA__EhrEncounter__c
                WHERE Title__c = :TITLE AND Appointment_Date__c = :APPOINTMENT_DATE AND
                Appointment_Time__c = :APPOINTMENT_TIME AND Appointment_Type__c = :APPOINTMENT_TYPE_TREATMENT
                LIMIT 1
        ];

        System.assertEquals(1, encounter.size());
    }

    @IsTest
    static void testEmptyEncounter() {
        Test.startTest();
        KHC_NewAppointmentController.createNewAppointment('', '', '', '', '', '');
        Test.stopTest();

        List<HealthCloudGA__EhrEncounter__c> encounter = [
                SELECT Title__c, Appointment_Date__c, Appointment_Time__c,
                        Appointment_Type__c
                FROM HealthCloudGA__EhrEncounter__c];
        System.assertEquals(0, encounter.size());
    }

    @IsTest
    static void testRequiredFieldsEncounter() {
        Test.startTest();
        KHC_NewAppointmentController.createNewAppointment(TITLE, '', '', '', APPOINTMENT_DESCRIPTION, '');
        Test.stopTest();

        List<HealthCloudGA__EhrEncounter__c> encounter = [
                SELECT Title__c, Appointment_Date__c, Appointment_Time__c,
                        Appointment_Type__c
                FROM HealthCloudGA__EhrEncounter__c];
        System.assertEquals(1, encounter.size());
    }

    @IsTest
    static void testInvalidDate() {
        Test.startTest();
        try {
            KHC_NewAppointmentController.createNewAppointment(TITLE, INVALID_DATE_FORMAT, STRING_APPOINTMENT_TIME,
                    APPOINTMENT_TYPE_TREATMENT, APPOINTMENT_DESCRIPTION, REMINDER_DAYS);
        }

        catch (TypeException e) {
            Boolean exceptionThrown = e.getMessage().contains('ERROR: Date string must be in format YYYY-MM-DD') ? true : false;
            System.assertEquals(true, exceptionThrown);
        }

        try{
            KHC_NewAppointmentController.createNewAppointment(TITLE, INVALID_DATE_WITH_CORRECT_FORMAT,
                    STRING_APPOINTMENT_TIME, APPOINTMENT_TYPE_TREATMENT, APPOINTMENT_DESCRIPTION, REMINDER_DAYS);
        }

        catch (TypeException e) {
            Boolean exceptionThrown = e.getMessage().contains('ERROR: Invalid Date') ? true : false;
            System.assertEquals(true, exceptionThrown);
        }

        Test.stopTest();

        List<HealthCloudGA__EhrEncounter__c> encounter = [
                SELECT Title__c, Appointment_Date__c, Appointment_Time__c,
                        Appointment_Type__c
                FROM HealthCloudGA__EhrEncounter__c];
        System.assertEquals(0, encounter.size());
    }

    @IsTest
    static void testInvalidTime() {
        Test.startTest();

        try {
            KHC_NewAppointmentController.createNewAppointment(TITLE, STRING_APPOINTMENT_DATE, INVALID_TIME_FORMAT,
                    APPOINTMENT_TYPE_TREATMENT, APPOINTMENT_DESCRIPTION, REMINDER_DAYS);
        }

        catch (TypeException e) {
            Boolean exceptionThrown = e.getMessage().contains('ERROR: Time string must be in format HH:MM:SS') ? true : false;
            System.assertEquals(true, exceptionThrown);
        }

        try{
            KHC_NewAppointmentController.createNewAppointment(TITLE, STRING_APPOINTMENT_DATE, INVALID_TIME_WITH_CORRECT_FORMAT,
                    APPOINTMENT_TYPE_TREATMENT, APPOINTMENT_DESCRIPTION, REMINDER_DAYS);
        }

        catch (TypeException e) {
            Boolean exceptionThrown = e.getMessage().contains('ERROR: Invalid Time') ? true : false;
            System.assertEquals(true, exceptionThrown);
        }

        Test.stopTest();

        List<HealthCloudGA__EhrEncounter__c> encounter = [
                SELECT Title__c, Appointment_Date__c, Appointment_Time__c,
                        Appointment_Type__c
                FROM HealthCloudGA__EhrEncounter__c];
        System.assertEquals(0, encounter.size());
    }
}