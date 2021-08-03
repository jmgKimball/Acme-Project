/**
 * Test Utility class to hold KHC related objects and methods
 * 
 * @author Nitin Chandwani, Traction on Demand
 * @date 2020-09-10
 */
@isTest
public class KHC_TestUtility {
    
    public static List<Medication__c> insertMedications( String medicationName, Integer count, Boolean performDml ){
        List<Medication__c> medications = new List<Medication__c>();
        for( Integer i = 0; i < count; i ++ ){
            medications.add( insertMedication( medicationName + i, false ) );
        }
        if( performDml ){
            INSERT medications;
        }
        return medications;
    }

    public static Medication__c insertMedication( String medicationName, Boolean performDml ){
        Medication__c medication = new Medication__c();
        medication.Med_Name__c  = medicationName;
        if( performDml ){
            INSERT medication;
        }
        return medication;
    }

    public static HealthCloudGA__EhrMedicationStatement__c insertEhrMedicationStatement( Id medicationId, Id personAccountId, Boolean performDml ){
        HealthCloudGA__EhrMedicationStatement__c medicationStatement = new HealthCloudGA__EhrMedicationStatement__c();
        medicationStatement.Medication__c = medicationId;
        medicationStatement.HealthCloudGA__Account__c = personAccountId;
        if( performDml ){
            INSERT medicationStatement;
        }
        return medicationStatement;
    }

    public static List<HealthCloudGA__EhrImmunization__c> insertEhrImmunizations( Id personAccountId, String immunizationType, Integer count, Boolean performDml){
        List<HealthCloudGA__EhrImmunization__c> immunizations = new List<HealthCloudGA__EhrImmunization__c>();
        for( Integer i = 0; i < count; i ++ ){
            immunizations.add( insertEhrImmunization( personAccountId, immunizationType, false ) );
        }
        if( performDml ){
            INSERT immunizations;
        }
        return immunizations;
    }

    public static HealthCloudGA__EhrImmunization__c insertEhrImmunization( Id personAccountId, String immunizationType, Boolean performDml ){
        HealthCloudGA__EhrImmunization__c immunization = new HealthCloudGA__EhrImmunization__c();
        immunization.HealthCloudGA__DateAdministered__c = System.today();
        immunization.HealthCloudGA__Account__c = personAccountId;
        immunization.Immunization_Type__c = immunizationType;
        if( performDml ){
            INSERT immunization;
        }
        return immunization;
    }

    public static List<HealthCloudGA__ReciprocalRole__c> insertReciprocalRoles( Map<String,String> rolesMap, Boolean performDml ){
        List<HealthCloudGA__ReciprocalRole__c> reciprocalRoles = new List<HealthCloudGA__ReciprocalRole__c>();
        for( String role : rolesMap.keySet() ){
            reciprocalRoles.add( insertReciprocalRole( role, rolesMap.get( role ), false ) );
        }
        if( performDml ){
            INSERT reciprocalRoles;
        }
        return reciprocalRoles;
    }

    public static HealthCloudGA__ReciprocalRole__c insertReciprocalRole( String roleName, String inverseRoleName, Boolean performDml ){
        HealthCloudGA__ReciprocalRole__c reciprocalRole = new HealthCloudGA__ReciprocalRole__c();
        reciprocalRole.Name = roleName;
        reciprocalRole.RecordTypeId = Schema.SObjectType.HealthCloudGA__ReciprocalRole__c.getRecordTypeInfosByName().get('Contact Role').getRecordTypeId();
        reciprocalRole.HealthCloudGA__InverseRole__c = inverseRoleName;
        if( performDml ){
            INSERT reciprocalRole;
        }
        return reciprocalRole;
    }

    public static HealthCloudGA__ContactContactRelation__c insertConConRel( Id relContactId, Id conId, Id roleId , Boolean performDml ){
        HealthCloudGA__ContactContactRelation__c conConRel = new HealthCloudGA__ContactContactRelation__c();
        conConRel.HealthCloudGA__Role__c = roleId;
        conConRel.HealthCloudGA__Contact__c = conId;
        conConRel.HealthCloudGA__RelatedContact__c = relContactId;
        if( performDml ){
            INSERT conConRel;
        }
        return conConRel;
    }

    public static HealthCloudGA__EhrAllergyIntolerance__c insertEhrAllergyIntolerance( Id personAccountId, String allergyType, String reactionType, Boolean performDml ){

        HealthCloudGA__EhrAllergyIntolerance__c allergyIntolerance = new HealthCloudGA__EhrAllergyIntolerance__c();

        allergyIntolerance.Allergy_Type__c = allergyType;
        allergyIntolerance.Allergen_Name__c = 'Test Allergy';
        allergyIntolerance.Reaction_Type__c = ReactionType;
        allergyIntolerance.HealthCloudGA__Reaction__c = 'Test Allergy';
        allergyIntolerance.Severity__c = 'Mild';
        allergyIntolerance.HealthCloudGA__Account__c = personAccountId;

        if( performDml ){
            INSERT allergyIntolerance;
        }
        return allergyIntolerance;
    }

    public static List<HealthCloudGA__EhrAllergyIntolerance__c> insertEhrAllergyIntolerances( Id personAccountId, String allergyType,  String reactionType, Integer count, Boolean performDml){
        List<HealthCloudGA__EhrAllergyIntolerance__c> allergies = new List<HealthCloudGA__EhrAllergyIntolerance__c>();
        for( Integer i = 0; i < count; i ++ ){
            allergies.add( insertEhrAllergyIntolerance( personAccountId, allergyType, reactionType,false ) );
        }
        if( performDml ){
            INSERT allergies;
        }
        return allergies;
    }

    public static List<HealthCloudGA__EhrEncounter__c> insertEhrEncounters( Id personAccountId, String providerName, Integer count, Boolean performDml){
        List<HealthCloudGA__EhrEncounter__c> encounters = new List<HealthCloudGA__EhrEncounter__c>();
        for( Integer i = 0; i < count; i ++ ){
            encounters.add( insertEhrEncounter( personAccountId, providerName, false ) );
        }
        if( performDml ){
            INSERT encounters;
        }
        return encounters;
    }

    public static HealthCloudGA__EhrEncounter__c insertEhrEncounter( Id personAccountId, String providerName, Boolean performDml ){
        HealthCloudGA__EhrEncounter__c encounter = new HealthCloudGA__EhrEncounter__c();
        encounter.Appointment_Date__c = System.today();
        encounter.HealthCloudGA__Account__c = personAccountId;
        encounter.Provider_Name__c = providerName;
        encounter.Title__c = 'Test';
        if( performDml ){
            INSERT encounter;
        }
        return encounter;
    }

    public static Knowledge__kav insertKnowledgeArticleVersion( String articleName, String resourceType, Boolean performDml,
            Id recordTypeId, Boolean isFeatured){
        Knowledge__kav newArticle = new knowledge__kav( Title=articleName, Summary=articleName, Urlname=articleName );
        newArticle.Resource_Type__c = resourceType;
        newArticle.IsVisibleInCsp = true;
        newArticle.RecordTypeId = recordTypeId;
        newArticle.Featured__c = isFeatured;
        if( performDml ){
            INSERT newArticle;
        }
        return newArticle;
    }

    public static Referral_Record__c insertReferralRecord( Id accId, Id articleId, Boolean performDml ){
        Referral_Record__c refRecord = new Referral_Record__c();
        refRecord.Knowledge_Article_Referred__c = articleId;
        refRecord.Patient__c = accId;
        if( performDml ){
            INSERT refRecord;
        }
        return refRecord;
    }

    
}