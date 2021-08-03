/**
 * Tests for MKH_MyKomenRedirectorController
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2021-01-06
 */
@IsTest
private class MKH_MyKomenRedirectorControllerTest {
    private static final String TEST_MYKOMEN_URL = 'https://example.com/s/mykomen/';
    private static final String TEST_PROFILE_PAGE = 'my-profile/';
    private static final String TEST_ACCOUNT_PAGE = 'comm-my-account';

    @IsTest
    static void getRedirectorData() {
        // Stub out the settings selector to return fake metadata records, since we can't ensure these records exist
        MK_SettingsLoader.settingsSelector = new MK_MyKomenSettingsSelectorMock(
                new Map<String, List<MyKomen_Setting__mdt>>{
                        MKH_SettingsService.MYKOMEN_URL_KEY => new MyKomen_Setting__mdt[]{
                                new MyKomen_Setting__mdt(
                                        Key__c = MKH_SettingsService.MYKOMEN_URL_KEY,
                                        Value__c = TEST_MYKOMEN_URL
                                )
                        },
                        MKH_SettingsService.MYKOMEN_PROFILE_PAGE => new MyKomen_Setting__mdt[]{
                                new MyKomen_Setting__mdt(
                                        Key__c = MKH_SettingsService.MYKOMEN_PROFILE_PAGE,
                                        Value__c = TEST_PROFILE_PAGE
                                )
                        },
                        MKH_SettingsService.MYKOMEN_ACCOUNT_PAGE => new MyKomen_Setting__mdt[]{
                                new MyKomen_Setting__mdt(
                                        Key__c = MKH_SettingsService.MYKOMEN_ACCOUNT_PAGE,
                                        Value__c = TEST_ACCOUNT_PAGE
                                )
                        }
                }
        );

        Test.startTest();

        Map<String, String> result = MKH_MyKomenRedirectorController.getRedirectorData();

        Test.stopTest();

        Map<String, String> expected = new Map<String, String>{
                'myKomenURL' => TEST_MYKOMEN_URL,
                'profilePage' => TEST_PROFILE_PAGE,
                'accountPage' => TEST_ACCOUNT_PAGE
        };
        System.assertEquals(expected, result, 'The expected data should be returned');
    }
}