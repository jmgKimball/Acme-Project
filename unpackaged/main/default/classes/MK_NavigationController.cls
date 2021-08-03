/**
 * Created by cwico@tractionondemand.com on 2020-11-06.
 */

public with sharing class MK_NavigationController {

	public static final String NAVIGATION_MASTER_LABEL = 'Default Navigation';
	public static final String PROFILE_MASTER_LABEL = 'Default User Profile Menu';

	// Allow for overriding in tests
	@TestVisible
	private static Id networkId = Network.getNetworkId();
	@TestVisible
	private static Boolean isGuest = (UserInfo.getUserType() == 'Guest');

	@AuraEnabled //(Cacheable=true)
	public static List<NavigationMenuItem> getNavigationItems(String label) {
		if(label == null) {
			label = NAVIGATION_MASTER_LABEL;
		}

		return getNavigationMenuItems(label);
	}

	@AuraEnabled //(Cacheable=true)
	public static List<NavigationMenuItem> getUserNavigationItems(String label) {
		if(label == null) {
			label = PROFILE_MASTER_LABEL;
		}
		return getNavigationMenuItems(label);
	}

	private static List<NavigationMenuItem> getNavigationMenuItems(String label) {
		Set<String> accessRestrictionValues = new Set<String>{'None'};
		if (!isGuest) {
			accessRestrictionValues.add('LoginRequired');
		}

		return [
				SELECT Status, Label, Type, TargetPrefs, Target, ParentId, Position, NavigationLinkSet.DeveloperName,
						NavigationLinkSet.NetworkId
				FROM NavigationMenuItem
				WHERE NavigationLinkSet.MasterLabel = :label
				AND Status = 'Live'
				AND AccessRestriction IN :accessRestrictionValues
				AND NavigationLinkSet.NetworkId = :networkId
				ORDER BY ParentId, Position
		];
	}

	@AuraEnabled
	public static UserData getUserInfo() {
		return new UserData();
	}

	public class UserData {

		@AuraEnabled
		public Id id {
			get {
				return UserInfo.getUserId();
			}
			set;
		}

		@AuraEnabled
		public String email {
			get {
				return UserInfo.getUserEmail();
			}
			set;
		}

		@AuraEnabled
		public String name {
			get {
				return UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
			}
			set;
		}

		@AuraEnabled
		public String type {
			get {
				return UserInfo.getUserType();
			}
			set;
		}

		@AuraEnabled
		public String photoUrl {
			get {
				return [SELECT SmallPhotoUrl FROM User WHERE Id = :UserInfo.getUserId()][0].SmallPhotoUrl;
			}
			set;
		}
	}

	/*
	 * Used by the custom template to get relevant data needed for rendering login/register/opt-in links
	 */
	@AuraEnabled
	public static TemplateData getTemplateData() {
		return new TemplateData();
	}

	public class TemplateData {
		@AuraEnabled
		public String myKomenURL {
			get {
				return MKH_SettingsService.getMyKomenURL();
			}
			set;
		}

		@AuraEnabled
		public Boolean isGuest {
			get {
				return UserInfo.getUserType() == 'Guest';
			}
			set;
		}
	}
}