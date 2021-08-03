/**
 * Domain class for Clinical Trials object
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2020-05-28
 */
public with sharing class ClinicalTrials {
    public static final Set<String> VISIBLE_STATUSES = new Set<String>{
            'Recruiting', 'Enrolling by invitation', 'Active, not recruiting',  'Unknown Status'
    };
}