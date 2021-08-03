/**
 * Service methods used by the Clinical Trials application
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2020-05-21
 */
public without sharing class CTClinicalTrialsService {
    private static final Integer RECORD_LIMIT = 200;

    private static ClinicalTrialsSelector trialsSelector = new ClinicalTrialsSelector();
    private static ClinicalTrialLocationsSelector locationsSelector = new ClinicalTrialLocationsSelector();
    private static ClinicalTrialPatientsSelector patientsSelector = new ClinicalTrialPatientsSelector();

    /**
     * Load a list of active trials, optionally filtered by record limits and geo-data
     *
     * @param recordLimit optional, maximum number of trial records to return
     * @param latitude optional, current user's geo-coordinates, if present, trial location distances will be included
     * @param longitude optional, current user's geo-coordinates
     * @param maxDistance optional, if present with geo-coordinates, will filter results by distance
     *
     * @return List of maps containing 'trial', and either 'closestLocation' (if geo coords available) or 'locations'
     */
    @AuraEnabled(Cacheable=true)
    public static List<Map<String, Object>> loadTrials(Integer recordLimit, Double latitude, Double longitude,
            Integer maxDistance) {

        if(recordLimit == null) {
            recordLimit = RECORD_LIMIT;
        }

        if(latitude != null && longitude != null) {
            return loadTrialsWithLocationsWithDistance(recordLimit, latitude, longitude, maxDistance);
        }

        return loadTrialsWithLocations(recordLimit);
    }

    private static List<Map<String, Object>> loadTrialsWithLocationsWithDistance(Integer recordLimit, Double latitude,
            Double longitude, Integer maxDistance) {

        List<Clinical_Trial_Location__c> locations;
        if(maxDistance != null) {
            locations = locationsSelector.selectVisibleByDistance(latitude, longitude, maxDistance);
        } else {
            locations = locationsSelector.selectAllVisibleWithDistance(latitude, longitude);
        }

        List<Clinical_Trial_Location__c> dedupedLocations = dedupeAndTruncateLocations(locations, recordLimit);

        Set<Id> trialIds = new Set<Id>();
        for(Clinical_Trial_Location__c location : dedupedLocations) {
            trialIds.add(location.Clinical_Trial__c);
        }

        Map<Id, Clinical_Trial__c> trialsById =
                new Map<Id, Clinical_Trial__c>(trialsSelector.selectById(trialIds));

        List<Map<String, Object>> result = new List<Map<String, Object>>();
        for(Clinical_Trial_Location__c location : dedupedLocations) {
            result.add(new Map<String, Object>{
                    'trial' => trialsById.get(location.Clinical_Trial__c),
                    'closestLocation' => location
            });
        }

        return result;
    }

    private static List<Clinical_Trial_Location__c> dedupeAndTruncateLocations(
            List<Clinical_Trial_Location__c> locations, Integer recordLimit) {

        Set<Id> clinicalTrialIds = new Set<Id>();

        List<Clinical_Trial_Location__c> result = new List<Clinical_Trial_Location__c>();

        for(Clinical_Trial_Location__c location : locations) {
            if(result.size() == recordLimit) {
                break;
            }

            if(!clinicalTrialIds.contains(location.Clinical_Trial__c)) {
                result.add(location);
                clinicalTrialIds.add(location.Clinical_Trial__c);
            }
        }

        return result;
    }

    private static List<Map<String, Object>> loadTrialsWithLocations(Integer recordLimit) {
        List<Clinical_Trial__c> trials = trialsSelector.selectAllVisible(recordLimit);
        Set<Id> trialIds = new Map<Id, Clinical_Trial__c>(trials).keySet();

        List<Clinical_Trial_Location__c> locations = locationsSelector.selectByTrialId(trialIds);
        Map<Id, List<Clinical_Trial_Location__c>> locationsByTrialId = buildLocationsByTrialIdMap(locations);

        List<Map<String, Object>> result = new List<Map<String, Object>>();
        for (Clinical_Trial__c trial : trials) {
            result.add(new Map<String, Object>{
                    'trial' => trial,
                    'locations' => locationsByTrialId.get(trial.Id)
            });
        }

        return result;
    }

    private static Map<Id, List<Clinical_Trial_Location__c>> buildLocationsByTrialIdMap(
            List<Clinical_Trial_Location__c> locations) {

        Map<Id, List<Clinical_Trial_Location__c>> result = new Map<Id, List<Clinical_Trial_Location__c>>();

        for (Clinical_Trial_Location__c location : locations) {
            if (!result.containsKey(location.Clinical_Trial__c)) {
                result.put(location.Clinical_Trial__c, new List<Clinical_Trial_Location__c>());
            }

            result.get(location.Clinical_Trial__c).add(location);
        }

        return result;
    }

    /**
     * Load a specific clinical trial record and associated locations, optionally including distance information
     *
     * @param recordId Id of Clinical_Trial__c record to load
     * @param latitude optional, current user's geo-coordinates, if present, trial location distances will be included
     * @param longitude optional, current user's geo-coordinates
     *
     * @return Map containing clinical trial record under 'trial', and list of location records under 'locations'
     */
    @AuraEnabled(Cacheable=true)
    public static Map<String, Object> loadTrial(Id recordId, Double latitude, Double longitude) {
        validateTrialId(recordId);

        List<Clinical_Trial__c> trials = trialsSelector.selectByIdWithChildren(new Set<Id>{ recordId });

        if(trials.isEmpty()) {
            throw new ClinicalTrialsServiceException('Unable to load record for Id: ' + recordId);
        }

        Clinical_Trial__c trial = trials[0];

        List<Clinical_Trial_Location__c> locations;
        if(latitude != null && longitude != null) {
            locations = locationsSelector.selectByTrialIdWithDistance(new Set<Id>{ trial.Id }, latitude, longitude);
        } else {
            locations = locationsSelector.selectByTrialId(new Set<Id>{ trial.Id });
        }

        return new Map<String, Object>{
                'trial' => trial,
                'locations' => locations
        };
    }

    private static void validateTrialId(Id recordId) {
        if (recordId == null || recordId.getSobjectType() != Clinical_Trial__c.SObjectType) {
            throw new ClinicalTrialsServiceException('Invalid or null record Id provided: ' + recordId);
        }
    }

    /**
     * "Bookmarks" a Clinical Trial by creating a new Clinical Trial Patient record owned by the current user
     * @param trialId Id of Clinical_Trial__c record to create a new Clinical_Trial_Patient__c record for
     *
     * @return Id of the new Clinical_Trial_Patient__c record, or an exception if a record already exists
     */
    @AuraEnabled
    public static Id bookmarkTrial(Id trialId) {
        validateTrialId(trialId);

        List<Clinical_Trial_Patient__c> existing =
                patientsSelector.selectByTrialIdAndUserId(new Set<Id>{trialId}, new Set<Id>{ UserInfo.getUserId() });

        if(existing.size() > 0) {
            throw new ClinicalTrialsServiceException('A record already exists for this user and trial');
        }

        Clinical_Trial_Patient__c bookmark = new Clinical_Trial_Patient__c(Clinical_Trial__c = trialId);
        insert bookmark;
        return bookmark.Id;
    }

    /**
     * Removes a "Bookmark" for Clinical Trial by deleting the Clinical Trial Patient record specified
     * @param recordId Id of the Clinical_Trial_Patient__c record to delete
     */
    @AuraEnabled
    public static void removeBookmark(Id recordId) {
        Clinical_Trial_Patient__c bookmark = new Clinical_Trial_Patient__c(Id = recordId);
        delete bookmark;
        Database.emptyRecycleBin(bookmark);
    }

    private class ClinicalTrialsServiceException extends Exception {}
}