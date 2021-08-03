import { LightningElement, api } from 'lwc';
import EDIT_LABEL from '@salesforce/label/c.Edit';
import ATTENDED_LABEL from '@salesforce/label/c.Attended';
import SEND_A_REMINDER_LABEL from '@salesforce/label/c.Send_a_reminder';
import DAYS_BEFORE_MY_APPOINTMENT_LABEL from '@salesforce/label/c.Days_before_my_appointment';

export default class KhcAppointmentDetail extends LightningElement {
    @api appointment;
    @api ecounterFieldMap;

    editLabel = EDIT_LABEL;
    attendedLabel = ATTENDED_LABEL;
    sendReminderLabel = SEND_A_REMINDER_LABEL;
    daysBeforeAppointmentLabel = DAYS_BEFORE_MY_APPOINTMENT_LABEL;

    get showEdit(){
        if( this.appointment.Appointment_Type__c == 'Patient Navigation' ) return false;
        return true;
    }
    handleEdit(){
        const editEvent = new CustomEvent( 'edit', { detail: this.appointment.Id });
        this.dispatchEvent( editEvent );
    }

    handleAttended(){
        if(!this.appointment.Attended__c) {
            const attendedEvent = new CustomEvent( 'attended', { detail: this.appointment.Id });
            this.dispatchEvent( attendedEvent );
        }
    }
}