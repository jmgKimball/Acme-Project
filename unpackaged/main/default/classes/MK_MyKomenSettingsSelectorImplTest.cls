/**
 * Tests for MK_MyKomenSettingsSelectorImpl
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2020-09-16
 */
@IsTest
private class MK_MyKomenSettingsSelectorImplTest {

    // Because we can't perform DML on Custom Metadata for testing, just run a query we know will have no results
    @IsTest
    static void selectByDeveloperNameAndOptionalOrgId() {
        List<MyKomen_Setting__mdt> result = new MK_MyKomenSettingsSelectorImpl().selectByKeyAndOptionalOrgId(
                'BAD_KEY_VALUE', UserInfo.getOrganizationId());

        System.assert(result.isEmpty(), 'No records should be returned');
    }
}