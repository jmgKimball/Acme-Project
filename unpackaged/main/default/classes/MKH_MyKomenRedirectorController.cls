/**
 * Server-side controller for the MyKomen Redirector Component
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2021-01-06
 */
public with sharing class MKH_MyKomenRedirectorController {

    @AuraEnabled(Cacheable=true)
    public static Map<String, String> getRedirectorData() {

        return new Map<String, String>{
                'myKomenURL' => MKH_SettingsService.getMyKomenURL(),
                'profilePage' => MKH_SettingsService.getMyKomenProfilePage(),
                'accountPage' => MKH_SettingsService.getMyKomenAccountPage()
        };
    }
}