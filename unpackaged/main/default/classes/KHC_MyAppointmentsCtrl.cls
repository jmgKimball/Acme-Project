/* * Controller class for My Appointments Component
 *
 * @author Nitin Chandwani, Traction on Demand
 * @date 2021-03-01
 */
public inherited sharing class KHC_MyAppointmentsCtrl {

    private static EhrEncounterSelector encounterSelector = new EhrEncounterSelector();

    @AuraEnabled
    public static List<HealthCloudGA__EhrEncounter__c> getAppointments(){
        User currUser = MyKomenHealthUtility.getLoggedInUserDetails();
        if( currUser != null ){
            return encounterSelector.getAppointmentsByPatientId( currUser.AccountId );
        }
        return null;
    }

}