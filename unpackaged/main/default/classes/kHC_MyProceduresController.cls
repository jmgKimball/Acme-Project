/**
 * Created by vupneja on 10/2/2020.
 */

public with sharing class kHC_MyProceduresController {

    @AuraEnabled
    public static List<HealthCloudGA__EHRProcedure__c > getProcedures(Id currentLoggedAccount){

        List<HealthCloudGA__EHRProcedure__c> proceduresInfo = [
                SELECT  Id, HealthCloudGA__PerformedDateTime__c,Procedure_Type__c
                FROM HealthCloudGA__EHRProcedure__c
                WHERE HealthCloudGA__Account__c = :currentLoggedAccount
        ];

        return proceduresInfo;
    }

    @AuraEnabled
    public static List<HealthCloudGA__EHRProcedure__c > getEditProcedure(Id currentLoggedAccount, Id recordId) {
        List<HealthCloudGA__EHRProcedure__c> procedure = [
                SELECT HealthCloudGA__PerformedDateTime__c, Procedure_Type__c, HealthCloudGA__Account__c
                FROM HealthCloudGA__EHRProcedure__c
                WHERE HealthCloudGA__Account__c = :currentLoggedAccount AND Id = :recordId
                LIMIT 1
        ];

        if(procedure.isEmpty()) {
            throw new SObjectException('Unable to retrieve procedure');
        }
        return procedure;
    }

}