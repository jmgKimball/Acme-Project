@isTest
public class HealthCloudTestFactoryData {
    public Static void createAccountAndApplication(){
        Account account = new Account(FirstName='john',LastName='Smith',Race__pc='Asian',PersonBirthdate=system.today(),Preferred_Language__c ='English',
                                      Gender__pc='Male',Ethnicity__pc='Hispanic/LatinX',PersonEmail='abc@gmail.com');
        insert account;
        
        Application__c application = new Application__c(Patient__c =account.id,Total_annual_Household_Income__c =40000,No_of_People_in_the_Household__c=3,
                                                        Is_patient_in_active_treatment__c='yes',Medical_Provider_First_Name__c='Mark',  Medical_Provider_Last_Name__c='Waugh',
                                                        Hospital_Clinic__c='New Hospital',  Hospital_Clinic_Address__c='Oxford Lane',Hospital_Clinic_Phone__c='1258',
                                                        Hospital_Clinic_City__c='New York', Hospital_Clinic_State__c='New York',Hospital_Clinic_Zip__c='10001',
                                                        Signatory_Name__c='Adam',Signed_Date__c=system.today(),Relationship_to_Patient__c='Self',Application_Status__c='New',
                                                        Status_Change_Date__c= system.today());
        insert application;
    }  
}