/**
 * Test data factory for clinical trials tests
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2020-06-01
 */
@IsTest
public class ClinicalTrialsTestDataFactory {
    public static final String TRIAL_1_NCTID = '111111111111';
    public static final String TRIAL_2_NCTID = '222222222222';
    public static final String TRIAL_3_NCTID = '333333333333';

    public static final String LOC_1_KEY = 'LOCATION1';
    public static final Double LOC_1_LATITUDE = 49.2598906;
    public static final Double LOC_1_LONGITUDE = -122.9179885;

    public static final String LOC_2_KEY = 'LOCATION2';
    public static final Double LOC_2_LATITUDE= 43.6459318;
    public static final Double LOC_2_LONGITUDE = -79.5240142;

    public static final String LOC_3_KEY = 'LOCATION3';

    public static void insertTrialsAndTrialPatients() {
        List<Clinical_Trial__c> trials = insertTrials();
        insert new Clinical_Trial_Patient__c(Clinical_Trial__c = trials[1].Id);
    }

    public static void insertTrialsAndLocations() {
        List<Clinical_Trial__c> trials = insertTrials();

        Clinical_Trial_Location__c loc = new Clinical_Trial_Location__c(
                Clinical_Trial__c = trials[0].Id,
                Trial_Location_Key__c = LOC_1_KEY,
                Geocode__Latitude__s = LOC_1_LATITUDE,
                Geocode__Longitude__s = LOC_1_LONGITUDE
        );
        Clinical_Trial_Location__c loc2 = new Clinical_Trial_Location__c(
                Clinical_Trial__c = trials[1].Id,
                Trial_Location_Key__c = LOC_2_KEY,
                Geocode__Latitude__s = LOC_2_LATITUDE,
                Geocode__Longitude__s = LOC_2_LONGITUDE
        );
        Clinical_Trial_Location__c loc3 = new Clinical_Trial_Location__c(
                Clinical_Trial__c = trials[2].Id,
                Trial_Location_Key__c = LOC_3_KEY
        );
        insert new Clinical_Trial_Location__c[]{ loc, loc2, loc3 };
    }

    private static List<Clinical_Trial__c> insertTrials() {
        Clinical_Trial__c trial = new Clinical_Trial__c(
                NCTId__c = TRIAL_1_NCTID,
                Clinical_Trial_Status__c = 'Recruiting'
        );
        Clinical_Trial__c trial2 = new Clinical_Trial__c(
                NCTId__c = TRIAL_2_NCTID,
                Clinical_Trial_Status__c = 'Recruiting'
        );
        Clinical_Trial__c trial3 = new Clinical_Trial__c(
                NCTId__c = TRIAL_3_NCTID,
                Clinical_Trial_Status__c = 'Completed'
        );

        List<Clinical_Trial__c> trials = new List<Clinical_Trial__c>{ trial, trial2, trial3 };
        insert trials;

        return trials;
    }

    public static Clinical_Trial__c getTrial() {
        return getTrialByNCTId(TRIAL_1_NCTID);
    }

    public static Clinical_Trial__c getTrial2() {
        return getTrialByNCTId(TRIAL_2_NCTID);
    }

    public static Clinical_Trial__c getTrial3() {
        return getTrialByNCTId(TRIAL_3_NCTID);
    }

    private static Clinical_Trial__c getTrialByNCTId(String nctId) {
        if(clinicalTrialsByNCTId == null) {
            clinicalTrialsByNCTId = new Map<String, Clinical_Trial__c>();

            for (Clinical_Trial__c trial : [SELECT NCTId__c FROM Clinical_Trial__c ORDER BY NCTId__c]) {
                clinicalTrialsByNCTId.put(trial.NCTId__c, trial);
            }
        }

        return clinicalTrialsByNCTId.get(nctId);
    }

    private static Map<String, Clinical_Trial__c> clinicalTrialsByNCTId;
}