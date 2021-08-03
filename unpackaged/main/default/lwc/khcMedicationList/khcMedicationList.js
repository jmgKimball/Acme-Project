import { LightningElement, wire  } from 'lwc';
import getMedications from '@salesforce/apex/KHC_MedicationController.getMedications';

import MY_MEDICATION_HEADER_LABEL from "@salesforce/label/c.My_Medications";
import EDIT_LABEL from "@salesforce/label/c.Edit";
import NO_RECORD_FOUND_LABEL from "@salesforce/label/c.No_Records_Found";

export default class KhcMedicationList extends LightningElement {
    showEdit = true;
    medications = [];

    myMedicationHeader = MY_MEDICATION_HEADER_LABEL;
    editLabel = EDIT_LABEL;
    noRecordFoundLabel = NO_RECORD_FOUND_LABEL;
    
    connectedCallback(){
        this.getMedications();
    }
    editMedicationStatement( evt ){
        const editEvent = new CustomEvent("edit", { detail: evt.target.dataset.recordId } );
        this.dispatchEvent( editEvent );
    }

    handleRecordChange(){
        this.medications = [];
        this.getMedications() 
    }
    
    getMedications(){
        
        getMedications()
            .then( result => {
                this.medications = result;
            })
            .catch( error => {
                console.log( error );
            });
    }
}