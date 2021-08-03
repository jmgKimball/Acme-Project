/**
 * Selector for Contact records
 * 
 * @author Nitin Chandwani, Traction on Demand
 * @date 2020-08-31
 */
public with sharing class ContactSelector {
    public List<Contact> selectByNpiIds( Set<String> npiIds ){
        return [
                SELECT Id 
                From Contact 
                WHERE NPI_ID__c IN: npiIds 
            ];
    }
}