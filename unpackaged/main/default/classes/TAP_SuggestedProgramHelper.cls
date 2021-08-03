/***************************************************************************************************************************************************************
* @author IVL Dev
* @date 20-May-2020
* @description Helper class to calculate Suggested Care Programs based on Application and Patient information.
***************************************************************************************************************************************************************/
public without sharing class TAP_SuggestedProgramHelper {
    
    static List<Application__c> applications = new List<Application__c>();
    static Map<String,List<Application__c>> applicationTypeMap = new Map<String,List<Application__c>>();
    static Map<String,List<CareProgram>> careProgramTypeMap = new Map<String,List<CareProgram>>();
    static Map<String,List<CareProgram>> careProgramTypeNoCriteriaMap = new Map<String,List<CareProgram>>();
    Static Map<Id,List<Id>> careProgramRelatedToApplicationMap = new Map<Id,List<Id>>();
    static Map<Id,List<Eligibility_Detail__c>> criteriaDetailsMap = new Map<Id,List<Eligibility_Detail__c>>();
    static List<Eligibility_Detail__c> incomeEligDetails = new List<Eligibility_Detail__c>();
    static Map<String,Set<Id>> zipCriteriaMap = new Map<String,Set<Id>>();
    static Map<Id,List<Id>> existingCareProgramsOnApplicationMap = new Map<Id,List<Id>>();
    static Map<Id,List<Suggested_Care_Program__c>> existingSuggestedProgramsMap = new Map<Id,List<Suggested_Care_Program__c>>();
    static List<Suggested_Care_Program__c> suggestedCareProgramsToInsert = new List<Suggested_Care_Program__c>();
    static List<Id> suggestedCareProgramsToDelete = new List<Id>();
    
    /*******************************************************************************************************
    * @description Calculates Suggested Care Programs for Applications
    * @param applicationIds List of Application Ids
    * @return Map with key Application Id and value as list of Suggested Care Program Ids
    ********************************************************************************************************/
    public static Map<Id,List<Id>> calculateSuggestedPrograms(List<Id> applicationIds) {
        
        applications = [SELECT Id,Application_Type__c,Patient__r.PersonMailingPostalCode,Care_Program__c,
                        Patient__r.PersonMailingStateCode,
                        Patient__r.PersonContact.MailingCountryCode,
                        Patient__r.Payment_Date__c,
                        Applicant_has_no_award_in_last_12months__c,
                        Physician_confirms_patient_inactive_tre__c,
                        Is_patient_in_active_treatment__c,
                        Applicant_resides_US_Territory__c,
                        Poverty_Level__c,
                        Total_annual_Household_Income__c,No_of_People_in_the_Household__c FROM Application__c 
                        WHERE Id IN :applicationIds AND Application_Status__c != :TAP_Constants.APPLICATION_STATUS_APPROVED];
        if(applications.size() > 0) {
            calculateSuggestedPrograms();
        }
        
        return careProgramRelatedToApplicationMap;
    }
    
    /*******************************************************************************************************
    * @description Calculates Suggested Care Programs for Applications related to Accounts
    * @param accounts List of Accounts
    * @return Map with key Application Id and value as list of Suggested Care Program Ids
    ********************************************************************************************************/
    public static Map<Id,List<Id>> calculateSuggestedPrograms(List<Account> accounts) {
        
        applications = [SELECT Id,Application_Type__c,Patient__r.PersonMailingPostalCode,Care_Program__c,
                        Patient__r.PersonMailingStateCode,
                        Patient__r.PersonContact.MailingCountryCode,
                        Patient__r.Payment_Date__c,
                        Applicant_has_no_award_in_last_12months__c,
                        Physician_confirms_patient_inactive_tre__c,
                        Is_patient_in_active_treatment__c,
                        Applicant_resides_US_Territory__c,
                        Poverty_Level__c,
                        Total_annual_Household_Income__c,No_of_People_in_the_Household__c FROM Application__c 
                        WHERE Patient__c IN :accounts 
                        AND Application_Status__c IN (:TAP_Constants.APPLICATION_STATUS_NEW,
                                                      :TAP_Constants.APPLICATION_STATUS_IN_REVIEW,
                                                      :TAP_Constants.APPLICATION_STATUS_NEED_MORE_INFO,
                                                      :TAP_Constants.APPLICATION_STATUS_DEFERRED)];
        if(applications.size() > 0) {
            calculateSuggestedPrograms();
        }
        
        return careProgramRelatedToApplicationMap;
    }
    
    /*******************************************************************************************************
    * @description Delete Suggested Care Programs for Applications
    * @param applicationIds List of Application Ids
    * @return List with  Application
    ********************************************************************************************************/
    
    public static void deleteSuggestedCarePrograms(List<Application__c> applications) {
        
        List<Suggested_Care_Program__c> suggestedCarePrograms = [SELECT Id from Suggested_Care_Program__c 
                                                                 WHERE Application__c IN :applications];
        Database.delete(suggestedCarePrograms,false);
    }
    
    /*******************************************************************************************************
    * @description check whether Suggested Care Programs are available for Applications
    * @param applicationId which is  Application Id and  careProgramId which is careProgram Id
    * @return Boolean with  YES - suggested care program is available , NO -  suggested care program not available
    ********************************************************************************************************/
    
    public static Boolean isSelectedCareProgramSuggested(Id applicationId, Id careProgramId) {
        
        List<Suggested_Care_Program__c> suggestedCarePrograms = [SELECT Id from Suggested_Care_Program__c 
                                                                 WHERE Application__c = :applicationId AND Care_Program__c = :careProgramId];
        return suggestedCarePrograms.size() > 0;
    }
    
    private static void calculateSuggestedPrograms() {
        for(Application__c application : applications) {
            if (applicationTypeMap.get(application.Application_Type__c) == null) {
                applicationTypeMap.put(application.Application_Type__c,new List<Application__c>());
            }
            applicationTypeMap.get(application.Application_Type__c).add(application);
        }
        
        getCareProgramsForApplicationTypes(applicationTypeMap.keySet());
        
        getExistingSuggestedCarePrograms(applications);
        
        calculateCarePrograms();
    }
    
    private static void calculateCarePrograms() {
        
        for(Application__c application : applications) {
            List<CareProgram> carePrograms = careProgramTypeMap.get(application.Application_Type__c);
            if(carePrograms != null) {
                for(CareProgram careProgram : carePrograms) {
                    if(hasMatchingCriterias(application,careProgram.CProgram_Eligibility_Rules)) {
                        //check if suggested program for this care program and application exists. If not create one
                        createSuggestedProgram(application,careProgram);
                    } else {
                        // delete if present
                        removeSuggestedProgramIfPresent(application,careProgram);
                    }
                }
            }
        }
        
        
        Database.insert(suggestedCareProgramsToInsert,false);
        Database.delete(suggestedCareProgramsToDelete,false);
    }
    
    static Boolean hasMatchingCriterias(Application__c application,List<CareProgramEligibilityRule> rules) {
        //if (eligibilityCriteria.size() > 0)
        //p = eligibilityCriteria[0].Id;                                                          
        if(rules != null) {
            for(CareProgramEligibilityRule rule : rules) {
                EnrollmentEligibilityCriteria criteria = rule.EligibilityCriteria;
                List<Eligibility_Detail__c> eligibilityDetails = criteriaDetailsMap.get(criteria.Id);
                if(!hasMatchingCriteria(application,criteria,eligibilityDetails)) {
                    return false;
                }
            }
        }
        return true;
        
    }
    
    static Boolean hasMatchingCriteria(Application__c application,EnrollmentEligibilityCriteria criteria,List<Eligibility_Detail__c> eligibilityDetails) {
        Boolean isMatching = false;
        if(criteria.Criteria_Type__c == TAP_Constants.ELIGIBILITY_CRITERIA_ZIP_BASED) {
            isMatching = hasMatchingZIPCriteria(application,criteria);
        } else if(criteria.Criteria_Type__c == TAP_Constants.ELIGIBILITY_CRITERIA_INCOME_BASED) {
            isMatching = hasMatchingIncomeCriteria(application,criteria,incomeEligDetails);
        } else if(criteria.Criteria_Type__c == TAP_Constants.ELIGIBILITY_CRITERIA_USA_RESIDENT) {
            isMatching = hasMatchingUSResidentCriteria(application,criteria,eligibilityDetails);
        } else if(criteria.Criteria_Type__c == TAP_Constants.ELIGIBILITY_CRITERIA_NO_AWARD ) {
            isMatching = hasMatchingNoAwardCriteria(application,criteria,eligibilityDetails);
        } else if(criteria.Criteria_Type__c == TAP_Constants.ELIGIBILITY_CRITERIA_ACTIVE_TREATMENT) {
            isMatching = hasMatchingActiveTreatmentCriteria(application,criteria,eligibilityDetails);
        }
        return isMatching;
    }
    
    static Boolean hasMatchingZIPCriteria(Application__c application,EnrollmentEligibilityCriteria criteria) {
        
        if(application.Patient__r != null && zipCriteriaMap.get(application.Patient__r.PersonMailingPostalCode) != null) {
            return zipCriteriaMap.get(application.Patient__r.PersonMailingPostalCode).contains(criteria.Id);
        }
        return false;
    }
    
    static Boolean hasMatchingIncomeCriteria(Application__c application,EnrollmentEligibilityCriteria criteria,List<Eligibility_Detail__c> eligibilityDetails) {
        
        return application.Poverty_Level__c != null && criteria.Percent_Of_Poverty_Guideline__c >= application.Poverty_Level__c;
        
    }
    
    static Boolean hasMatchingUSResidentCriteria(Application__c application,EnrollmentEligibilityCriteria criteria,List<Eligibility_Detail__c> eligibilityDetails) {
        
        return application.Patient__r.PersonContact.MailingCountryCode == TAP_Constants.COUNTRY_CODE_US;
    }
    
    static Boolean hasMatchingNoAwardCriteria(Application__c application,EnrollmentEligibilityCriteria criteria,List<Eligibility_Detail__c> eligibilityDetails) {
        
        Date paymentdate = Date.valueof(application.Patient__r.Payment_Date__c);
        Date today = Date.valueof(System.today());
        return paymentdate != null ? (paymentdate.monthsBetween(today) >= criteria.No_Income_in_Last_N_months__c) : true;
        
        
    }
    
    static Boolean hasMatchingActiveTreatmentCriteria(Application__c application,EnrollmentEligibilityCriteria criteria,List<Eligibility_Detail__c> eligibilityDetails) {
        
        return application.Is_patient_in_active_treatment__c == TAP_Constants.YES;
    }
    
    static void createSuggestedProgram(Application__c application,CareProgram careProgram) {
        
        if (careProgramRelatedToApplicationmap.get(application.Id) == null) {
            careProgramRelatedToApplicationmap.put(application.Id,new List<Id>());
        }
        careProgramRelatedToApplicationmap.get(application.Id).add(careProgram.id);
        if(existingCareProgramsOnApplicationMap.get(application.Id) == null || !existingCareProgramsOnApplicationMap.get(application.Id).contains(careProgram.Id)) {
            
            suggestedCareProgramsToInsert.add(populateSuggestedCareProgram(application,careProgram));
        }
    }
    
    static void removeSuggestedProgramIfPresent(Application__c application,CareProgram careProgram) {
        
        if(existingCareProgramsOnApplicationMap.get(application.Id) != null && existingCareProgramsOnApplicationMap.get(application.Id).contains(careProgram.Id)) {
            for(Suggested_Care_Program__c suggestedCP : existingSuggestedProgramsMap.get(application.Id)) {
                if(suggestedCP.Care_Program__c == careProgram.Id) {
                    suggestedCareProgramsToDelete.add(suggestedCP.Id);
                }
            }
        }
    }
    
    static Suggested_Care_Program__c populateSuggestedCareProgram(Application__c application,CareProgram careProgram) {
        
        Suggested_Care_Program__c suggestedCareProgram = new Suggested_Care_Program__c();
        suggestedCareProgram.Care_Program__c = careProgram.Id;
        suggestedCareProgram.Application__c = application.Id;
        suggestedCareProgram.Name = careProgram.name;
        return suggestedCareProgram;
    }
    
    static void getCareProgramsForApplicationTypes(Set<String> types) {
        
        List<CareProgram> carePrograms = [SELECT id,name,Care_Program_Type__c,
                                          (SELECT id,name,EligibilityCriteria.id,EligibilityCriteria.Criteria_Type__c,
                                           EligibilityCriteria.Percent_Of_Poverty_Guideline__c,EligibilityCriteria.No_Income_in_Last_N_months__c,EligibilityCriteria.Status 
                                           FROM CProgram_Eligibility_Rules) FROM CareProgram 
                                          WHERE Status = :TAP_Constants.CARE_PROGRAM_STATUS_ACTIVE AND Care_Program_Type__c IN :types];
        List<Id> eligCriterias = new List<Id>();
        for(CareProgram careProgram :carePrograms) {
            
            if(careProgram.CProgram_Eligibility_Rules != null) {
                if (careProgramTypeMap.get(careProgram.Care_Program_Type__c) == null) {
                    careProgramTypeMap.put(careProgram.Care_Program_Type__c,new List<CareProgram>());
                }
                careProgramTypeMap.get(careProgram.Care_Program_Type__c).add(careProgram);
                for(CareProgramEligibilityRule rule : careProgram.CProgram_Eligibility_Rules) {
                    eligCriterias.add(rule.EligibilityCriteria.id);
                }
            } else {
                if (careProgramTypeNoCriteriaMap.get(careProgram.Care_Program_Type__c) == null) {
                    careProgramTypeNoCriteriaMap.put(careProgram.Care_Program_Type__c,new List<CareProgram>());
                }
                careProgramTypeNoCriteriaMap.get(careProgram.Care_Program_Type__c).add(careProgram);
            }
        }
        
        getEligibilityDetailsForCriterias(eligCriterias);
    }
    
    public static void getEligibilityDetailsForCriterias(List<Id> criteriaIds) {
        
        List<Eligibility_Detail__c> eligibilityDetails = [SELECT Id, ZIP_Code__c,Eligibility_Criteria__c,RecordType.DeveloperName,State__c,
                                                          Per_Person_Incremental_Amount__c,Single_Person_Income_Limit__c
                                                          FROM Eligibility_Detail__c 
                                                          WHERE Eligibility_Criteria__c IN :criteriaIds 
                                                          OR (RecordType.DeveloperName = :TAP_Constants.ELIGIBILITY_DETAIL_INCOME_RECORD_TYPE AND is_Active__c = true)];
        
        for(Eligibility_Detail__c eligibilityDetail : eligibilityDetails) {
            if (criteriaDetailsMap.get(eligibilityDetail.Eligibility_Criteria__c) == null) {
                criteriaDetailsMap.put(eligibilityDetail.Eligibility_Criteria__c,new List<Eligibility_Detail__c>());
            }
            criteriaDetailsMap.get(eligibilityDetail.Eligibility_Criteria__c).add(eligibilityDetail);
            if(eligibilityDetail.RecordType.DeveloperName == TAP_Constants.ELIGIBILITY_DETAIL_INCOME_RECORD_TYPE) {
                incomeEligDetails.add(eligibilityDetail);
            }
            if (zipCriteriaMap.get(eligibilityDetail.ZIP_Code__c) == null) {
                zipCriteriaMap.put(eligibilityDetail.ZIP_Code__c, new Set<Id>());
            }
            zipCriteriaMap.get(eligibilityDetail.ZIP_Code__c).add(eligibilityDetail.Eligibility_Criteria__c);
        }
    }
    
    static void getExistingSuggestedCarePrograms(List<Application__c> applications) {
        
        List<Suggested_Care_Program__c> existingSuggestedPrograms = [SELECT id,Application__c,Care_Program__c 
                                                                     FROM Suggested_Care_Program__c 
                                                                     WHERE Application__c IN :applications];
        for(Suggested_Care_Program__c suggProgs : existingSuggestedPrograms) {
            if (existingCareProgramsOnApplicationMap.get(suggProgs.Application__c) == null) {
                existingCareProgramsOnApplicationMap.put(suggProgs.Application__c, new List<Id>());
            }
            existingCareProgramsOnApplicationMap.get(suggProgs.Application__c).add(suggProgs.Care_Program__c);
            if (existingSuggestedProgramsMap.get(suggProgs.Application__c) == null) {
                existingSuggestedProgramsMap.put(suggProgs.Application__c, new List<Suggested_Care_Program__c>());
            }
            existingSuggestedProgramsMap.get(suggProgs.Application__c).add(suggProgs);
        }
    }
}