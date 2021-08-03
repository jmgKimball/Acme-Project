/**
  * @description Account Selector
  * @author      Scott Taylor, Traction on Demand
  * @date        2020-11-17
  */

public inherited sharing class AccountSelector {
    /**
     * @description Get the details for a set of person account Ids
     * @author      Scott Taylor, Traction on Demand
     * @date        2020-11-17
     *
     * @param accountIds    List of account Ids
     *
     * @return      List of accounts for provided Ids
     */
    public List<Account> getPersonAccountById (List<String> accountIds) {
        return [ SELECT Id,
            Is_Insured__pc
            FROM Account WHERE Id IN :accountIds];
    }
}