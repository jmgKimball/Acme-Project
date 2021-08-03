/**
 * Custom registration handler for MyKomen Health's SSO connection to MyKomen
 *
 * @author Grant Adamson, Traction on Demand
 * @date 2020-08-19
 */
global class MKH_RegistrationHandler implements Auth.RegistrationHandler {
    @TestVisible
    private static final Id COMMUNITY_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'Patient Community Login'].Id;
    private static final Id PERSON_ACCOUNT_RT_ID =
            Account.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('PersonAccount').recordTypeId;

    private static final Map<String, SObjectField> CONTACT_TO_PERSON_FIELD_MAP = new Map<String, SObjectField>{
            'Salutation' => Account.Salutation,
            'Suffix__c' => Account.Suffix,
            'Professional_Suffix__c' => Account.Professional_Suffix__pc,
            'Birthdate' => Account.PersonBirthdate,
            'Deceased__c' => Account.Deceased__pc,
            //'Gender__c' => Account.Gender__pc, // Excluding due to picklist value mismatches, handled by ext sync
            //'Ethnicity__c' => Account.Ethnicity__pc, // Excluding due to picklist value mismatches, handled by ext sync
            //'LP_Ethnicity__c' => Account.Race__pc, // Excluding due to picklist value mismatches, handled by ext sync
            'Employer__c' => Account.Employer__pc,
            'Occupation__c' => Account.Occupation__pc,
            'MailingStreet' => Account.PersonMailingStreet,
            'MailingCity' => Account.PersonMailingCity,
            'MailingState' => Account.PersonMailingState,
            'MailingCountry' => Account.PersonMailingCountry,
            'MailingPostalCode' => Account.PersonMailingPostalCode,
            //'Phone' => Account.Phone, // Phone values to be handled by ext sync
            //'npe01__WorkPhone__c' =>
            //'HomePhone' => Account.PersonHomePhone,
            //'MobilePhone' => Account.PersonMobilePhone,
            //'npe01__PreferredPhone__c' =>
            'Do_Not_Contact__c' => Account.Do_Not_Contact__pc,
            //'Email_Opt_Out_Date__c' => Account.PersonHasOptedOutOfEmail, // Excluded due to data type mismatch
            'Postal_Mail_Opt_Out__c' => Account.Postal_Opt_Out__pc,
            'ContactId' => Account.CRM_Org_ID__pc
    };

    private static final Map<String, SObjectField> USER_FIELD_MAP = new Map<String, SObjectField>{
            'MiddleName' => User.MiddleName,
            'Street' => User.Street,
            'City' => User.City,
            'State' => User.State,
            'Country' => User.Country,
            'PostalCode' => User.PostalCode,
            'CommunityNickname' => User.CommunityNickname,
            'CompanyName' => User.CompanyName,
            'Title' => User.Title,
            'LanguageLocaleKey' => User.LanguageLocaleKey,
            'TimeZoneSidKey' => User.TimeZoneSidKey,
            'LocaleSidKey' => User.LocaleSidKey
    };

    private static final Database.DMLOptions DML_OPTIONS;

    static {
        DML_OPTIONS = new Database.DMLOptions();
        DML_OPTIONS.duplicateRuleHeader.allowSave = true;
    }

    /**
     * Custom user creation logic, finds or creates a Person Account and corresponding User record based on the data
     * provided by the MyKomen connected app
     *
     * @return new User record
     */
    global User createUser(Id portalId, Auth.UserData data) {
        Account person = findPersonAccountFromUserData(data);
        Id contactId;

        if(person == null) {
            person = createPersonAccountFromUserData(data);
            validateDatabaseResult(Database.insert(person, DML_OPTIONS));

            contactId = getContactIdForPersonAccount(person);
        } else {
            // TODO: Determine if we actually want to update the Person Account with NPSP data
            updatePersonAccountFromUserData(person, data);
            validateDatabaseResult(Database.update(person, DML_OPTIONS));
            contactId = person.PersonContactId;
        }

        return createUserFromUserData(data, contactId);
    }

    private static void validateDatabaseResult(Database.SaveResult result) {
        if(!result.isSuccess()) {
            throw new RegistrationHandlerException(result.getErrors()[0].getMessage());
        }
    }

    private Id getContactIdForPersonAccount(Account person) {
        return [SELECT PersonContactId FROM Account WHERE Id = :person.Id].PersonContactId;
    }

    /**
     * Custom user update logic, updates Person Account and corresponding User record based on the data provided by the
     * MyKomen connected app
     */
    global void updateUser(Id userId, Id portalId, Auth.UserData data) {
        User user = new User(Id = userId, IsActive = true);
        updateUserFromUserData(user, data);
        update user;

        Id accountId = getAccountIdForCommunityUser(userId);
        Account person = new Account(Id = accountId);
        updatePersonAccountFromUserData(person, data);
        // Avoid Mixed DML errors by deferring the account update using a future call
        updateAccountInFuture(JSON.serialize(person));
    }

    @Future
    private static void updateAccountInFuture(String accountJSON) {
        Account a = (Account)JSON.deserialize(accountJSON, Account.class);
        validateDatabaseResult(Database.update(a, DML_OPTIONS));
    }

    private Id getAccountIdForCommunityUser(Id userId) {
        return [SELECT AccountId FROM User WHERE Id = :userId].AccountId;
    }

    private Account findPersonAccountFromUserData(Auth.UserData data) {
        String email = data.email;

        // TODO: Implement proper matching
        List<Account> accounts = [
                SELECT Id, PersonContactId
                FROM Account
                WHERE PersonEmail = :email
                AND RecordTypeId = :PERSON_ACCOUNT_RT_ID
                ORDER BY LastModifiedDate DESC
        ];

        if(accounts.isEmpty()) {
            return null;
        }

        return accounts[0];
    }

    private Account createPersonAccountFromUserData(Auth.UserData data) {
        Account a = new Account(
                RecordTypeId = PERSON_ACCOUNT_RT_ID,
                FirstName = data.firstName,
                LastName = data.lastName,
                PersonEmail = data.email
        );

        updatePersonAccountFromUserData(a, data);

        return a;
    }

    private void updatePersonAccountFromUserData(Account person, Auth.UserData data) {
        Map<String, String> customAttributes = extractCustomAttributes(data);

        for(String dataKey : CONTACT_TO_PERSON_FIELD_MAP.keySet()) {
            if(customAttributes.containsKey(dataKey)) {
                SObjectField sObjectField = CONTACT_TO_PERSON_FIELD_MAP.get(dataKey);
                String stringValue = customAttributes.get(dataKey);

                if(!String.isBlank(stringValue)) {
                    person.put(sObjectField, convertStringToFieldType(stringValue, sObjectField));
                }
            }
        }

        KHC_AccountService.correctPersonAccountState(person);

        populatePersonAccountCountryIfStatePresent(person);

    }

    private Map<String, String> extractCustomAttributes(Auth.UserData data) {
        Map<String, String> result = new Map<String, String>();

        try {
            // Custom attributes are returned as an apex Map.toString() value that we need to extract the JSON from
            String customAttributesRaw = data.attributeMap.get('custom_attributes');

            // exclude '{json=' and closing '}' from the returned string
            String jsonString = customAttributesRaw.substring(6, customAttributesRaw.length() - 1);

            result = (Map<String, String>) JSON.deserialize(jsonString, Map<String, String>.class);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }

        return result;
    }

    /*
        This will only account for records where a state is present but no country, where the state is in the US
     */
    private void populatePersonAccountCountryIfStatePresent(Account person) {
        // Because we aren't querying for these address fields, but rather are populating them from the attribute map,
        // we can't simply check if a field is null because we will get a "SObject row was retrieved via SOQL without
        // querying the requested field" exception if it is blank
        Set<String> populatedFields = person.getPopulatedFieldsAsMap().keySet();
        Boolean hasState = populatedFields.contains(Account.PersonMailingState + '');
        Boolean hasStateCode = populatedFields.contains(Account.PersonMailingStateCode + '');
        Boolean hasCountry = populatedFields.contains(Account.PersonMailingCountry + '');
        Boolean hasCountryCode = populatedFields.contains(Account.PersonMailingCountryCode + '');

        if ((hasState || hasStateCode) && (!hasCountry || !hasCountryCode)) {
            person.PersonMailingCountry = 'United States';
        }
    }

    private User createUserFromUserData(Auth.UserData data, Id contactId) {
        User user = new User(
                ProfileId = COMMUNITY_PROFILE_ID,
                ContactId = contactId,
                EmailEncodingKey = 'UTF-8'
        );

        updateUserFromUserData(user, data);

        return user;
    }

    private void updateUserFromUserData(User u, Auth.UserData data) {
        String myKomenUserId = data.identifier.right(18); // identifer is org id + user id
        String alias = data.username.length() > 8 ? data.username.left(8) : data.username;

        u.MyKomen_User_Id__c = myKomenUserId;
        u.Username = data.email;
        u.Alias = alias;
        u.Email = data.email;
        u.LastName = data.lastName;
        u.FirstName = data.firstName;

        Map<String, String> customAttributes = extractCustomAttributes(data);

        for(String dataKey : USER_FIELD_MAP.keySet()) {
            if(customAttributes.containsKey(dataKey)) {
                SObjectField sObjectField = USER_FIELD_MAP.get(dataKey);
                String stringValue = customAttributes.get(dataKey);

                if(!String.isBlank(stringValue)) {
                    u.put(sObjectField, convertStringToFieldType(stringValue, sObjectField));
                }
            }
        }

        KHC_AccountService.correctUserState(u);

        // This will only account for records where a state is present but no country, where the state is in the US
        if((u.State != null || u.StateCode != null) && u.Country == null) {
            u.Country = 'United States';
        }
    }

    private Object convertStringToFieldType(String stringValue, SObjectField sObjectField) {
        Schema.DisplayType displayType = sObjectField.getDescribe().getType();

        Object result;
        if(displayType == Schema.DisplayType.BOOLEAN) {
            result = Boolean.valueOf(stringValue);
        } else if(displayType == Schema.DisplayType.DATE) {
            result = Date.valueOf(stringValue);
        } else if(displayType == Schema.DisplayType.DATETIME) {
            result = Datetime.valueOf(stringValue);
        } else if(displayType == Schema.DisplayType.DOUBLE) {
            result = Double.valueOf(stringValue);
        } else if(displayType == Schema.DisplayType.INTEGER) {
            result = Integer.valueOf(stringValue);
        } else {
            result = stringValue;
        }

        return result;
    }

    private class RegistrationHandlerException extends Exception {}
}