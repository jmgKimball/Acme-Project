/**
 * Shared services used by various KHC/MKH components
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2020-09-22
 */
public with sharing class KHC_AccountService {
    public static final Set<String> VALID_STATES;
    public static final Set<String> VALID_STATE_CODES;

    static {
        VALID_STATES = new Set<String>();
        VALID_STATE_CODES = new Set<String>();

        for (PicklistEntry entry : User.StateCode.getDescribe().getPicklistValues()) {
            if (entry.active) {
                VALID_STATES.add(entry.label);
                VALID_STATE_CODES.add(entry.value);
            }
        }
    }

    /**
     * @param userId User record Id
     *
     * @return Account Id of patient account corresponding to current user, or null if none exists
     */
    @AuraEnabled(Cacheable=true)
    public static Id getAccountIdForUser(Id userId) {
        Id accountId;

        User user = getUserById(userId);
        if(user != null) {
            accountId = user.AccountId;
        }

        return accountId;
    }

    /**
     * @param userId User record Id
     *
     * @return Contact Id of patient account's contact corresponding to current user, or null if none exists
     */
    @AuraEnabled(Cacheable=true)
    public static Id getContactIdForUser(Id userId) {
        Id contactId;

        User user = getUserById(userId);
        if(user != null) {
            contactId = user.ContactId;
        }

        return contactId;
    }

    /**
     * @param userId User record Id
     *
     * @return User record
     */
    @AuraEnabled(Cacheable=true)
    public static User getUserRecord(Id userId) {
        List<User> users = [SELECT AccountId, ContactId, Contact.Relationship_To_Cancer__c, Contact.Breast_Health_topics_on_your_mind__c FROM User WHERE Id = :userId];
        if(users.size() > 0) {
            return users[0];
        }
        return null;
    }

    /**
     * @param userId User record Id
     *
     * @return User record
     */
    @AuraEnabled(Cacheable=true)
    public static User getUserById(Id userId) {
        User user;

        List<User> users = [SELECT AccountId, ContactId FROM User WHERE Id = :userId];
        if(users.size() > 0) {
            user = users[0];
        }

        return user;
    }

    /**
     * @param state Full name of a state
     *
     * @return validity of state according to state and country picklist values
     */
    public static Boolean isValidState(String state) {
        return VALID_STATES.contains(state);
    }

    /**
     * @param stateCode ISO state code value
     *
     * @return validity of state code according to state and country picklist values
     */
    public static Boolean isValidStateCode(String stateCode) {
        return VALID_STATE_CODES.contains(stateCode);
    }

    /**
     * Given a person account, attempt to correct the State value, if required
     * The method will validate the existing state value and if invalid will next check if it is a valid state code
     * If so, the value will be moved to the state code field
     * If not, the value will be cleared
     * @param personAccount Account record of type Person Account
     */
    public static void correctPersonAccountState(Account personAccount) {
        correctState(personAccount, Account.PersonMailingState, Account.PersonMailingStateCode);
        correctState(personAccount, Account.PersonOtherState, Account.PersonOtherStateCode);
    }

    /**
     * Given a User, attempt to correct the State value, if required
     * The method will validate the existing state value and if invalid will next check if it is a valid state code
     * If so, the value will be moved to the state code field
     * If not, the value will be cleared
     * @param u User record
     */
    public static void correctUserState(User u) {
        correctState(u, User.State, User.StateCode);
    }

    private static void correctState(SObject record, SObjectField stateField, SObjectField stateCodeField) {
        String state;

        try {
            state = (String) record.get(stateField);
        } catch (System.SObjectException e) {} // if field wasn't queried it will throw an error

        if(state == null) {
            return;
        }

        if(!isValidState(state)) {
            record.put(stateField, null);

            if(isValidStateCode(state)) {
                record.put(stateCodeField, state);
            }
        }
    }
}