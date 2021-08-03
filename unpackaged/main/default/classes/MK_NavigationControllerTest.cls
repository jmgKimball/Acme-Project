/**
 * Created by cwico@tractionondemand.com on 2020-11-12.
 */

@IsTest(IsParallel=true)
private class MK_NavigationControllerTest {
    private static final String NETWORK_NAME = 'MKH';
    private static final Id NETWORK_ID = [SELECT Name FROM Network WHERE Name = :NETWORK_NAME LIMIT 1]?.Id;

    @IsTest
    static void getNavigationItems() {
        MK_NavigationController.networkId = NETWORK_ID; // Network.getNetworkId returns null in tests

        Test.startTest();

        List<NavigationMenuItem> result = MK_NavigationController.getNavigationItems(null);

        Test.stopTest();

        // Since we can't confirm the menu will exist at runtime, all we can assert is that the method runs
        System.assertNotEquals(null, result, 'The method should return a value');
    }

    @IsTest
    static void getUserNavigationItems() {
        MK_NavigationController.networkId = NETWORK_ID; // Network.getNetworkId returns null in tests

        Test.startTest();

        List<NavigationMenuItem> result = MK_NavigationController.getUserNavigationItems(null);

        Test.stopTest();

        // Since we can't confirm the menu will exist at runtime, all we can assert is that the method runs
        System.assertNotEquals(null, result, 'The method should return a value');
    }

    @IsTest
    static void getUserInfo() {
        MK_NavigationController.UserData userData = MK_NavigationController.getUserInfo();
        System.assertEquals(UserInfo.getUserEmail(), userData.email);
        System.assertEquals(UserInfo.getUserId(), userData.id);
        System.assertNotEquals(null, userData.name);
        System.assertNotEquals(null, userData.photoUrl);
    }

    @IsTest
    static void getTemplateData() {
        MK_NavigationController.TemplateData templateData = MK_NavigationController.getTemplateData();
        System.assertEquals(false, templateData.isGuest, 'The running user is not a guest');
    }
}