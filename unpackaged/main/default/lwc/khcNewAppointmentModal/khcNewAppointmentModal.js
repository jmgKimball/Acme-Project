/**
 * Created by ako on 4/8/2021.
 */

import {LightningElement, wire} from 'lwc';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import ENCOUNTER_OBJECT from '@salesforce/schema/HealthCloudGA__EhrEncounter__c';
import Appointment_Type__c from '@salesforce/schema/HealthCloudGA__EhrEncounter__c.Appointment_Type__c';
import createAppointment from '@salesforce/apex/KHC_NewAppointmentController.createNewAppointment';
import {getObjectInfo, getPicklistValues} from "lightning/uiObjectInfoApi";
import SUCCESS_LABEL from "@salesforce/label/c.Success";
import APPOINTMENT_CREATED_MESSAGE from '@salesforce/label/c.Appointment_Created'
import ERROR_LABEL from "@salesforce/label/c.Error";
import ERROR_MESSAGE_LABEL from '@salesforce/label/c.Error';
import CREATE_AN_APPOINTMENT_LABEL from '@salesforce/label/c.Create_an_Appointment';
import TITLE_LABEL from '@salesforce/label/c.Title';
import Date_LABEL from '@salesforce/label/c.Date';
import TIME_LABEL from '@salesforce/label/c.Time';
import TYPE_LABEL from '@salesforce/label/c.Type';
import DESCRIPTION_LABEL from '@salesforce/label/c.Description';
import SEND_A_REMINDER_LABEL from '@salesforce/label/c.Send_a_reminder';
import DAYS_BEFORE_MY_APPOINTMENT_LABEL from '@salesforce/label/c.Days_before_my_appointment';


export default class KhcNewAppointmentModal extends LightningElement {

    createAnAppointmentLabel = CREATE_AN_APPOINTMENT_LABEL;
    appointmentTypes;
    titleLabel = TITLE_LABEL;
    dateLabel = Date_LABEL;
    timeLabel = TIME_LABEL;
    typeLabel = TYPE_LABEL;
    descriptionLabel = DESCRIPTION_LABEL;
    sendReminderLabel = SEND_A_REMINDER_LABEL;
    daysBeforeAppointmentLabel = DAYS_BEFORE_MY_APPOINTMENT_LABEL;
    disableReminderDays = true;
    greyOutDisabledFields = 'khc-disabled-field';
    appointmentRecordTypeId;

    @wire(getObjectInfo, {objectApiName: ENCOUNTER_OBJECT})
    encounterObjectInfo({ data, error }) {
        if (data) {
            let recordTypes = data.recordTypeInfos;
            if (recordTypes) {
                Object.keys(recordTypes).forEach(function (rtId) {
                    if (recordTypes[rtId].name == 'Community') {
                        this.appointmentRecordTypeId = rtId;
                    }
                }.bind(this));
            } else {
                this.appointmentRecordTypeId = data.defaultRecordTypeId;
            }
        }
    };

    @wire(getPicklistValues, {recordTypeId: '$appointmentRecordTypeId', fieldApiName: Appointment_Type__c})
    theTypes({data, error}) {
        if(data) {
            this.appointmentTypes = data.values;
        }

        if(error) {
            this.showToast(ERROR_LABEL, ERROR_MESSAGE_LABEL, 'error');
        }
    }

    /**
     * Creates a new appointment from the modal form on submission.
     * @returns An appointment object
     */
    async submitForm() {
        const titleInput = this.template.querySelector("lightning-input[data-name='title']");
        const appointmentDateInput = this.template.querySelector("lightning-input[data-name='appointmentDate']");
        const appointmentTimeInput = this.template.querySelector("lightning-input[data-name='appointmentTime']");
        const appointmentTypeInput = this.template.querySelector("lightning-combobox[data-name='appointmentType']");
        const appointmentDescriptionInput = this.template.querySelector("lightning-textarea[data-name='appointmentDescription']");
        const reminderDaysInput = this.template.querySelector("lightning-input[data-name='reminderDays']");

        if (!appointmentDateInput.reportValidity() || !appointmentTimeInput.reportValidity() ||
            !appointmentTypeInput.reportValidity() || !appointmentDescriptionInput.reportValidity()
            || !titleInput.reportValidity() || !reminderDaysInput.reportValidity()){
            return;
        }

        const title = titleInput.value;
        const appointmentDate = appointmentDateInput.value;
        const appointmentTime = appointmentTimeInput.value;
        const appointmentType = appointmentTypeInput.value;
        const appointmentDescription = appointmentDescriptionInput.value;
        const reminderDays = reminderDaysInput.value;

        try {
            await createAppointment({
                title: title, appointmentDate: appointmentDate, appointmentTime: appointmentTime,
                appointmentType: appointmentType, appointmentDescription: appointmentDescription, reminderDays: reminderDays
            }).then(result => {
                this.closeModal();
                this.showToast(SUCCESS_LABEL, APPOINTMENT_CREATED_MESSAGE, 'success');

                const refreshEvent = new CustomEvent('refresh');
                this.dispatchEvent(refreshEvent);
            });
        }

        catch (e) {
            if(e.body.pageErrors && e.body.pageErrors.length > 0) {
                let validationRuleError = e.body.pageErrors[0].message;
                this.showToast(ERROR_LABEL, validationRuleError, 'error');
            }
            else {
                this.showToast(ERROR_LABEL, ERROR_MESSAGE_LABEL, 'error');
            }
        }
    }

    openModal() {
        this.disableReminderDays = true;
        this.greyOutDisabledFields = 'khc-disabled-field';
        const modal = this.template.querySelector("c-mk-modal");
        modal.show();
    }

    closeModal() {
        const modal = this.template.querySelector("c-mk-modal");
        modal.hide();
    }

    showToast( title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    setReminderDays() {
        let dateInput = this.template.querySelector("lightning-input[data-name='appointmentDate']");
        this.disableReminderDays = !dateInput.value;
        if(this.disableReminderDays)  {
            this.template.querySelector("lightning-input[data-name='reminderDays']").value = '';
        }
        this.greyOutDisabledFields = this.disableReminderDays === true ? 'khc-disabled-field' : ''
    }
}