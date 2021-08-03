/**
 * Created by ako on 3/11/2021.
 */

import {LightningElement, track, wire} from 'lwc';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAppointment from '@salesforce/apex/KHC_MyAppointmentsCtrl.getAppointments';
import ENCOUNTER_OBJECT from '@salesforce/schema/HealthCloudGA__EhrEncounter__c';
import NEXT_APPOINTMENT_LABEL from '@salesforce/label/c.Next_Appointment';
import All_APPOINTMENTS_LABEL from '@salesforce/label/c.All_Appointments';
import CREATE_AN_APPOINTMENT_LABEL from '@salesforce/label/c.Create_an_Appointment';
import NO_UPCOMING_APPOINTMENTS_LABEL from '@salesforce/label/c.No_Upcoming_Appointments';
import ERROR_LABEL from "@salesforce/label/c.Error";
import ERROR_MESSAGE_LABEL from '@salesforce/label/c.Error';
import {msToTime} from "c/khcLwcUtils";
import {isAppointmentLaterToday} from "c/khcLwcUtils";

export default class KhcNextAppointment extends LightningElement {
    loaded = false;
    nextAppointmentLabel = NEXT_APPOINTMENT_LABEL;
    allAppointmentsLabel = All_APPOINTMENTS_LABEL;
    createAnAppointmentLabel = CREATE_AN_APPOINTMENT_LABEL;
    noUpcomingAppointmentsLabel = NO_UPCOMING_APPOINTMENTS_LABEL;
    @track appointment;
    encounterFields;
    error;

    @wire(getObjectInfo, {objectApiName: ENCOUNTER_OBJECT})
    encounterObjectInfo({data, error}) {
        if(data) {
            this.encounterFields = {
                Provider_Name__c: {label: data.fields.Provider_Name__c.label},
                Appointment_Date__c: {label: data.fields.Appointment_Date__c.label},
                Appointment_Time__c: {label: data.fields.Appointment_Time__c.label},
                Description__c: {label: data.fields.Description__c.label},
                Appointment_Type__c: {label: data.fields.Appointment_Type__c.label},
                Attended__c: {label: data.fields.Attended__c.label},
                Title__c: {label: data.fields.Title__c.label}
            };
            this.loaded = true;
        } else if(error){
            console.error(error);
            this.showToast(ERROR_LABEL, ERROR_MESSAGE_LABEL, 'error');
        }
    }

    connectedCallback() {
        this.getAppointment();
    }

    get hasAppointment() {
        return this.appointment !== undefined;
    }

    get hasAppointmentTime() {
        return this.appointment.Appointment_Time__c !== undefined;
    }

    get hasAppointmentDate() {
        return this.appointment.Appointment_Date__c !== undefined;
    }

    /**
     *  Gets the next appointment from the list of all appointments.
     *  It first checks if an appointment is today and that its time has
     *  not passed yet. If so, that appointment is selected and function ends.
     *  If the appointment is not today, it gets the next upcoming appointment.
     */

    getAppointment() {
        getAppointment().then(result => {
            if (result !== null) {
                for (let i = 0; i < result.length; i++) {
                    let now = new Date();
                    let temp = (new Date(result[i].Appointment_Date__c));
                    let appointmentDate = new Date(temp.getTime() + temp.getTimezoneOffset() * 60000);

                    let appointmentIsLaterToday = isAppointmentLaterToday(now, appointmentDate, result[i].Appointment_Time__c);

                    if (appointmentDate > now || appointmentIsLaterToday) {
                        result[i].Appointment_Date__c = appointmentDate;
                        this.appointment = result[i];
                        break;

                    }
                }
            }
        }).catch(error => {
            console.error(error);
            this.showToast(ERROR_LABEL, ERROR_MESSAGE_LABEL, 'error');
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
}