/**
 * Selector for Medication records
 * 
 * @author Nitin Chandwani, Traction on Demand
 * @date 2020-09-03
 */
public with sharing class MedicationSelector {
    public List<Medication__c> selectAll(){
        return [
                SELECT Id, Name, RXCUI__c, Product_NDC__c, Brand_Name__c, 
                Side_Effects_Statement__c, RXCUI_Possible_Matches__c, 
                Update_Medication_Information__c , Med_Name__c
                FROM Medication__c
                ORDER BY Name
            ];
    }

    public List<Medication__c> selectByName( String name ){
        return [
                SELECT Id, Name, RXCUI__c, Product_NDC__c, Brand_Name__c, 
                Side_Effects_Statement__c, RXCUI_Possible_Matches__c, 
                Update_Medication_Information__c , Med_Name__c
                FROM Medication__c
                WHERE Med_Name__c =: name
                LIMIT 1 
            ];
    }
}