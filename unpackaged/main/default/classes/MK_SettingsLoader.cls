/**
 * Loads custom metadata setting values based on key provided
 * Will first look for records specific to the current org's Id, then fall back to "global" values
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2020-09-16
 */
public inherited sharing class MK_SettingsLoader {
    @TestVisible
    private static final String NO_SETTING_FOUND_ERROR_MESSAGE = 'No setting found for key specified: ';

    @TestVisible
    private static MK_MyKomenSettingsSelector settingsSelector = new MK_MyKomenSettingsSelectorImpl();

    public String load(String key) {
        Id orgId = UserInfo.getOrganizationId();
        List<MyKomen_Setting__mdt> settings = settingsSelector.selectByKeyAndOptionalOrgId(key, orgId);

        if(settings.isEmpty()) {
            throw new SettingsLoaderException(NO_SETTING_FOUND_ERROR_MESSAGE + key);
        }

        return settings[0].Value__c;
    }

    class SettingsLoaderException extends Exception {}
}