/**
 * Selector for MyKomen Setting custom metadata
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2020-09-16
 */
public inherited sharing class MK_MyKomenSettingsSelectorImpl implements MK_MyKomenSettingsSelector {
    public List<MyKomen_Setting__mdt> selectByKeyAndOptionalOrgId(String key, Id orgId) {
        return [
                SELECT Value__c
                FROM MyKomen_Setting__mdt
                WHERE Key__c = :key
                AND (Org_Id__c = :orgId OR Org_Id__c = NULL)
                ORDER BY Org_Id__c NULLS LAST
        ];
    }
}