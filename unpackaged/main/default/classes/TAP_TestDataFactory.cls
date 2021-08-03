/**
* @author IVL Dev
* @description Call these methods in test classes to create test data for varying situations.
*/
@isTest
public class TAP_TestDataFactory {
    /*******************************************************************************************************
    * @description use this method to create accounts
    * @param  Integer nuberOfAccount  of Number of Accounts to create String LastName of Account Last Name
    * @return return list of Accounts
    ****************************************************************************************************/
    
    public static  List<Account> createAccount (Integer numberOfAccount, String lastName){
        //Declare Variables                                       
        List<Account> accounts = populateAccount(1,lastName);
        Database.insert (accounts,false);
        return accounts;    
    }

    /*******************************************************************************************************
    * @description use this method to populate accounts
    * @param  Integer nuberOfAccount  of Number of Accounts to create String LastName of Account Last Name
    * @return return list of Accounts
    ****************************************************************************************************/
    public static  List<Account> populateAccount (Integer numberOfAccount, String lastName){
        //Declare Variables                                       
        List<Account> accounts = new List<Account>();
        //Query for record type IDs
        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(TAP_Constants.PERSONACCOUNT_RECORDTYPE_NAME).getRecordTypeId();
        for(Integer i=0;i<numberOfAccount;i++){
            
            Account account= new Account(FirstName= 'Test', LastName= lastName + i, RecordTypeId= personAccountId,PersonEmail = 'abc@gmail.com',
                                         PersonBirthdate= date.newInstance(1995, 01, 05), Preferred_Language__c='English',PersonMailingStreet='1851 Heritage Ln #299',
                                         PersonMailingCity = 'New Jersey',PersonMailingState = 'New Jersey',PersonMailingStateCode = 'NJ',PersonMailingCountry = 'United States',
                                         PersonMailingPostalCode = '07001');
            
            accounts.add(account); 
        }
        return accounts;    
    }

    /*******************************************************************************************************
    * @description use this method to create accounts with address
    * @param  Integer nuberOfAccount  of Number of Accounts to create String  LastName of Account Last Name
    * @return return list of Accounts
    ****************************************************************************************************/
    
    public static  List<Account> createAccountWithoutAddress (Integer numberOfAccount, String LastName){
        //Declare Variables                                       
        List<Account> accounts = new List<Account>();
        //Query for record type IDs
        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(TAP_Constants.PERSONACCOUNT_RECORDTYPE_NAME).getRecordTypeId();
        //Create Accounts
        for(Integer i=0;i<numberOfAccount;i++){
            Account account= new Account(FirstName= 'Test', LastName= LastName + i, RecordTypeId= personAccountId,PersonEmail = 'abc@gmail.com',
                                         PersonBirthdate= date.newInstance(1995, 01, 05), Preferred_Language__c='English');
            accounts.add(account); 
        }
        Database.insert (accounts,false);
        return accounts;    
    }
     
    /*******************************************************************************************************
    * @description use this method to create Care Program.
    * @param  Integer numberOfCareProgram  of Number of Care Program to create and String Name of Care Program Name
    * @return return list of Care Program
    ********************************************************************************************************/
    public static List<CareProgram> createCareProgram (Integer numberOfCareProgram, String Name){
        //Create Care Program
        List<CareProgram> carePrograms = populateCarePrograms(numberOfCareProgram,Name);
        database.insert(carePrograms,false);
        return carePrograms;  
    }

    /*******************************************************************************************************
    * @description use this method to populate Care Program.
    * @param  Integer numberOfCareProgram  of Number of Care Program to create and String Name of Care Program Name
    * @return return list of Care Program
    ********************************************************************************************************/
    public static List<CareProgram> populateCarePrograms (Integer numberOfCareProgram, String Name){
        List<CareProgram> carePrograms = new List<CareProgram>();
        for(Integer i=0; i<numberOfCareProgram; i++){
            CareProgram careProgram = new CareProgram(Name= Name +i, Care_Program_Type__c=TAP_Constants.CARE_PROGRAM_TYPE, Status=TAP_Constants.CARE_PROGRAM_STATUS_ACTIVE,
                                                      Payout_Amount__c=300,Department__c = '1236',Project_Code__c='INTERNAL',Activity_Code__c='TAF');
            
            carePrograms.add(careProgram);
        }
        return carePrograms;  
    }
  
    /*******************************************************************************************************
    * @description use this method to create Applications.
    * @param  Integer nuberOfApplication  of Number of Application to create 
    * @return return list of Application
    ********************************************************************************************************/
    public static List<Application__c> createApplication( Integer nuberOfApplication,Id accountId,Id careProgramId){
        
        List<Application__c> applications = populateApplications(nuberOfApplication,accountId,careProgramId);
        database.insert(applications,false);
        return applications;  
    }

    /*******************************************************************************************************
    * @description use this method to populate Applications.
    * @param  Integer nuberOfApplication  of Number of Application to create 
    * @return return list of Application
    ********************************************************************************************************/
    public static List<Application__c> populateApplications( Integer nuberOfApplication,Id accountId,Id careProgramId){
        
        List<Application__c> applications = new List<Application__c>();
        for(Integer i=0; i<nuberOfApplication; i++){
            Application__c application = new Application__c(Patient__c = accountId, Care_Program__c = careProgramId, 
                                                            Application_Status__c = TAP_Constants.APPLICATION_STATUS_NEW, Status_Change_Date__c=date.newInstance(2020, 07, 10),
                                                            Application_Source__c = 'Direct Fax',Health_Insurance__c = true,    Type_of_Insurance__c='Medicaid',
                                                            Employment_Status__c = 'Full_Time', No_of_People_in_the_Household__c = 3,   
                                                            Total_annual_Household_Income__c= 40000, Family__c = 'Salary', Transportation__c = true, Palliative_care__c =true,
                                                            Childcare__c = true, Date_Of_Breast_Cancer_Diagnosis__c = date.newInstance(2020, 07, 01),
                                                            Breast_cancer_type__c  = 'Invasive Lobular Carcinoma', Breast_Cancer_Subtype__c = 'ER+/HER2-', Current_Stages__c = 'Stage-I',
                                                            Treatment_s_received_in_the_past_12_mon__c = 'Chemotherapy',
                                                            Medical_Provider_First_Name__c = 'Matt', Medical_Provider_Last_Name__c = 'Wall', Hospital_Clinic__c = 'Apollo Breast cancer Hospital',
                                                            Hospital_Clinic_Address__c = '1851 Heritage Ln #299',Hospital_Clinic_Phone__c = '1258796',Hospital_Clinic_Fax__c = '12589',
                                                            Hospital_Clinic_State__c = 'California',Hospital_Clinic_Zip__c = 'CA 95815',Method_of_Payment_Distribution__c = '   Postal Mail',
                                                            Signatory_Name__c = 'Jaff Roy',Signed_Date__c = date.newInstance(2020, 07, 20),
                                                            Relationship_to_Patient__c = 'Family Member',New_Status_Duration__c =0, Payable_To__c = 'Example Payee');
            applications.add(application);        
        }
        
        return applications;  
    }
    
    /*******************************************************************************************************
    * @description use this method to create EnrollmentEligibilityCriteria.
    * @param  Integer numberOfCriteria  of Number of EnrollmentEligibilityCriteria to create and 
    * String basedOn of criteria based on  String Name of EnrollmentEligibilityCriteria Name
    * @return return list of EnrollmentEligibilityCriteria
    ********************************************************************************************************/
    
    public static List<EnrollmentEligibilityCriteria> createEnrollmentEligibilityCriteria(Integer numberOfCriteria, String criteriaType, String name){
        List<EnrollmentEligibilityCriteria> enrollmentEligibilityCriterias = populateEnrollmentEligibilityCriteria(numberOfCriteria,criteriaType,name);
        insert enrollmentEligibilityCriterias;
        return enrollmentEligibilityCriterias;  
    }

    /*******************************************************************************************************
    * @description use this method to populate EnrollmentEligibilityCriteria.
    * @param  Integer numberOfCriteria  of Number of EnrollmentEligibilityCriteria to create and 
    * String basedOn of criteria based on  String Name of EnrollmentEligibilityCriteria Name
    * @return return list of EnrollmentEligibilityCriteria
    ********************************************************************************************************/
    public static List<EnrollmentEligibilityCriteria> populateEnrollmentEligibilityCriteria(Integer numberOfCriteria, String criteriaType, String Name){
        List<EnrollmentEligibilityCriteria> enrollmentEligibilityCriterias = new List<EnrollmentEligibilityCriteria>();
        for(Integer i=0; i<numberOfCriteria; i++){
            EnrollmentEligibilityCriteria enrollmentEligibilityCriteria = new EnrollmentEligibilityCriteria(Name= Name,Criteria_Type__c = criteriaType, Status= TAP_Constants.CARE_PROGRAM_STATUS);
            EnrollmentEligibilityCriterias.add(EnrollmentEligibilityCriteria);
        }
        return enrollmentEligibilityCriterias;  
    }
    
    /*******************************************************************************************************
    * @description use this method to create CareProgramEligibilityRule.
    * @param  Integer numberOfCareProgramRule  of Number of CareProgramEligibilityRule
    * @return return list of CareProgramEligibilityRule
    ********************************************************************************************************/    
    public static List<CareProgramEligibilityRule> careProgramEligibilityRule (Integer numberOfCareProgramRule, Id eligibilityCriteriaId, Id careProgramId ){
        //Generate EnrollmentEligibilityCriteria to use
        List<CareProgramEligibilityRule> careProgramRules = populateCareProgramEligibilityRule(numberOfCareProgramRule,eligibilityCriteriaId,careProgramId);
        database.insert(careProgramRules,false);
        return careProgramRules;   
    }
    
    /*******************************************************************************************************
    * @description use this method to populate CareProgramEligibilityRule.
    * @param  Integer numberOfCareProgramRule  of Number of CareProgramEligibilityRule
    * @return return list of CareProgramEligibilityRule
    ********************************************************************************************************/    
    public static List<CareProgramEligibilityRule> populateCareProgramEligibilityRule (Integer numberOfCareProgramRule, Id eligibilityCriteriaId, Id careProgramId ){
        //Generate EnrollmentEligibilityCriteria to use
        List<CareProgramEligibilityRule> careProgramRules = new List<CareProgramEligibilityRule>();
        for(Integer i=0; i<numberOfCareProgramRule; i++){
            CareProgramEligibilityRule careProgramRule = new CareProgramEligibilityRule(CareProgramId= careProgramId,
                                                                                        EligibilityCriteriaId= eligibilityCriteriaId, Status= TAP_Constants.CARE_PROGRAM_STATUS);
            careProgramRules.add(careProgramRule);
        }
        return careProgramRules;   
    }
    
    /*******************************************************************************************************
    * @description use this method to create Eligibility Details.
    * @param  String recordType  of record Type of Eligibility Details and Id eligibilityCriteria of EnrollmentEligibilityCriteria IDs
    *  and String state of Eligibility Details state and String zipCode of Eligibility Details Zip code
    * @return return list of Eligibility Details
    ********************************************************************************************************/
    public static List<Eligibility_Detail__c> createEligibilityDetail(String recordType, Id eligibilityCriteria, String state, String zipCode){
        
        List<Eligibility_Detail__c> eligibilityDetails = populateEligibilityDetail(recordType,eligibilityCriteria,state,zipCode);
        database.insert(eligibilityDetails,false);
        return eligibilityDetails;   
    }
    
    /*******************************************************************************************************
    * @description use this method to populate Eligibility Details.
    * @param  String recordType  of record Type of Eligibility Details and Id eligibilityCriteria of EnrollmentEligibilityCriteria IDs
    *  and String state of Eligibility Details state and String zipCode of Eligibility Details Zip code
    * @return return list of Eligibility Details
    ********************************************************************************************************/
    public static List<Eligibility_Detail__c> populateEligibilityDetail(String recordType, Id eligibilityCriteria, String state, String zipCode){
        
        
        //Query for record type ID 
        List<RecordType> recordtypes = [SELECT Id,DeveloperName From RecordType where sObjectType='Eligibility_Detail__c' 
                                        and isActive=true and DeveloperName = :recordType];
        List<Eligibility_Detail__c> eligibilityDetails = new List<Eligibility_Detail__c>();
        
        if(recordType =='Location_Based'){
            Eligibility_Detail__c eligibilityDetail = new Eligibility_Detail__c (RecordTypeId= recordtypes[0].id, Eligibility_Criteria__c= eligibilityCriteria, 
                                                                                 Is_Active__c= true, State__c= state, ZIP_Code__c= zipCode);
            eligibilityDetails.add(eligibilityDetail);
            
        }else if(recordType =='Income_Based'){
            Eligibility_Detail__c eligibilityDetail = new Eligibility_Detail__c (RecordTypeId= recordtypes[0].id,Eligibility_Criteria__c= eligibilityCriteria, 
                                                                                 Per_Person_Incremental_Amount__c= 4480,Single_Person_Income_Limit__c = 12760,
                                                                                 Is_Active__c= true, State__c= state,ZIP_Code__c= zipCode);
            eligibilityDetails.add(eligibilityDetail);
        }
        return eligibilityDetails;   
    }
    
    /********************************************************************************************************
    * @description use this method to create Payments.
    * @param  Id accountId  of Number ofAccount Ids and Id applicationId of Application Ids and Id careProgramId of care Program Ids
    * @return return list of Payments
    ********************************************************************************************************/    
    public static List<Payment__c> createPayments(Id accountId, Id applicationId, Id careProgramId){
        List<Payment__c> payments = populatePayments(accountId,applicationId,careProgramId);
        database.insert(payments,false);
        return payments;    
    }

    /********************************************************************************************************
    * @description use this method to populate Payments.
    * @param  Id accountId  of Number ofAccount Ids and Id applicationId of Application Ids and Id careProgramId of care Program Ids
    * @return return list of Payments
    ********************************************************************************************************/    
    public static List<Payment__c> populatePayments(Id accountId, Id applicationId, Id careProgramId){
        List<Payment__c> payments = new List<Payment__c>();
        
        Payment__c payment = new Payment__c(Account__c= accountId, Application__c= applicationId, Care_Program__c= careProgramId,Amount__c = 300,
                                            Payment_Date__c = date.newInstance(2020, 07, 15),Payment_Status__c='Pending');
        payments.add(payment);
        return payments;    
    }
    
    /********************************************************************************************************
    * @description Creates Donation object.
    * @param careProgramId Care Program Id
    * @param amount Amount for donation
    * @return return list of Donations
    ********************************************************************************************************/
    public static List<Donation__c> createDonation(Id careProgramId, Decimal amount) {
        List<Donation__c> donations = populateDonation(careProgramId, amount);
        insert donations;
        return donations;
    }
    
    /********************************************************************************************************
    * @description Populate Donation object.
    * @param careProgramId Care Program Id
    * @param amount Amount for donation
    * @return return list of Donations
    ********************************************************************************************************/
    public static List<Donation__c> populateDonation(Id careProgramId, Decimal amount) {
        List<Donation__c> donations = new List<Donation__c>();
        donations.add(new Donation__c(care_program__c = careProgramId, amount__c = amount));
        return donations;
    }
    
    /********************************************************************************************************
    * @description use this method to create Suggested Care Program.
    * @param  Integer  numberOfSuggestedProgram  of Number of Suggested Care Program to create and 
    * Id applicationId of Application Ids and Id careProgramId of care Program Ids
    * @return return list of Suggested Care Program
    ********************************************************************************************************/    
    Public static List<Suggested_Care_Program__c> createSuggestedCareProgram(Integer  numberOfSuggestedProgram, Id applicationId, Id careProgramId){
        List<Suggested_Care_Program__c> suggestedCarePrograms = populateSuggestedCareProgram(numberOfSuggestedProgram,applicationId,careProgramId);
        database.insert(suggestedCarePrograms,false);
        return suggestedCarePrograms;   
    }

    /********************************************************************************************************
    * @description use this method to populate Suggested Care Programs.
    * @param  Integer  numberOfSuggestedProgram  of Number of Suggested Care Program to create and 
    * Id applicationId of Application Ids and Id careProgramId of care Program Ids
    * @return return list of Suggested Care Program
    ********************************************************************************************************/   
    public static List<Suggested_Care_Program__c> populateSuggestedCareProgram(Integer  numberOfSuggestedProgram, Id applicationId, Id careProgramId) {
        List<Suggested_Care_Program__c> suggestedCarePrograms = new List<Suggested_Care_Program__c>();
        
        for(Integer i=0; i<numberOfSuggestedProgram; i++){
            Suggested_Care_Program__c suggestedCareProgram = new Suggested_Care_Program__c(name='testsuggestedProgram' +i, Care_Program__c= careProgramId,
                                                                                           Application__c= applicationId);
            suggestedCarePrograms.add(suggestedCareProgram);
        }
        return suggestedCarePrograms;
    }
    

    /********************************************************************************************************
    * @description use this method to create CareDeterminantType
    * @param Integer  numberOfcareDeterminantType of Number of createCareDeterminantType to create
    * and String Name of createCareDeterminantType Name and tring Type of createCareDeterminantType Type
    * and String Domain of createCareDeterminantType Domain
    * @return return list of TAP Inbox
    ********************************************************************************************************/
    public static List<CareDeterminantType> createCareDeterminantType(Integer numberOfcareDeterminantType, String Name,String Type,String Domain){
        List<CareDeterminantType> careDeterminantTypes = new List<CareDeterminantType>();
        for(Integer i=0; i< numberOfcareDeterminantType; i++){
            CareDeterminantType careDeterminantType = new CareDeterminantType(Name=Name,Type=Type,Domain= Domain);
            careDeterminantTypes.add(careDeterminantType);
        }
        database.insert(careDeterminantTypes,false);
        return careDeterminantTypes; 
    }
        
    /********************************************************************************************************
    * @description use this method to create CareDeterminantType
    * @param Id  createCareDeterminantTypeId of Number of createCareDeterminantType Ids
    * and Id AccountId of Account Ids
    * @return return list of CareDeterminant
    ********************************************************************************************************/
    public static List<CareDeterminant> createCareDeterminant(Id createCareDeterminantTypeId, Id AccountId){
        List<CareDeterminant> careDeterminants = new List<CareDeterminant>();
        CareDeterminant careDeterminant = new CareDeterminant(Name='TestCareDeterminant',CareDeterminantTypeId = createCareDeterminantTypeId,
                                                              PatientId = AccountId,IsActive=true);
        careDeterminants.add(careDeterminant);
        database.insert(careDeterminant,false);
        return careDeterminants; 
    }
    
    /********************************************************************************************************
    * @description to create Tap Inbox
    * @param  Id TAPInboxRecID of Tap Inbox Id
    * @return List of TAPInbox
    ********************************************************************************************************/
    public static List<TAP_Inbox__c> createtapInbox(Integer numberOfInboxes,Id applicationId,String LastName){
        List<TAP_Inbox__c> tapInboxs  = populateTAPInboxes(1, applicationId, LastName);
        Database.insert(tapInboxs,false);
        return tapInboxs;  
    }
    
    public static List<TAP_Inbox__c> createtapInbox(Integer numberOfInboxes,String LastName){
        List<TAP_Inbox__c> tapInboxs  = populateTAPInboxes(1, LastName);
        Database.insert(tapInboxs,false);
        return tapInboxs;  
    }
    
     /********************************************************************************************************
    * @description to populate Tap Inbox
    * @param  Id TAPInboxRecID of Tap Inbox Id
    * @return List of TAPInbox
    ********************************************************************************************************/
    public static List<TAP_Inbox__c> populateTAPInboxes(Integer numberOfInboxes,Id applicationId,String LastName){
        List<TAP_Inbox__c> tapInboxs = new List<TAP_Inbox__c>();
        for(Integer i= 0; i< numberOfInboxes; i++){
            TAP_Inbox__c TapInbox = new TAP_Inbox__c(First_Name__c = 'Test', Last_Name__c = LastName + i, Subject__c =  'New Application Request',
                                                     Status__c = TAP_Constants.TAP_INBOX_STATUS_PENDING, Application__c = applicationId);
            tapInboxs.add(TapInbox);
        }
        
        return tapInboxs;   
    }
    
    public static List<TAP_Inbox__c> populateTAPInboxes(Integer numberOfInboxes, String LastName){
        List<TAP_Inbox__c> tapInboxs = new List<TAP_Inbox__c>();
        for(Integer i= 0; i< numberOfInboxes; i++){
            TAP_Inbox__c TapInbox = new TAP_Inbox__c(First_Name__c = 'Test', Last_Name__c = LastName + i, Subject__c =  'New Application Request',
                                                     Status__c = TAP_Constants.TAP_INBOX_STATUS_PENDING);
            tapInboxs.add(TapInbox);
        }
        
        return tapInboxs;   
    }

   /********************************************************************************************************
    * @description to create Messinging Inbound Email
    * @param  Id TAPInboxRecID of Tap Inbox Id
    * @return list EmailMessage
    ********************************************************************************************************/
    public static List<EmailMessage> createEmailMessage(Id recordId){
        List<EmailMessage> inboxEmails = populateEmailMessage(recordId);
        
        Database.insert(inboxEmails,false);
        return inboxEmails;
    }
    
    /********************************************************************************************************
    * @description to populate Messinging Inbound Email
    * @param  Id TAPInboxRecID of Tap Inbox Id
    * @return list EmailMessage
    ********************************************************************************************************/
    public static List<EmailMessage> populateEmailMessage(Id recordId){
        List<EmailMessage> inboxEmails = new List<EmailMessage>();
        EmailMessage inboxEmail= new EmailMessage(htmlBody= TAP_Constants.EMAIL_HTML_BODY,TextBody =TAP_Constants.EMAIL_TEXT_BODY,subject=TAP_Constants.EMAIL_SUBJECT,
                                                  toAddress = TAP_Constants.EMAIL_TO_ADDRESS,fromAddress=TAP_Constants.EMAIL_FROM_ADDRESS,
                                                  ccAddress=TAP_Constants.EMAIL_CC_ADDRESS,FromName =TAP_Constants.EMAIL_FROM_NAME, relatedToId =recordId);
        
        inboxEmails.add(inboxEmail);
        return inboxEmails;
    }
        
    /********************************************************************************************************
    * @description to create contentVersion
    * @return List of contentVersions
    *********************************************************************************************************/
    public static List<ContentVersion> createContentVersion(){
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        ContentVersion ContentVersion= new ContentVersion( title='ABC',PathOnClient ='test');
        contentVersions.add(ContentVersion);
        Database.insert(contentVersions,false);
        return contentVersions;
    }

    /********************************************************************************************************
    * @description use this method to create  Users
    * @param  String profileNameof Number profile name of user
    * @return list of user
    ********************************************************************************************************/
    public static List<User> createUser(){
        //List of Users
        List<User> users = new List<User>();
        //List of  custom Profile
        List<Profile> profiles = [SELECT Id,Name FROM Profile Where Name IN (:TAP_Constants.PROFILE_MISSION_TEAM,
                                                                             :TAP_Constants.PROFILE_PROGRAM_OWNER_TEAM,
                                                                             :TAP_Constants.PROFILE_ACCOUNTING_TEAM)];
        
        // create Mission Data entry Profile User
        User missionUser = new User(Alias = TAP_Constants.MISSION_ALIAS, Email=TAP_Constants.MISSION_TEAM,
                                    EmailEncodingKey='UTF-8', LastName=TAP_Constants.MISSION_TEAM_LASTNAME, LanguageLocaleKey='en_US',
                                    LocaleSidKey='en_US', ProfileId = profiles[0].Id,
                                    TimeZoneSidKey='America/Los_Angeles', UserName=TAP_Constants.MISSION_TEAM);
        database.insert(missionUser,false);
        users.add(missionUser);
        System.runAs(missionUser){
            List<PermissionSet> missionUserPermissionSet = [Select Id FROM PermissionSet WHERE Name IN (:TAP_Constants.PERMISSIONSET_HEALTH_FOUNDATION,
                                                                                                        :TAP_Constants.PERMISSIONSET_REPORT_DASHBOARDS)];
            
            // PermissionSetAssignment for Mission data entry user
            PermissionSetAssignment PermissionSetAssignmentFormissionUser1= new PermissionSetAssignment(PermissionSetId =missionUserPermissionSet[0].Id, AssigneeId = missionUser.id);
            database.insert(PermissionSetAssignmentFormissionUser1,false);
            PermissionSetAssignment PermissionSetAssignmentFormissionUser2 = new PermissionSetAssignment(PermissionSetId =missionUserPermissionSet[1].Id, AssigneeId = missionUser.id);
            database.insert(PermissionSetAssignmentFormissionUser2,false);
            
        }
        // Create Program pser Profilr user
        User programOwnerUser = new User(Alias = TAP_Constants.PROGRAM_ALIAS, Email=TAP_Constants.PROGRAM_TEAM,
                                         EmailEncodingKey='UTF-8', LastName=TAP_Constants.PROGRAM_TEAM_LASTNAME, LanguageLocaleKey='en_US',
                                         LocaleSidKey='en_US', ProfileId = profiles[1].Id,
                                         TimeZoneSidKey='America/Los_Angeles', UserName=TAP_Constants.PROGRAM_TEAM); 
        database.insert(programOwnerUser,false);
        users.add(programOwnerUser);
        
        System.runAs(programOwnerUser){
            // List of Permission set for Program owner user
            List<PermissionSet> programOwnerUserPermissionSet = [Select Id FROM PermissionSet WHERE Name IN (:TAP_Constants.PERMISSIONSET_HEALTH_FOUNDATION,
                                                                                                             :TAP_Constants.PERMISSIONSET_MISSION_TEAM)];
            
            // PermissionSetAssignment for Program owner user
            PermissionSetAssignment PermissionSetAssignmentForProgramOwnerUser1 = new PermissionSetAssignment(PermissionSetId =programOwnerUserPermissionSet[0].Id, 
                                                                                                              AssigneeId = programOwnerUser.id);
            database.insert(PermissionSetAssignmentForprogramOwnerUser1,false);
            
            PermissionSetAssignment PermissionSetAssignmentForProgramOwnerUser2 = new PermissionSetAssignment(PermissionSetId =programOwnerUserPermissionSet[1].Id,
                                                                                                              AssigneeId = programOwnerUser.id);
            database.insert(PermissionSetAssignmentForprogramOwnerUser2,false);
        }
        // create Accounting profilr user
        User accountingUser = new User(Alias = TAP_Constants.ACCOUNTING_ALIAS, Email=TAP_Constants.ACCOUNTING_TEAM,
                                       EmailEncodingKey='UTF-8', LastName=TAP_Constants.ACCOUNTING_TEAM_LASTNAME, LanguageLocaleKey='en_US',
                                       LocaleSidKey='en_US', ProfileId = profiles[2].Id,
                                       TimeZoneSidKey='America/Los_Angeles', UserName=TAP_Constants.ACCOUNTING_TEAM);
        database.insert(accountingUser,false);
        users.add(accountingUser);
        System.runAs(accountingUser){
            // List of Permission set for Accounting user
            List<PermissionSet> accountingpermissionSets = [Select Id FROM PermissionSet WHERE Name IN (:TAP_Constants.PERMISSIONSET_HEALTH_FOUNDATION, 
                                                                                                        :TAP_Constants.PERMISSIONSET_HEALTH_CLOUD_LIMITED,
                                                                                                        :TAP_Constants.PERMISSIONSET_HEALTH_CLOUD_LICENSE,
                                                                                                        :TAP_Constants.PERMISSIONSET_HEALTH_CLOUD_STANDARD)];
            // PermissionSetAssignment for Accounting user 
            PermissionSetAssignment PermissionSetAssignmentForAccountingUser1 = new PermissionSetAssignment(PermissionSetId =accountingpermissionSets[0].Id,
                                                                                                            AssigneeId = accountingUser.id);
            database.insert(PermissionSetAssignmentForAccountingUser1,false);
            PermissionSetAssignment PermissionSetAssignmentForAccountingUser2 = new PermissionSetAssignment(PermissionSetId =accountingpermissionSets[1].Id, 
                                                                                                            AssigneeId = accountingUser.id);
            database.insert(PermissionSetAssignmentForAccountingUser2,false);
            PermissionSetAssignment PermissionSetAssignmentForAccountingUser3 = new PermissionSetAssignment(PermissionSetId =accountingpermissionSets[2].Id,
                                                                                                            AssigneeId = accountingUser.id);
            database.insert(PermissionSetAssignmentForAccountingUser3,false);
            PermissionSetAssignment PermissionSetAssignmentForAccountingUser4 = new PermissionSetAssignment(PermissionSetId =accountingpermissionSets[3].Id,
                                                                                                            AssigneeId = accountingUser.id);
            database.insert(PermissionSetAssignmentForAccountingUser4,false);
            
        }
        database.update(users,false);
        return users; 
    }
    
    public static User createTestUser_noAccess(String objectType,Boolean hasRead,Boolean hasEdit, Boolean hasDelete){
        User usr;
        try {
            //look for a profile that does not have access to the Account object
            PermissionSet ps = 
                [SELECT Profile.Id, profile.name
                 FROM PermissionSet
                 WHERE IsOwnedByProfile = true
                 AND Profile.UserType = 'Standard'
                 AND Id NOT IN (SELECT ParentId
                                FROM ObjectPermissions
                                WHERE SObjectType = :objectType
                                AND PermissionsRead = :hasRead 
                                AND PermissionsEdit = :hasEdit 
                                AND PermissionsDelete = :hasDelete)
                 LIMIT 1];
            
            if (ps != null){
                //create a user with the profile found that doesn't have access to the Account object
                usr = new User(
                    firstName = 'testUsrF',
                    LastName = 'testUsrL',
                    Alias = 'tstUsr',
                    Email = 'testy.test@test.com',
                    UserName='test'+ Math.random().format()+'user99@test.com',
                    EmailEncodingKey = 'ISO-8859-1',
                    LanguageLocaleKey = 'en_US',
                    TimeZoneSidKey = 'America/Los_Angeles',
                    LocaleSidKey = 'en_US',
                    ProfileId = ps.Profile.Id,
                    IsActive=true
                );
                insert usr;
            }
        } catch (Exception e) {
            //do nothing, just return null User because this test case won't work in this org.
            return null;
        }   
        return usr; 
    }
    
}