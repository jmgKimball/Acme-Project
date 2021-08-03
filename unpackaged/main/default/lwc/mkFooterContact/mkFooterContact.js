/**
 * Created by cwico@tractionondemand.com on 2020-11-16.
 */

import {api, LightningElement, track} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getData from '@salesforce/apex/MK_FooterContactController.getData';

import CONTACT_FORM_SUCCESS_MSG_TITLE from '@salesforce/label/c.Contact_Form_Success_Msg_Title';
import CONTACT_FORM_SUCCESS_MSG from '@salesforce/label/c.Contact_Form_Success_Msg';
import CONTACT_FORM_TOPIC_REQUIRED from '@salesforce/label/c.Contact_Form_Topic_Required';
import CONTACT_FORM_NAME_REQUIRED from '@salesforce/label/c.Contact_Form_Name_Required';
import CONTACT_FORM_EMAIL_REQUIRED from '@salesforce/label/c.Contact_Form_Email_Required';
import CONTACT_FORM_ERROR from '@salesforce/label/c.Error';

export default class MkFooterContact extends LightningElement {

	@api mode = 'Accordion'; // 'Block'
	@api isHidden = false;

	@track isExpanded = false;
	@track isCaseModalOpen = false;
	@track data;

	async connectedCallback() {
		await this.loadData();
	}

	get isBlock() {
		return this.mode !== 'Accordion';
	}

	get isCollapsed() {
		return !this.isExpanded && !this.isBlock;
	}

	async loadData() {
		this.data = await getData();
	}

	toggle() {
		this.isExpanded = !this.isExpanded;
	}

	toggleCaseModal() {
		this.isCaseModalOpen = !this.isCaseModalOpen;
	}

	submitForm(event) {
		event.preventDefault();
		const topic = this.template.querySelector('.mk-topic').value;

		if (topic.length === 0) {
			this.dispatchEvent(new ShowToastEvent({
				title: CONTACT_FORM_ERROR,
				message: CONTACT_FORM_TOPIC_REQUIRED,
				variant: 'error'
			}));
			return;
		}

		const contactNameInput = this.template.querySelector("input[name='name']");
		const emailInput = this.template.querySelector("input[name='email']");

		if(!emailInput.reportValidity()) {
			return;
		}

		if(!contactNameInput.value) {
			this.dispatchEvent(new ShowToastEvent({
				title: CONTACT_FORM_ERROR,
				message: CONTACT_FORM_NAME_REQUIRED,
				variant: 'error'
			}));
			return;
		}

		if(!emailInput.value) {
			this.dispatchEvent(new ShowToastEvent({
				title: CONTACT_FORM_ERROR,
				message: CONTACT_FORM_EMAIL_REQUIRED,
				variant: 'error'
			}));
			return;
		}

		const formData = this.getFormData();
		this.postFormData(formData);
	}

	getFormData() {
		const form = this.template.querySelector('.mk-caseForm');
		return new FormData(form);
	}

	postFormData(formData) {
		const xhr = new XMLHttpRequest();
		xhr.open('POST', '/servlet/servlet.WebToCase?encoding=UTF-8', true);
		xhr.onload = () => {
			this.handleSubmitSuccess();
		};
		xhr.send(formData);
	}

	handleSubmitSuccess() {
		this.dispatchEvent(new ShowToastEvent({
			title: CONTACT_FORM_SUCCESS_MSG_TITLE,
			message: CONTACT_FORM_SUCCESS_MSG,
			variant: 'success'
		}));

		this.isCaseModalOpen = false;
	}
}