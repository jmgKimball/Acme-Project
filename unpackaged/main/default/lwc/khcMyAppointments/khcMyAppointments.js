import { LightningElement, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {updateRecord} from 'lightning/uiRecordApi';
import { msToTime } from "c/khcLwcUtils";
import {isAppointmentLaterToday} from "c/khcLwcUtils";
import getAppointments from '@salesforce/apex/KHC_MyAppointmentsCtrl.getAppointments';
import ENCOUNTER_OBJECT from '@salesforce/schema/HealthCloudGA__EhrEncounter__c';

import MY_APPOINTMENTS_HEADER_TEXT from '@salesforce/label/c.My_Appointments';
import UPCOMING_APPOINTMENTS_LABEL from '@salesforce/label/c.Upcoming_Apppointments';
import PAST_APPOINTMENTS_LABEL from '@salesforce/label/c.Past_Appointments';
import EDIT_APPOINTMENT_LABEL from '@salesforce/label/c.Edit_Appointment';
import UPDATE_APPOINTMENT_LABEL from '@salesforce/label/c.Update_Appointment';
import CANCEL_LABEL from '@salesforce/label/c.Cancel';
import SUCCESS_LABEL from "@salesforce/label/c.Success";
import SUCCESS_MESSAGE_LABEL from '@salesforce/label/c.Success';
import ERROR_LABEL from "@salesforce/label/c.Error";
import ERROR_MESSAGE_LABEL from '@salesforce/label/c.Error';
import NO_APPOINTMENTS_LABEL from '@salesforce/label/c.There_are_no_appointments';
import CREATE_NEW_APPOINTMENT_LABEL from '@salesforce/label/c.Create_New_Appointment';
import SEND_A_REMINDER_LABEL from '@salesforce/label/c.Send_a_reminder';
import DAYS_BEFORE_MY_APPOINTMENT_LABEL from '@salesforce/label/c.Days_before_my_appointment';

import list from './list.html';
import edit from './edit.html';

export default class KhcMyAppointments extends LightningElement {
    activePage = list;
    showSpinner = true;
    appointments;
    pastAppointments;
    ecounterFieldMap;
    encounterFieldList;
    loaded = false;
    editRecordId;
    appointmentTime;
    reminderDays;
    appointmentRecordTypeId;

    headerText = MY_APPOINTMENTS_HEADER_TEXT;
    upcomingAppointmentsLabel = UPCOMING_APPOINTMENTS_LABEL;
    pastAppointmentsLabel = PAST_APPOINTMENTS_LABEL;
    editHeaderText = EDIT_APPOINTMENT_LABEL;
    saveButtonLabel = UPDATE_APPOINTMENT_LABEL;
    cancelLabel = CANCEL_LABEL;
    noAppointmentsLabel = NO_APPOINTMENTS_LABEL;
    createNewAppointmentLabel = CREATE_NEW_APPOINTMENT_LABEL;
    sendReminderLabel = SEND_A_REMINDER_LABEL;
    daysBeforeAppointmentLabel = DAYS_BEFORE_MY_APPOINTMENT_LABEL;

    connectedCallback(){
        this.getAppointments();
    }

    render(){
        return this.activePage;
    }

    @wire(getObjectInfo, { objectApiName: ENCOUNTER_OBJECT })
    encounterObjectInfo({ data, error }) {
        if (data){
            let recordTypes = data.recordTypeInfos;
            if ( recordTypes ) {
                Object.keys(recordTypes).forEach(function (rtId) {
                    if (recordTypes[rtId].name == 'Community') {
                        this.appointmentRecordTypeId = rtId;
                    }
                }.bind(this));
            } else {
                this.appointmentRecordTypeId = data.defaultRecordTypeId;
            }

            let fieldList = [
                { apiName : 'Title__c', label : data.fields.Title__c.label },
                { apiName : 'Appointment_Date__c', label : data.fields.Appointment_Date__c.label },
                { apiName : 'Description__c', label : data.fields.Description__c.label },
                { apiName : 'Appointment_Type__c', label : data.fields.Appointment_Type__c.label },
                { apiName : 'Attended__c', label : data.fields.Attended__c.label }
            ];
            this.encounterFieldList = fieldList;
            let fieldMap = {
                Title__c : { label : data.fields.Title__c.label },
                Appointment_Date__c : { label : data.fields.Appointment_Date__c.label },
                Appointment_Time__c : { label : data.fields.Appointment_Time__c.label },
                Description__c : { label : data.fields.Description__c.label },
                Appointment_Type__c : { label : data.fields.Appointment_Type__c.label },
                Attended__c : { label : data.fields.Attended__c.label }
            };
            this.ecounterFieldMap = fieldMap;
            this.loaded = true;
        }
    }

    get hasAppointments(){
        return ( this.appointments != undefined && this.appointments.length > 0 );
    }

    get hasPastAppointments(){
        return ( this.pastAppointments != undefined && this.pastAppointments.length > 0 );
    }

    handleAttended( event ){
        this.showSpinner = true;
        const record = {
            fields: {
                Id: event.detail,
                Attended__c: true
            }
        };
        updateRecord( record ).then(result => {
            this.showToast( SUCCESS_LABEL, SUCCESS_LABEL, 'success');
            this.refreshComponent();
        })
        .catch(error => {
            this.showToast( ERROR_LABEL, error.body.message, 'error');
            this.showSpinner = false;
        });
    }
    handleEdit( event ){
        this.editRecordId = event.detail;
        this.activePage = edit;
        this.showSpinner = true;
    }

    handleLoad( event ){
        this.appointmentTime = event.detail.records[this.editRecordId].fields.Appointment_Time__c.value;
        this.reminderDays = event.detail.records[this.editRecordId].fields.Reminder_Days__c.value;
        this.showSpinner = false;
    }

    handleSubmit( event ){
        event.preventDefault();

        const reminderDaysInput = this.template.querySelector("lightning-input[data-name='reminderDays']");

        if(!reminderDaysInput.reportValidity()) {
            return;
        }
        this.showSpinner = true;
        const fields = event.detail.fields;
        fields.Appointment_Time__c = this.appointmentTime;
        fields.Reminder_Days__c = this.reminderDays;

        let appointmentDateInput = this.template.querySelector("lightning-input-field[data-name='Appointment_Date__c']");
        if(!appointmentDateInput.value && this.reminderDays) {
            this.showToast(ERROR_LABEL, 'The appointment must have a date to in order to set a reminder', 'error');
            this.showSpinner = false;
            return;
        }

        this.template.querySelector('lightning-record-edit-form').submit( fields );
    }

    handleSuccess(){
        this.showToast( SUCCESS_LABEL, SUCCESS_MESSAGE_LABEL, 'success' );
        this.refreshComponent();
    }

    handleTimeChange( event ){
        this.appointmentTime = event.detail.value;
    }
    handleReminderDays(event) {
        this.reminderDays = event.detail.value;
    }


    handleError( error ){
        this.showSpinner = false;
        this.showToast( ERROR_LABEL, ERROR_MESSAGE_LABEL, 'error' );
    }

    handleCancelClick(){
        this.activePage = list;
        this.editRecordId = undefined;
    }

    getAppointments(){
        getAppointments().then( result=>{
            let appointments = [];
            let pastAppointments = [];
            let now = new Date();
            result.forEach( appointment =>{
                //Populate title
                appointment.Title = '';
                if( appointment.Appointment_Date__c ){
                    appointment.Title += appointment.Appointment_Date__c;
                }

                let temp = (new Date(appointment.Appointment_Date__c));
                let appointmentDate = new Date(temp.getTime() + temp.getTimezoneOffset() * 60000);

                let appointmentIsLaterToday = isAppointmentLaterToday(now, appointment.Appointment_Date__c, appointment.Appointment_Time__c);

                appointment.Appointment_Date__c = appointmentDate;
                appointment.Appointment_Time__c = appointment.Appointment_Time__c != null ? msToTime(appointment.Appointment_Time__c) : appointment.Appointment_Time__c;

                if(appointmentIsLaterToday || appointmentDate > now) {
                    appointments.push(appointment);
                }

                else {
                    pastAppointments.push(appointment);
                }

                appointment.Attended = appointment.Attended__c == true ? 'Yes' : 'No'; 
            })
            this.appointments = appointments;
            //Sort past appointment
            let  sortedAppointment = pastAppointments.sort((a, b) => b.appointmentDate - a.appointmentDate);
            this.pastAppointments = sortedAppointment;
        }).catch( error =>{
            this.showToast( ERROR_LABEL, ERROR_MESSAGE_LABEL, 'error' );
        }).finally( resp =>{
            this.showSpinner = false;
        });
    }

    showToast( title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
    refreshComponent(){
        this.editRecordId = undefined;
        this.activePage = list;
        this.getAppointments();
    }
}