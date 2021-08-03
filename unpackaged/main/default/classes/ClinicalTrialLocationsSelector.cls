/**
 * Selector for Clinical Trial Location records
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2020-05-28
 */
public inherited sharing class ClinicalTrialLocationsSelector {

    public List<Clinical_Trial_Location__c> selectByTrialId(Set<Id> trialIds) {
        return [
                SELECT Trial_Location_Key__c, Clinical_Trial__c, Geocode__Latitude__s, Geocode__Longitude__s,
                        Facility__c, Street_Address__c, City__c, State__c, Country__c, Zip__c
                FROM Clinical_Trial_Location__c
                WHERE Clinical_Trial__c IN :trialIds
        ];
    }

    public List<Clinical_Trial_Location__c> selectByTrialIdWithDistance(Set<Id> trialIds, Double latitude,
            Double longitude) {

        return [
                SELECT Trial_Location_Key__c, Clinical_Trial__c, Geocode__Latitude__s, Geocode__Longitude__s,
                        DISTANCE(Geocode__c, GEOLOCATION(:latitude, :longitude), 'mi') dist,
                        Facility__c, Street_Address__c, City__c, State__c, Country__c, Zip__c
                FROM Clinical_Trial_Location__c
                WHERE Clinical_Trial__c IN :trialIds
                ORDER BY DISTANCE(Geocode__c, GEOLOCATION(:latitude, :longitude), 'mi') NULLS LAST
        ];
    }
    public List<Clinical_Trial_Location__c> selectVisibleByDistance(Double latitude, Double longitude,
            Integer maxDistance) {

        return [
                SELECT Trial_Location_Key__c, Clinical_Trial__c, Geocode__Latitude__s, Geocode__Longitude__s,
                        DISTANCE(Geocode__c, GEOLOCATION(:latitude, :longitude), 'mi') dist
                FROM Clinical_Trial_Location__c
                WHERE Clinical_Trial__r.Clinical_Trial_Status__c IN :ClinicalTrials.VISIBLE_STATUSES
                AND DISTANCE(Geocode__c, GEOLOCATION(:latitude, :longitude), 'mi') < :maxDistance
                ORDER BY DISTANCE(Geocode__c, GEOLOCATION(:latitude, :longitude), 'mi') NULLS LAST
        ];
    }

    public List<Clinical_Trial_Location__c> selectAllVisibleWithDistance(Double latitude, Double longitude) {

        return [
                SELECT Trial_Location_Key__c, Clinical_Trial__c, Geocode__Latitude__s, Geocode__Longitude__s,
                        DISTANCE(Geocode__c, GEOLOCATION(:latitude, :longitude), 'mi') dist
                FROM Clinical_Trial_Location__c
                WHERE Clinical_Trial__r.Clinical_Trial_Status__c IN :ClinicalTrials.VISIBLE_STATUSES
                ORDER BY DISTANCE(Geocode__c, GEOLOCATION(:latitude, :longitude), 'mi') NULLS LAST
        ];
    }

}