/****************************************************************************************************************************************************************
* @author IVL Dev
* @date 18-July-2020
* @description Helper class to calculate create and populate CareDeterminantsForApplication .
****************************************************************************************************************************************************************/
public without sharing class TAP_CareDeterminant_Helper {
    
    public static void createCareDeterminantsForApplication(List<Application__c> newApplications) {
        
        Map<String,CareDeterminantType> determinantTypeMap = getDeterminantTypesMap();
        Map<Id,Map<Id,CareDeterminant>> accountCareDeterminantsMap = getExistingDeterminantsForAccounts(newApplications);
        
        for(Application__c application : newApplications) {
            createDeterminants(application,determinantTypeMap,
                               accountCareDeterminantsMap.get(application.Patient__c));
        }
    }
    
    public static List<Schema.FieldSetMember> getFinancialAssistanceFieldSetMembers() {
        return SObjectType.Application__c.FieldSets.Financial_Assistance_Needs.getFields();
    }
    
    private static Map<Id,Map<Id,CareDeterminant>> getExistingDeterminantsForAccounts(List<Application__c> newApplications) {
        List<Id> accountIds = new List<Id>();
        for(Application__c application : newApplications) {
            accountIds.add(application.Patient__c);
        }
        List<CareDeterminant> existingDeterminants = [SELECT id, CareDeterminantTypeId,PatientId FROM CareDeterminant 
                                                      where CareDeterminant.PatientId IN :accountIds];
        Map<Id,Map<Id,CareDeterminant>> accountCareDeterminantsMap = new Map<Id,Map<Id,CareDeterminant>>();
        for(CareDeterminant existingDeterminant : existingDeterminants) {
            if(accountCareDeterminantsMap.get(existingDeterminant.PatientId) == null) {
                accountCareDeterminantsMap.put(existingDeterminant.PatientId, new Map<Id,CareDeterminant>());
            }
            accountCareDeterminantsMap.get(existingDeterminant.PatientId).put(existingDeterminant.CareDeterminantTypeId,existingDeterminant);
        }
        return accountCareDeterminantsMap;
    }
    
    private static Map<String,CareDeterminantType> getDeterminantTypesMap() {
        List<CareDeterminantType> determinantTypes = [SELECT id,Name FROM CareDeterminantType where IsActive = true];
        Map<String,CareDeterminantType> determinantTypeMap = new Map<String,CareDeterminantType>();
        for(CareDeterminantType determinantType : determinantTypes) {
            determinantTypeMap.put(determinantType.Name, determinantType);
        }
        return determinantTypeMap;
    }
    
    private static void createDeterminants(Application__c application,Map<String,CareDeterminantType> determinantTypeMap,
                                           Map<Id,CareDeterminant> existingDeterminantsMap) {
                                               List<CareDeterminant> determinantsToInsert = new List<CareDeterminant>();
                                               for(Schema.FieldSetMember f : getFinancialAssistanceFieldSetMembers()) {
                                                   CareDeterminantType determinantType = determinantTypeMap.get(f.getLabel());
                                                   if(determinantType != null && (existingDeterminantsMap == null || existingDeterminantsMap.get(determinantType.id) == null)) {
                                                       determinantsToInsert.add(populateCareDeterminant(determinantType,application));
                                                   }
                                               }
                                               if(determinantsToInsert.size() > 0) {
                                                   Database.insert(determinantsToInsert);
                                               }
                                           }
    
    private static CareDeterminant populateCareDeterminant(CareDeterminantType determinantType,Application__c application) {
        CareDeterminant careDet = new CareDeterminant();
        careDet.CareDeterminantTypeId = determinantType.id;
        careDet.IsActive = true;
        careDet.PatientId = application.Patient__c;
        careDet.Name = determinantType.Name;
        return careDet;
    }
    
}