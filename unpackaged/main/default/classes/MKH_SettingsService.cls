/**
 * Shared service for fetching various setting values related to the MyKomen Health community
 * Uses shared functionality in MK_Settings* ported from the MyKomen environment
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2020-09-16
 */
public without sharing class MKH_SettingsService {
    @TestVisible
    private static final String MYKOMEN_URL_KEY = 'MyKomen_URL';
    @TestVisible
    private static final String MYKOMEN_PROFILE_PAGE = 'MyKomen_Profile_Page';
    @TestVisible
    private static final String MYKOMEN_ACCOUNT_PAGE = 'MyKomen_Account_Page';

    private static MK_SettingsLoader settingsLoader = new MK_SettingsLoader();

    /**
     * @return URL for to the MyKomen Community that corresponds to the current sandbox or production environment
     */
    @AuraEnabled(Cacheable=true)
    public static String getMyKomenURL() {
        return settingsLoader.load(MYKOMEN_URL_KEY);
    }

    /**
     * @return Return the path the profile page on MyKomen
     */
    @AuraEnabled(Cacheable=true)
    public static String getMyKomenProfilePage() {
        return settingsLoader.load(MYKOMEN_PROFILE_PAGE);
    }

    /**
     * @return Return the path to the account page on MyKomen
     */
    @AuraEnabled(Cacheable=true)
    public static String getMyKomenAccountPage() {
        return settingsLoader.load(MYKOMEN_ACCOUNT_PAGE);
    }
}