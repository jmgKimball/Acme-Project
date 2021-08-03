@isTest
public class KHC_MyContactsControllerTest {
    static String testingEmail = 'test@test.com';
    static Map<String, String> reciprocalRoles = new Map<String,String>{ 'Caregiver' => 'Patient', 'Family' => 'Patient', 'Other' => 'Patient' };
    static Contact con;

    @TestSetup
    static void makeData(){
        Account a = MKH_TestDataFactory.createPersonAccount('First', 'Last', testingEmail, true);
        con = [SELECT FirstName, LastName, Email FROM Contact WHERE AccountId = :a.Id];
        MKH_TestDataFactory.createCommunityUser( con, true, true);
        List<HealthCloudGA__ReciprocalRole__c> reciprocalRoles = KHC_TestUtility.insertReciprocalRoles( reciprocalRoles, true );
        List<HealthCloudGA__ContactContactRelation__c> conConRels = new List<HealthCloudGA__ContactContactRelation__c>();
        for( HealthCloudGA__ReciprocalRole__c role : reciprocalRoles ){
            conConRels.add( KHC_TestUtility.insertConConRel( con.Id, con.Id, role.Id, false ) );
        }
        INSERT conConRels;
    }

    @isTest
    static void getContactsTest(){
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];
        System.runAs( commUsr ){
            Test.startTest();
            List<HealthCloudGA__ContactContactRelation__c> conConRels = KHC_MyContactsController.getContacts();
            Test.stopTest();
            System.assertEquals( 3, conConRels.size(), 'Three conConRels must be returned');
        }
    }

    @isTest
    static void getRolesTest(){
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];
        System.runAs( commUsr ){
            Test.startTest();
            List<HealthCloudGA__ReciprocalRole__c> roles = KHC_MyContactsController.getRoles();
            Test.stopTest();
            System.assertEquals( 3, roles.size(), 'Three role must be returned');
        }
    }

    @isTest
    static void getLoggedInUserTest(){
        User commUsr = [SELECT Id, AccountId FROM User WHERE  email = :testingEmail LIMIT 1];
        User loggedInUser;
        System.runAs( commUsr ){
            Test.startTest();
            loggedInUser = KHC_MyContactsController.getLoggedInUser();
            Test.stopTest();
        }
        System.assertEquals( commUsr.Id, loggedInUser.Id, 'User retuned must have the same Id.');
    }
}