/**
 * Created by cwico@tractionondemand.com on 2020-11-16.
 */

public with sharing class MK_FooterContactController {

	@AuraEnabled
	public static Data getData() {
		return new Data();
	}

	public class Data {

		@AuraEnabled
		public Id orgId {
			get {
				return UserInfo.getOrganizationId();
			}
			set;
		}

		@AuraEnabled
		public Id caseRecordTypeId {
			get {
				return  Schema.SObjectType.Case.getRecordTypeInfosByName().get('General Inquiry')?.getRecordTypeId();
			}
			set;
		}

		@AuraEnabled
		public String userEmail {
			get {
				return UserInfo.getUserType() != 'Guest' ? UserInfo.getUserEmail() : '';
			}
			set;
		}

		@AuraEnabled
		public String userFullName {
			get {
				return UserInfo.getUserType() != 'Guest' ? UserInfo.getFirstName() + ' ' + UserInfo.getLastName() : '';
			}
			set;
		}

		@AuraEnabled
		public Id getPatientId {
			get {
				  User usr = getLoggedInUserDetails();
				  System.debug('** usr ' + usr);
				  System.debug('** usr.AccountId ' + usr.AccountId);
				  return usr.AccountId;
			}
			set;
		}

	}

	@AuraEnabled
	public static User getLoggedInUserDetails(){
		User currUser = MyKomenHealthUtility.getLoggedInUserDetails();
		if( currUser != null ){
			return currUser;
		}
		return null;
	}
}