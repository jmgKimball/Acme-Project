/****************************************************************************************************************************************************************
* @author IVL Dev
* @date 21-May-2020
* @description Controller for Lightning components on Application Object
****************************************************************************************************************************************************************/

public with sharing class TAP_Application_Ctlr {
    
    /*******************************************************************************************************
    * @description checks if user have edit access for Applications
    * @return Map with key String and value as Boolean it return true if user have Edit access
    ********************************************************************************************************/
    @auraEnabled
    public static Map<String,Boolean> checkAccessOnApplication() {
        return new Map<String,Boolean>{'hasEditAccess' => Schema.sObjectType.Application__c.IsUpdateable()};
    }
    
    /*******************************************************************************************************
    * @description checks if user have edit access for Applications		
    * @param applicationIds Id of Application Id
    * @return Map with key String and value as Boolean it return true if user have Edit access
	********************************************************************************************************/
    
    @auraEnabled
    public static Map<String,Boolean> checkAccessesOnApplication(Id recordId) {
        Boolean isEditable = false;
        Boolean isAdmin = false;
        for(PermissionSetAssignment psa: [SELECT PermissionSet.PermissionsModifyAllData FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()]) {
            isAdmin |= psa.PermissionSet.PermissionsModifyAllData;
        }
        if(isAdmin) {
            isEditable = true;
        } else if(Schema.sObjectType.Application__c.IsUpdateable()) {
            isEditable = true;
            Application__c application = [Select Id,Application_Status__c from Application__c where Id =:recordId LIMIT 1];
            if(application.Application_Status__c == TAP_Constants.APPLICATION_STATUS_APPROVED) {
                isEditable = false;
            }
        }
        return new Map<String,Boolean>{'hasEditAccess' => isEditable,'isAdmin' => isAdmin};
    }
    
    /***************************************************************************************************************************
    * @description checks list of Suggested Care Programs Care Programs and Existing Programs for Application 		
    * @param applicationIds Id of Application Id
    * @return Map with key String and value as List of list of Suggested Care Programs Care Programs and Existing Programs 
	*****************************************************************************************************************************/
    
    @auraEnabled
    public static Map<String,List<CareProgram>> loadPrograms(Id recordId) {

        Application__c application = [SELECT Id, Care_Program__c, (SELECT Care_Program__c FROM Suggested_Program__r)  
                                    FROM Application__c WHERE Id = :recordId LIMIT 1];
        String activeStatus = TAP_Constants.CARE_PROGRAM_STATUS_ACTIVE;
        Id careProgramId = application.Care_Program__c;
        String queryString = 'SELECT Id,name,Care_Program_Type__c,Status,Remaining_Amount__c,Remaining_monthly_Balance__c '+
                                'FROM CareProgram Where Status = :activeStatus';
        if(careProgramId != null) {
            queryString += ' OR Id = :careProgramId';
        }
        Map<Id,CareProgram> allCareProgramsMap = new Map<Id,CareProgram>((List<CareProgram>)Database.query(queryString));
        List<CareProgram> existingProgramsOnApplication = null;
        if(careProgramId != null) {
            existingProgramsOnApplication = new List<CareProgram> {allCareProgramsMap.get(application.Care_Program__c)};
        }
        List<CareProgram> suggestedCarePrograms = new List<CareProgram>();
        if(application.Suggested_Program__r != null) {
            for(Suggested_Care_Program__c suggestedCareProgram : application.Suggested_Program__r) {
                if(allCareProgramsMap.get(suggestedCareProgram.Care_Program__c) != null) {
                    suggestedCarePrograms.add(allCareProgramsMap.get(suggestedCareProgram.Care_Program__c));
                }
            }
        }
               
        return new Map<String,List<CareProgram>>{'suggested' => suggestedCarePrograms,'all' => allCareProgramsMap.values(),
                                                 'existing' => existingProgramsOnApplication};
        
    }
    
    /*******************************************************************************************************
    * @description checks  Care Programs is in Suggested Care Programs for Application 		
    * @param  recordId of Application Id and careProgramId of CareProgram Id
    * @return Boolean, YES- if Care Program in Suggested Care Program for Application
	********************************************************************************************************/
    
    @auraEnabled
    public static Boolean isCareProgramSuggested(Id recordId, Id careProgramId) {
        return TAP_SuggestedProgramHelper.isSelectedCareProgramSuggested(recordId,careProgramId);
    }
    
    /*******************************************************************************************************
     * @description checks other Applications related to Patient(PersonAccount) 		
     * @param  recordId of Application Id 
     * @return List of other Applications for that Patient(PersonAccount)
	********************************************************************************************************/
    
    @auraEnabled
    public Static List<Application__c> relatedApplicationlist(String recordId){
        Application__c application = [Select Patient__c from Application__c where Id =:recordId LIMIT 1];
        return [Select Id,Name,Application_Status__c,Application_Date__c,Payment_Status__c,LastModifiedDate,Payment_Date__c 
                from Application__c Where Id != :recordId 
                AND Patient__c = :application.Patient__c ORDER BY LastModifiedDate DESC limit 5];
    }

    /*******************************************************************************************************
    * @description checks status of application	
    * @param  recordId of Application Id 
    * @return String which is status of Application
    ********************************************************************************************************/
    
    @auraEnabled    
    public static String initialValue( String recordId){
        String result;
        Application__c app = [Select Id,Application_Status__c from Application__c where Id =:recordId];
        if(app.Application_Status__c!= null){
            result= app.Application_Status__c;
        }
        return result;
    }
    
    /*******************************************************************************************************
    * @description checks if status of Application is rejected 	then populate the reason in Rich text Area
    * @param recordId of Application Id 
    * @return String which is rejection reason of Application
    ********************************************************************************************************/
    
    @AuraEnabled
    public static String calculateRejectionComment(Id recordId) {
        String rejectionComment = '<html><body><ul>';
        for(String comment : TAP_Application_Helper.getIncompleteReviewChecks(recordId)) {
            rejectionComment += '<li>'+comment+'</li>';
        }
        rejectionComment += '</ul></body></html>';
        return rejectionComment;
    }
}