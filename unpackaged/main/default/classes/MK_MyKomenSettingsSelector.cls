/**
 * Interface for MyKomen Settings Selector
 * Provided in order to mock the selector, since custom metadata records cannot be inserted in tests
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2020-09-16
 */
public interface MK_MyKomenSettingsSelector {
    List<MyKomen_Setting__mdt> selectByKeyAndOptionalOrgId(String key, Id orgId);
}