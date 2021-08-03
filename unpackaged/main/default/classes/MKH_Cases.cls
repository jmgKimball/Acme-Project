/**
 * Created by cwico@tractionondemand.com on 2021-01-18.
 */

public with sharing class MKH_Cases {

	@AuraEnabled
	public static List<Case> getCases() {
		User user = [SELECT AccountId, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
		return [
				SELECT
						AccountId, CaseNumber, Subject, Ticket_Status__c,
						IsClosed, Type, Status, Owner.Name,
						CreatedDate
				FROM Case
				WHERE AccountId = :user.AccountId
				ORDER BY CreatedDate DESC
				LIMIT 2000
		]; 
	}
}