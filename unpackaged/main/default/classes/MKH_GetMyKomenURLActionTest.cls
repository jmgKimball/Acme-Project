/**
 * Tests for MKH_GetMyKomenURLAction
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2020-11-16
 */
@IsTest
private class MKH_GetMyKomenURLActionTest {

    @IsTest
    static void getMyKomenURL() {
        String expectedValue = 'https://example.com';
        MK_SettingsLoader.settingsSelector = new MK_MyKomenSettingsSelectorMock(new MyKomen_Setting__mdt[]{
                new MyKomen_Setting__mdt(
                        Key__c = MKH_SettingsService.MYKOMEN_URL_KEY,
                        DeveloperName = 'Test',
                        Value__c = expectedValue
                )
        });

        List<String> result = MKH_GetMyKomenURLAction.getMyKomenURL();

        System.assertEquals(1, result.size(), 'The list should contain one value');
        System.assertEquals(expectedValue, result[0], 'The correct value should be returned');
    }
}