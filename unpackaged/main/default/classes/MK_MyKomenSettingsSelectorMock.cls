/**
 * Mock selector implementation for testing classes that depend on use of custom settings via MK_SettingsLoader
 *
 * Because we can't insert custom metadata in tests, we have to mock the selector response to return values instead
 * This mock implementation simply returns whatever list is provided to the constructor
 * The most recent call parameters are stored in lastCallKey and lastCallOrgId, respectively
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2020-11-16
 */
@IsTest
public class MK_MyKomenSettingsSelectorMock implements MK_MyKomenSettingsSelector {

    private List<MyKomen_Setting__mdt> returnValue = new List<MyKomen_Setting__mdt>();
    private Map<String, List<MyKomen_Setting__mdt>> returnValueByKey = new Map<String, List<MyKomen_Setting__mdt>>();

    private String lastCallKey;
    private Id lastCallOrgId;

    /**
     * Construct a mock selector that will return an empty list for each call
     */
    public MK_MyKomenSettingsSelectorMock() {}

    /**
     * Construct a mock selector that will return a static result for each call
     * @param returnValue List of MyKomen_Setting__mdt records to be returned
     */
    public MK_MyKomenSettingsSelectorMock(List<MyKomen_Setting__mdt> returnValue) {
        this.returnValue = returnValue;
    }

    /**
     * Construct a mock selector that will return a result based on the key provided in the call
     * If no matching return value is found for the key, an empty list will be returned
     * @param returnValueByKey Map of key to List of MyKomen_Setting__mdt records
     */
    public MK_MyKomenSettingsSelectorMock(Map<String, List<MyKomen_Setting__mdt>> returnValueByKey) {
        this.returnValueByKey = returnValueByKey;
    }

    public List<MyKomen_Setting__mdt> selectByKeyAndOptionalOrgId(String key, Id orgId) {
        lastCallKey = key;
        lastCallOrgId = orgId;

        if(returnValueByKey.containsKey(key)) {
            return returnValueByKey.get(key);
        }

        return returnValue;
    }
}