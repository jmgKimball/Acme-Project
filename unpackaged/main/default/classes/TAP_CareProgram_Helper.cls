/****************************************************************************************************************************************************************
* @author IVL Dev
* @date 18-July-2020
* @description Helper class for Care Program Object
****************************************************************************************************************************************************************/
public without sharing class TAP_CareProgram_Helper {

    /*******************************************************************************************************
    * @description Calculates poverty level based on Application information
    * @param application Application for which poverty level is to be calculated
	********************************************************************************************************/
    public static Integer calculatePovertyLevelForApplication(Application__c application) {
        Application__c app = new Application__c();
        if(application.id == null) {
            Account acc = [SELECT Id,PersonMailingStateCode FROM Account 
                           WHERE Id = :application.Patient__c];
            app.Patient__r = acc;
            
        } else {
            app = [SELECT Id,Patient__r.PersonMailingStateCode 
                   FROM Application__c 
                   WHERE Id = :application.Id];
        }
        
        app.Total_annual_Household_Income__c = application.Total_annual_Household_Income__c;
        app.No_of_People_in_the_Household__c = application.No_of_People_in_the_Household__c;
        List<Eligibility_Detail__c> incomeBasedEligibilityDetails = [SELECT Id, State__c,Per_Person_Incremental_Amount__c,Single_Person_Income_Limit__c
                                                                     FROM Eligibility_Detail__c 
                                                                     WHERE RecordType.DeveloperName = :TAP_Constants.ELIGIBILITY_DETAIL_INCOME_RECORD_TYPE 
                                                                     AND is_Active__c = true];
        return (Integer)getPovertyLevel(app,incomeBasedEligibilityDetails);
    }

    /*******************************************************************************************************
    * @description check poverty level value  for Patient, populated on Applications
    * @param accounts List of Account
	********************************************************************************************************/
    
    public static void updatePovertyLevelForApplicant(List<Account> accounts) {
        
        List<Application__c> applications = [SELECT Id,Patient__r.PersonMailingStateCode,
                                             Total_annual_Household_Income__c,No_of_People_in_the_Household__c 
                                             FROM Application__c 
                                             WHERE Patient__c IN :accounts 
                                             AND Application_Status__c IN (:TAP_Constants.APPLICATION_STATUS_NEW,
                                                                           :TAP_Constants.APPLICATION_STATUS_IN_REVIEW,
                                                                           :TAP_Constants.APPLICATION_STATUS_NEED_MORE_INFO,
                                                                           :TAP_Constants.APPLICATION_STATUS_DEFERRED)];
        List<Eligibility_Detail__c> incomeBasedEligibilityDetails = [SELECT Id, State__c,Per_Person_Incremental_Amount__c,Single_Person_Income_Limit__c
                                                                     FROM Eligibility_Detail__c 
                                                                     WHERE RecordType.DeveloperName = :TAP_Constants.ELIGIBILITY_DETAIL_INCOME_RECORD_TYPE 
                                                                     AND is_Active__c = true];
        for(Application__c app : applications) {
            app.Poverty_Level__c =  getPovertyLevel(app,incomeBasedEligibilityDetails);
        }
        Database.update(applications,false);
    }
    
    static Decimal getPovertyLevel(Application__c application,List<Eligibility_Detail__c> eligibilityDetails) {
        
        Decimal level = null;
        if(application.Patient__r != null && application.Total_annual_Household_Income__c != null && application.No_of_People_in_the_Household__c != null) {
            for(Eligibility_Detail__c detail : eligibilityDetails) {
                if(detail.State__c == application.Patient__r.PersonMailingStateCode) {
                    Decimal incomeLimit = getIncomeLimit(detail,application);
                    if(incomeLimit > 0) {
                        level = (application.Total_annual_Household_Income__c / incomeLimit) * 100;
                    }
                }
            }
        }
        
        return level;
    }

    private static Decimal getIncomeLimit(Eligibility_Detail__c detail, Application__c application) {
        Decimal incomeLimit = 0.0;
        if(detail.Per_Person_Incremental_Amount__c != null && detail.Single_Person_Income_Limit__c != null) {
            incomeLimit = detail.Single_Person_Income_Limit__c;
            if(application.No_of_People_in_the_Household__c > 1) {
                incomeLimit = ((application.No_of_People_in_the_Household__c-1) * detail.Per_Person_Incremental_Amount__c) + 
                    detail.Single_Person_Income_Limit__c;
            }
        }
        return incomeLimit;
    }

}