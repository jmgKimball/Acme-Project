/**
 * Tests for MKH_SettingsService
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2020-09-16
 */
@IsTest
private class MKH_SettingsServiceTest {

    @IsTest
    static void getMyKomenURLMissing() {
        MK_SettingsLoader.settingsSelector = new MK_MyKomenSettingsSelectorMock();

        Exception caughtException;

        try {
            MKH_SettingsService.getMyKomenURL();
        } catch (Exception e) {
            caughtException = e;
        }

        System.assertNotEquals(null, caughtException, 'An exception should have been thrown');
        System.assertEquals(MK_SettingsLoader.NO_SETTING_FOUND_ERROR_MESSAGE + MKH_SettingsService.MYKOMEN_URL_KEY,
                caughtException.getMessage(), 'The exception should have the expected error message');
    }

    @IsTest
    static void getMyKomenURL() {
        String expectedValue = 'https://example.com';
        MK_SettingsLoader.settingsSelector = new MK_MyKomenSettingsSelectorMock(new MyKomen_Setting__mdt[]{
                new MyKomen_Setting__mdt(
                        Key__c = MKH_SettingsService.MYKOMEN_URL_KEY,
                        DeveloperName = 'URL',
                        Value__c = expectedValue
                )
        });

        String result = MKH_SettingsService.getMyKomenURL();

        System.assertEquals(expectedValue, result, 'The correct value should be returned');
    }

    @IsTest
    static void getMyKomenProfilePage() {
        String expectedValue = 'PROFILE';
        MK_SettingsLoader.settingsSelector = new MK_MyKomenSettingsSelectorMock(new MyKomen_Setting__mdt[]{
                new MyKomen_Setting__mdt(
                        Key__c = MKH_SettingsService.MYKOMEN_PROFILE_PAGE,
                        DeveloperName = 'Profile',
                        Value__c = expectedValue
                )
        });

        String result = MKH_SettingsService.getMyKomenProfilePage();

        System.assertEquals(expectedValue, result, 'The correct value should be returned');
    }

    @IsTest
    static void getMyKomenAccountPage() {
        String expectedValue = 'ACCOUNT';
        MK_SettingsLoader.settingsSelector = new MK_MyKomenSettingsSelectorMock(new MyKomen_Setting__mdt[]{
                new MyKomen_Setting__mdt(
                        Key__c = MKH_SettingsService.MYKOMEN_ACCOUNT_PAGE,
                        DeveloperName = 'Account',
                        Value__c = expectedValue
                )
        });

        String result = MKH_SettingsService.getMyKomenAccountPage();

        System.assertEquals(expectedValue, result, 'The correct value should be returned');
    }
}