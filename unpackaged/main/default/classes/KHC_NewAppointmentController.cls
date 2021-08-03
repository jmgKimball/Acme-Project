/**
 * @description Controller for the next appointment component that allows the user
 * to create a new appointment from a form.
 *
 * @author Amos Ko, Traction on Demand
 * @date 2021-03-22
 */

public with sharing class KHC_NewAppointmentController {
    /**
     * @param title Name of provider
     * @param appointmentDate Date string in format YY-MM-DD
     * @param appointmentTime Time string in format HH:MM:SS
     * @param appointmentType Type of appointment
     * @param appointmentDescription String description of appointment
     * @param reminderDays An integer from 0 to 999
     *
     * @return A HealthCloudGA__EhrEncounter__c object with the given data
     */

    @AuraEnabled
    public static HealthCloudGA__EhrEncounter__c createNewAppointment(String title, String appointmentDate,
           String appointmentTime, String appointmentType, String appointmentDescription, String reminderDays) {

        if(String.isBlank(appointmentDescription) || String.isBlank(title)) {
            return null;
        }

        User currUser = MyKomenHealthUtility.getLoggedInUserDetails();
        HealthCloudGA__EhrEncounter__c encounter = new HealthCloudGA__EhrEncounter__c(
                HealthCloudGA__Account__c = currUser.AccountId,
                Title__c = title,
                Appointment_Date__c = stringToDateObject(appointmentDate),
                Appointment_Time__c = stringToTimeObject(appointmentTime),
                Description__c = appointmentDescription,
                Appointment_Type__c = appointmentType
        );

        if(!String.isBlank(reminderDays)) { 
            try {
                Integer days = Integer.valueOf(reminderDays);
                encounter.Reminder_Days__c = days;
            }

            catch (TypeException e) {
                throw new TypeException('ERROR: Reminder days must be an integer');
            }
        }

        insert encounter;
        return encounter; 
    }

    /**
     * @param appointmentDate A date string in format YYYY-MM-DD
     *
     * @return A Date object containing the date
     */
    public static Date stringToDateObject(String appointmentDate) {

        if(String.isBlank(appointmentDate)) {
            return null;
        }

        List<String> dateList = appointmentDate.split('-');

        if(dateList.size() < 3) {
            throw new TypeException('ERROR: Date string must be in format YYYY-MM-DD');
        }

        try {
            Integer year = Integer.valueOf(dateList[0]);
            Integer month = Integer.valueOf(dateList[1]);
            Integer day = Integer.valueOf(dateList[2]);

            Date myDate = Date.newInstance(year, month, day);
            return myDate;
        }

        catch (TypeException e) {
            throw new TypeException('ERROR: Invalid Date');
        }
    }

    /**
     * @param appointmentTime A time string in format HH:MM:SS
     *
     * @return A time object containing the time
     */
    public static Time stringToTimeObject(String appointmentTime) {

        if(String.isBlank(appointmentTime)) {
            return null;
        }

        List<String> timeList = appointmentTime.split(':');

        if(timeList.size() < 2) {
            throw new TypeException('ERROR: Time string must be in format HH:MM:SS');
        }

        try {
            Integer hours = Integer.valueOf(timeList[0]);
            Integer minutes = Integer.valueOf(timeList[1]);

            Time myTime = Time.newInstance(hours, minutes, 0,0);
            return myTime;
        }

        catch (TypeException e) {
            throw new TypeException('ERROR: Invalid Time');
        }
    }
}