/**
 * Tests for KHC_FamilyHealthHistoryCtlr
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2020-09-17
 */
@IsTest
private class KHC_FamilyHealthHistoryCtlrTest {

    private static final String CONDITION_NAME = 'Condition 1';
    private static final String HISTORY_1 = 'History 1';
    private static final String HISTORY_2 = 'History 2';
    private static final String EMAIL = 'healthhistorytest@example.com';

    @TestSetup
    static void setup() {
        Account a = MKH_TestDataFactory.createPersonAccount('First', 'Last', EMAIL, true);

        Patient_Contact__c h1 = new Patient_Contact__c(
                Patient__c = a.Id,
                Family_Member_Name__c = HISTORY_1
        );
        Patient_Contact__c h2 = new Patient_Contact__c(
                Patient__c = a.Id,
                Family_Member_Name__c = HISTORY_2
        );
        insert new Patient_Contact__c[] { h1, h2 };

        insert new Family_Medical_History_Condition__c(
                Family_Medical_History__c = h1.Id,
                Condition_Name__c = CONDITION_NAME
        );
    }

    @IsTest
    static void loadHistory() {
        Account a = getPatientAccount();

        Test.startTest();

        List<Patient_Contact__c> result = KHC_FamilyHealthHistoryCtlr.loadHistory(a.Id);

        Test.stopTest();

        System.assertEquals(2, result.size(), 'The expected number of records should have been returned');
        System.assertEquals(1, result[0].Family_Medical_History_Conditions__r.size(),
                'The expected number of child records should have been returned');
    }

    @IsTest
    static void updateConditions() {
        Family_Medical_History_Condition__c existingCondition = getExistingCondition();

        Family_Medical_History_Condition__c newCondition = new Family_Medical_History_Condition__c(
                Condition_Name__c = 'Bonus Eruptus',
                Family_Medical_History__c = existingCondition.Family_Medical_History__c
        );

        Family_Medical_History_Condition__c[] conditionsToInsert = new Family_Medical_History_Condition__c[]{
                newCondition
        };
        Family_Medical_History_Condition__c[] conditionsToDelete = new Family_Medical_History_Condition__c[]{
                existingCondition
        };


        Test.startTest();

        KHC_FamilyHealthHistoryCtlr.updateConditions(conditionsToInsert, conditionsToDelete);

        Test.stopTest();

        List<Family_Medical_History_Condition__c> result = [
                SELECT Condition_Name__c
                FROM Family_Medical_History_Condition__c
                WHERE Condition_Name__c IN :new String[]{
                        existingCondition.Condition_Name__c,
                        newCondition.Condition_Name__c
                }
        ];

        System.assertEquals(1, result.size(), 'One record should be present');
        System.assertEquals(newCondition.Condition_Name__c, result[0].Condition_Name__c,
                'It should be the new condition');
    }
    
    private static Account getPatientAccount() {
        return [SELECT Id FROM Account WHERE PersonEmail = :EMAIL];
    }

    private static Family_Medical_History_Condition__c getExistingCondition() {
        return [
                SELECT Family_Medical_History__c, Condition_Name__c
                FROM Family_Medical_History_Condition__c
                WHERE Condition_Name__c = :CONDITION_NAME
        ];
    }
}