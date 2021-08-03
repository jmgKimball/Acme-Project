/**
 * Selector for CaseTeamRole records
 * 
 * @author Nitin Chandwani, Traction on Demand
 * @date 2020-09-03
 */
public with sharing class CaseTeamRoleSelector {
    public List<CaseTeamRole> selectAll(){
        return [
                SELECT Id, Name, PreferencesVisibleInCSP, AccessLevel 
                FROM CaseTeamRole
                ORDER BY Name
            ];
    }
}
