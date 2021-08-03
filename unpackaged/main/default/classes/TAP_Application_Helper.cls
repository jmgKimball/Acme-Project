/****************************************************************************************************************************************************************
* @author IVL Dev
* @date 18-July-2020
* @description Helper class to Application Trigger Handler.
****************************************************************************************************************************************************************/

public with sharing class TAP_Application_Helper {

    /***********************************************************************************************
    * @description calculate the Application Status Duration for each stage.
    * @param Application__c application of Application
    * @param String previousApplicationStatus of Application Status
    ************************************************************************************************/
    
    public static void calculateStatusDuration(Application__c application, String previousApplicationStatus) {
        if(application.Application_Status__c != previousApplicationStatus){
            if(previousApplicationStatus == TAP_Constants.APPLICATION_STATUS_NEW){
                application.New_Status_Duration__c = getUpdatedDuration(application.New_Status_Duration__c,application);
            } else if(previousApplicationStatus == TAP_Constants.APPLICATION_STATUS_IN_REVIEW){
                application.In_Review_Status_Duration__c = getUpdatedDuration(application.In_Review_Status_Duration__c,application);
            } else if(previousApplicationStatus == TAP_Constants.APPLICATION_STATUS_NEED_MORE_INFO){
                application.Need_More_Info_Status_Duration__c = getUpdatedDuration(application.Need_More_Info_Status_Duration__c,application);
            }else if(previousApplicationStatus == TAP_Constants.APPLICATION_STATUS_DEFERRED){
                application.Deferred_Status_Duration__c = getUpdatedDuration(application.Deferred_Status_Duration__c,application);
            }
            setStatusChangeDate(application);
        }
    }
    
    /***********************************************************************************************
    * @description Updates Income Guidelines review checks on Application
    * @param List<Application__c> applications of Application  
    ************************************************************************************************/
    
    public static void updateIncomeGuidelinesCheck(List<Application__c> applications) {
        List<Id> careProgramIds = new List<Id>();
        for(Application__c application : applications) {
            if(application.Care_Program__c != null) {
                careProgramIds.add(application.Care_Program__c);
            }
        }
        
        Map<Id,CareProgram> carePrograms = new Map<Id,CareProgram>([SELECT id,(SELECT id,EligibilityCriteria.id,EligibilityCriteria.Percent_Of_Poverty_Guideline__c 
                                                                               FROM CProgram_Eligibility_Rules WHERE EligibilityCriteria.Status = :TAP_Constants.ELIGIBILITY_CRITERIA_STATUS 
                                                                               AND EligibilityCriteria.Criteria_Type__c = 
                                                                               :TAP_Constants.ELIGIBILITY_CRITERIA_INCOME_BASED) 
                                                                    FROM CareProgram where Id IN :careProgramIds]);
        for(Application__c application : applications) {
            CareProgram careProgram = carePrograms.get(application.Care_Program__c);
            application.Applicant_within_income_guideline__c = incomeGuidelinesValue(careProgram,application);
        }
    }
    
    /***********************************************************************************************
    * @description copy the Email Id from Account and set it as Applicant Email
    * @param List<Application__c> applications of Application  
    ************************************************************************************************/
    
    public static void copyEmailIdFromAccount(List<Application__c> applications,Map<Id,Application__c> oldApplicationsMap){
        List<Id> accountIds = new List<Id>();
        for(Application__c application : applications){
            if(oldApplicationsMap.get(application.Id) == null 
               || application.Patient__c != oldApplicationsMap.get(application.Id).Patient__c){
                //accountIds.add(application.Id);
                  accountIds.add(application.Patient__c);
            }
        }
        if(accountIds.size() > 0) {
            Map<Id,Account> accountMap  = new Map<Id,Account>(
                                        [Select Id, PersonEmail from Account where Id = :accountIds]);
            for(Application__c application : applications){
                if(accountMap.get(application.Patient__c) != null){
                    application.Applicant_Email__c = accountMap.get(application.Patient__c).PersonEmail;
                }
            }
        }
    }
    
    /***********************************************************************************************
    * @description set status change date of Application to Today's date
    * @param application Application  
    ************************************************************************************************/
    
    public static void setStatusChangeDate(Application__c application) {
        application.Status_Change_Date__c = System.today();
    }

    /***********************************************************************************************
    * @description finds Incomlete review checks on Application and returns it as a list of comments.
    * @param recordId which is Application ID 
    * @return list of comments  
    ************************************************************************************************/
    public static List<String> getIncompleteReviewChecks(Id recordId) {
        Application__c application = [SELECT Id, Income_Verification_is_Valid__c, Type_of_Income_Verification_Provided__c, 
                                      Physician_confirms_patient_inactive_tre__c, Poverty_Level__c, 
                                      Applicant_within_income_guideline__c, Applicant_resides_US_Territory__c, 
                                      Applicant_has_no_award_in_last_12months__c 
                                      FROM Application__c WHERE Id = :recordId];

        List<String> comments = new List<String>();
        if(application.Income_Verification_is_Valid__c == TAP_Constants.NO) {
            comments.add(Label.Application_Income_Verification_Invalid);
        } else if(String.isBlank(application.Income_Verification_is_Valid__c)) {
            comments.add(Label.Application_Income_Verification_Not_Provided);
        }
        if(application.Physician_confirms_patient_inactive_tre__c == TAP_Constants.NO 
            || String.isBlank(application.Physician_confirms_patient_inactive_tre__c)) {
            comments.add(Label.Application_Active_Breast_Cancer_No);
        }
        if(application.Applicant_within_income_guideline__c == TAP_Constants.NO) {
            comments.add(Label.Application_Income_Within_Guidelines_No);
        } else if(application.Applicant_within_income_guideline__c == TAP_Constants.UNKNOWN 
                  || application.Applicant_within_income_guideline__c == Label.Application_Income_Guideline 
                  || String.isBlank(application.Applicant_within_income_guideline__c)) {
            comments.add(Label.Application_Income_Details_No);
        }
        if(application.Applicant_resides_US_Territory__c == TAP_Constants.NO) {
            comments.add(Label.Application_US_Resident_No);
        }
        if(application.Applicant_has_no_award_in_last_12months__c == TAP_Constants.NO) {
            comments.add(Label.Application_Award_In_Last_12_Months_Yes);
        }
        return comments;
    }
    
    private static String incomeGuidelinesValue(CareProgram careProgram, Application__c application) {
        String incomeGuidelinesCheckValue = TAP_Constants.NO;
        if(careProgram == null) {
            incomeGuidelinesCheckValue = Label.Application_Income_Guideline_for_Care_Program ; 
        } else if(careProgram.CProgram_Eligibility_Rules == null || careProgram.CProgram_Eligibility_Rules.size() == 0) {
            incomeGuidelinesCheckValue = Label.Application_No_Income_Guideline_On_Care_Program ; 
        } else if(application.Poverty_Level__c == null || application.Poverty_Level__c == 0) {
            incomeGuidelinesCheckValue = Label.Application_Income_Guideline ;
        } else {
            if (careProgram.CProgram_Eligibility_Rules.get(0).EligibilityCriteria.Percent_Of_Poverty_Guideline__c > application.Poverty_Level__c) {
                incomeGuidelinesCheckValue = TAP_Constants.YES;
            }
        }
        return incomeGuidelinesCheckValue;
    }
    private static Integer getUpdatedDuration(Decimal duration,Application__c application) {
        Integer newDuration = (Integer)(duration != null ? duration : 0);
        if(application.Status_Change_Date__c != null) {
            return newDuration + application.Status_Change_Date__c.date().daysBetween(System.TODAY());
        }
       return newDuration;
    }
}