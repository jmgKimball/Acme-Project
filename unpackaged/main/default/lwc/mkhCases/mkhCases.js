/**
 * Created by cwico@tractionondemand.com on 2021-01-18.
 */

import {api, LightningElement, track} from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import getCases from '@salesforce/apex/MKH_Cases.getCases';

import CASE_DATE from '@salesforce/label/c.Case_Date';
import CASE_NUMBER from '@salesforce/label/c.Case_Number';
import CASE_OWNER from '@salesforce/label/c.Case_Owner';
import CASE_STATUS from '@salesforce/label/c.Case_Status';
import CASE_SUBJECT from '@salesforce/label/c.Case_Subject';

import basePath from '@salesforce/community/basePath';
import { NavigationMixin } from 'lightning/navigation';

export default class MkhCases extends NavigationMixin(LightningElement) {

	communityBaseUrl ;
	@track cases;
	casesList = [];

	@track labels = {
		CASE_DATE: CASE_DATE,
		CASE_NUMBER: CASE_NUMBER,
		CASE_OWNER: CASE_OWNER,
		CASE_STATUS: CASE_STATUS,
		CASE_SUBJECT: CASE_SUBJECT
	}

	get isDesktop() {
        return FORM_FACTOR === 'Large';
    }

	async connectedCallback() {
		await this.loadData();
	}

	loadData() {
		var urlString = window.location.href;
		this.communityBaseUrl = urlString.substring(0, urlString.indexOf("/s"))+basePath + '/detail/';

		getCases().then( result =>{
			let caseList = [];
			result.forEach( res => {
				var cas ={};
				cas.URL = this.communityBaseUrl + res.Id;
				cas.CaseNumber = res.CaseNumber;
				cas.Subject = res.Subject;
				cas.Ticket_Status__c = res.Ticket_Status__c;
				cas.CreatedDate = res.CreatedDate;
				caseList.push(cas);
			});
			this.casesList = caseList;
			}).catch( error => {
			console.error( error );
		});
	}

}