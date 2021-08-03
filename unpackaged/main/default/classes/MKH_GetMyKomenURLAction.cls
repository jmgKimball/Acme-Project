/**
 * Invocable Method that fetches the appropriate MyKomen URL that corresponds to the current environment
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2020-11-16
 */
public without sharing class MKH_GetMyKomenURLAction {

    @InvocableMethod(Label='Get MyKomen URL' Description='Returns the MyKomen URL that corresponds to the current environment')
    public static List<String> getMyKomenURL() {
        return new String[]{
                MKH_SettingsService.getMyKomenURL()
        };
    }
}