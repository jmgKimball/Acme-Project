/**
 * Created by cwico@tractionondemand.com on 2020-11-06.
 */

import {LightningElement, api, track, wire} from 'lwc';

import communityId from '@salesforce/community/Id';
import communityBasePath from '@salesforce/community/basePath';
import userId from '@salesforce/user/Id';
import isGuest from '@salesforce/user/isGuest';
import {NavigationMixin} from "lightning/navigation";
import {CurrentPageReference } from 'lightning/navigation';

// apex imports
import getUserInfo from '@salesforce/apex/MK_NavigationController.getUserInfo';
import getNavigationItems from '@salesforce/apex/MK_NavigationController.getNavigationItems';
import getUserNavigationItems from '@salesforce/apex/MK_NavigationController.getUserNavigationItems';
import getTemplateData from '@salesforce/apex/MK_NavigationController.getTemplateData';

export default class MkNavigation extends NavigationMixin(LightningElement)  {
	error;

	@api mode = 'Desktop';
	@api navigationMenuLabel;
	@api profileMenuLabel

	@track portalId;
	@track portalPath;
	@track menuItems = [];
	@track menuItemsUser = [];
	@track selectedLabel;
	@track isMobileMode = false;
	@track userId;

	@track userData = {};
	isGuest = isGuest;
	myKomenURL;

	@wire(CurrentPageReference) pageRef;

	renderedCallback() {
		this.isMobileMode = window.screen.width < 420;
	}

	get isLoggedIn() {
		return !isGuest;
	}

	get isDesktop() {
		return this.mode === 'Desktop';
	}

	get isMobile() {
		return this.mode === 'Mobile';
	}

	get photoUrl() {
		return 'background-image: url(' + this.userData.photoUrl + ')';
	}

	get isUserMenuExpanded() {
		return userId === this.selectedLabel;
	}

	get showUserMenu() {
		return !this.selectedLabel || this.isUserMenuExpanded;
	}

	connectedCallback() {
		this.portalId = 'Portal: ' + communityId;
		this.portalPath = communityBasePath;
		this.userId = userId;
		this.loadTemplateData();
		this.loadMenuData();
		this.loadMobileMenuData();
	}

	async loadMenuData() {
		const menus = await getNavigationItems({ label: this.navigationMenuLabel });

		// prepare hyperlinks
		menus.forEach(item => {
			let hyperlink = item.Target;

			if (item.Type === "InternalLink") {
				hyperlink = communityBasePath + item.Target;
			}

			item.hyperlink = hyperlink;
			item.pathName = window.location.pathname.toLowerCase();
			item.isSelected = hyperlink === window.location.pathname.toLowerCase();

		});

		// organize parent child
		menus.forEach(item => {
			if (!item.ParentId) {
				const menuItem = item;
				menuItem.children = menus.filter(menuItem => menuItem.ParentId === item.Id);
				menuItem.hasChildren = menuItem.children.length > 0;
				// highlight parent link
				if (!menuItem.isSelected) {
					menuItem.isSelected = menuItem.children.filter(child => child.isSelected).length > 0;
				}

				this.menuItems.push(menuItem)
			}
		});
	}

	async loadMobileMenuData() {
		this.userData = await getUserInfo();
		this.menuItemsUser = await getUserNavigationItems({ label: this.profileMenuLabel });
		// prepare hyperlinks
		this.menuItemsUser.forEach(item => {
			let hyperlink = item.Target;

			if (item.Type === "InternalLink") {
				hyperlink = communityBasePath + item.Target;
			}

			item.hyperlink = hyperlink;
			item.isSelected = hyperlink === window.location.pathname.toLowerCase();
		});
	}

	async loadTemplateData() {
		this.userData = await getTemplateData();
		this.myKomenURL = this.userData.myKomenURL;
	}

	navigateToItem(event) {
		this.selectedLabel = event.currentTarget.dataset.label;
		if(event.currentTarget.dataset.type === 'Event') {
			this[NavigationMixin.Navigate]({
				type: 'comm__loginPage',
				attributes: {
					actionName: event.currentTarget.dataset.target.toLowerCase()
				}
			});

			return;
		}
		else if (event.currentTarget.dataset.type === 'MenuLabel') {

			if (!this.isUserMenuExpanded) {
				this.menuItems.find(item => this.selectedLabel === item.Label).isExpanded = true;
			}
			return;
		}
		window.document.location.href = event.currentTarget.dataset.url;
	}

	resetNavigation(event) {

		if (!this.isUserMenuExpanded) {
			this.menuItems.find(item => item.isExpanded === true).isExpanded = false;
		}

		this.selectedLabel = null;
	}

	// Navigate an internal link
	navigateToInternalPage(item) {
		window.open(url, "_self");

		const pageName = communityBasePath + item.Target;
		this[NavigationMixin.Navigate]({
			type: "standard__webPage",
			attributes: {
				url: pageName
			}
		});
	}

	gotoLogin () {
		var myKomenURL = this.myKomenURL;

		if(myKomenURL) { // We are in MyKomen Health, use the "classic" login url to redirect to SSO
			window.location.href = "/login?startURL=/s/";
		} else { // We are in MyKomen, use the lightning community login url
			this[NavigationMixin.Navigate]({
				type: 'comm__loginPage',
				attributes: {
					actionName: 'login'
				}
			});

			return;
		}
	}

	gotoRegistration () {
		var myKomenURL = this.myKomenURL;

		if(myKomenURL) { // We are in MyKomen Health, use the external registration URL
			window.location.href = myKomenURL + "login/SelfRegister";
		} else { // We are in MyKomen, open the local Register page
			window.location.href = "/s/login/SelfRegister"
		}
	}
}