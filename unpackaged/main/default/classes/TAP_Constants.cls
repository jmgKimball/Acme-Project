/****************************************************************************************************************************************************************
* @author IVL Dev
* @date 19-Jul-2020
* @description This class contains constants for Treatment Assistance Program functionality
****************************************************************************************************************************************************************/
public class TAP_Constants {
    
    /******************************************************************
     * Constants for Application object
     * ***************************************************************/
    public static final String APPLICATION_STATUS_NEW = 'New';
    public static final String APPLICATION_STATUS_IN_REVIEW = 'In Review';
    public static final String APPLICATION_STATUS_NEED_MORE_INFO = 'Need More Information';
    public static final String APPLICATION_STATUS_DEFERRED = 'Deferred';
    public static final String APPLICATION_STATUS_APPROVED = 'Approved';
    public static final String APPLICATION_STATUS_REJECTED = 'Rejected';
    public static final String APPLICATION_STATUS_CANCELED = 'Canceled';
    
    /******************************************************************
     * Constants for Eligibility Criteria object
     * ***************************************************************/
    public static final String ELIGIBILITY_CRITERIA_INCOME_BASED = 'Income';
    public static final String ELIGIBILITY_CRITERIA_ZIP_BASED = 'ZIP';
    public static final String ELIGIBILITY_CRITERIA_USA_RESIDENT = 'USA Resident';
    public static final String ELIGIBILITY_CRITERIA_NO_AWARD = 'No Awards';
    public static final String ELIGIBILITY_CRITERIA_ACTIVE_TREATMENT = 'Active Treatment';
    
    /******************************************************************
     * Constants for Care Program object
     * ***************************************************************/
    
    public static final String CARE_PROGRAM_STATUS_ACTIVE = 'Active';
    
    /*****************************************************************
     * Constants for Eligibility Details object
     * **************************************************************/
    public static final String ELIGIBILITY_DETAIL_INCOME_RECORD_TYPE = 'Income_Based';
    
    /*****************************************************************
    * Constants for Eligibility Criteria
    * ****************************************************************/
    public static final String ELIGIBILITY_CRITERIA_STATUS = 'Active';

    
    /****************************************************************
     * Constants for Address
     * *************************************************************/
    public static final String COUNTRY_CODE_US = 'US';
    
    /***************************************************************
     * Constants for Payment object
     * ************************************************************/
	public static final String PAYMENT_STATUS_PENDING = 'Pending';
    public static final String PAYMENT_STATUS_PAID = 'Paid';
     public static final String PAYMENT_SUPPLIER_ID = '2689';
    
    /*************************************************************
     * Constants for TAP Inbox object
     * **********************************************************/
	public static final String TAP_INBOX_STATUS_PENDING = 'Pending';
    public static final String TAP_INBOX_STATUS_PROCESSED = 'Processed';
    
    /************************************************************
     * Constants for Feed Item object
     * *********************************************************/
	public static final String FEED_ITEM_TYPE_TEXTPOST = 'TextPost';
    public static final String FEED_ITEM_VISIBILITY_ALL_USERS = 'AllUsers';

    /***********************************************************
     * Generic Constants
     * ********************************************************/
    public static final String YES = 'Yes';
    public static final String NO = 'No';
    public static final String UNKNOWN = 'Unknown';
    
    /***********************************************************
     * Constants for TestDataFactory 
     * ********************************************************/
     public static final String PERSONACCOUNT_RECORDTYPE_NAME ='Person Account';
     public static final String INCOME_BASED_RECORDTYPE_NAME ='Income Based';
     public static final String LOCATION_BASED_RECORDTYPE_NAME ='Location Based';
     public static final String CARE_PROGRAM_TYPE = 'Treatment Assistance Program';
     public static final String CARE_PROGRAM_STATUS = 'Active';
     public static final String PROFILE_SYS_ADMIN_TEAM = 'System Administrator';
     public static final String PROFILE_MISSION_TEAM = 'Mission Data Entry';
     public static final String PROFILE_PROGRAM_OWNER_TEAM = 'Program Owner';
     public static final String PROFILE_ACCOUNTING_TEAM = 'Accounting';
     public static final String SYS_ADMIN_ALIAS = 'sysadmin';
     public static final String MISSION_ALIAS = 'mission';
     public static final String PROGRAM_ALIAS = 'Program';
     public static final String ACCOUNTING_ALIAS = 'account';
     public static final String SYS_ADMIN = 'systemuser@testorg.com';
     public static final String MISSION_TEAM = 'missionuser@testorg.com';
     public static final String PROGRAM_TEAM = 'programuser@testorg.com';
     public static final String ACCOUNTING_TEAM = 'accountinguser@testorg.com';
     public static final String PERMISSIONSET_MISSION_TEAM = 'Mission_Data_Entry_Permission_Set';
     public static final String PERMISSIONSET_HEALTH_FOUNDATION = 'HealthCloudFoundation';
     public static final String PERMISSIONSET_REPORT_DASHBOARDS = 'View_Public_Reports_and_Dashboards';
     public static final String PERMISSIONSET_HEALTH_CLOUD_LIMITED = 'HealthCloudLimited';
     public static final String PERMISSIONSET_HEALTH_CLOUD_LICENSE = 'HealthCloudPermissionSetLicense';
     public static final String PERMISSIONSET_HEALTH_CLOUD_STANDARD = 'HealthCloudStandard';
     public static final String PERMISSIONSETLICENSE_HEALTH_CLOUD = 'Health Cloud';
     Public static final String PERMISSIONSETLICENSE_HEALTH_CLOUD_PLATFORM = 'Health Cloud Platform';
     Public static final String SYS_ADMIN_LASTNAME = 'TestSystem';
     Public static final String MISSION_TEAM_LASTNAME = 'TestMission';
     Public static final String PROGRAM_TEAM_LASTNAME = 'TestProgram';
     Public static final String ACCOUNTING_TEAM_LASTNAME = 'TestAccounting';
     Public static final String EMAIL_HEADER = 'In-Reply-To';
     Public static final String EMAIL_SUBJECT = 'This is a test email subject';
     Public static final String EMAIL_FROM_ADDRESS = 'testemail@gmail.com';
     Public static final String EMAIL_TEXT_BODY = 'This is a test email body.';
     Public static final String EMAIL_TO_ADDRESS = 'test@testorg.com'; 
     Public static final String EMAIL_CC_ADDRESS = 'testccaddress@testorg.com';
     Public static final String EMAIL_FROM_NAME = 'Test Name';
     Public static final String EMAIL_HTML_BODY = 'Test Name';
}