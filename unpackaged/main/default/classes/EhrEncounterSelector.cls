/** Selector class for HealthCloudGA__EhrEncounter__c
 *
 * @author Nitin Chandwani, Traction on Demand
 * @date 2021-03-01
 */
public inherited sharing class EhrEncounterSelector {

    public List<HealthCloudGA__EhrEncounter__c> getAppointmentsByPatientId( Id personAccountId ) {
        if( personAccountId != null ){
            return [SELECT Provider_Name__c, Appointment_Date__c, Appointment_Time__c,
                    Description__c, Attended__c, Appointment_Type__c, Title__c, Reminder_Days__c
            FROM HealthCloudGA__EhrEncounter__c
            WHERE HealthCloudGA__Account__c =: personAccountId
            ORDER BY Appointment_Date__c, Appointment_Time__c ASC ];
        }
        return null;

    }
}