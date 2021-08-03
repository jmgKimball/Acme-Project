import { LightningElement } from 'lwc';

import ADD_A_MEDICATION_LABEL from "@salesforce/label/c.Add_a_new_Medication";
import BACK_LABEL from "@salesforce/label/c.Back";
import { loadStyle } from 'lightning/platformResourceLoader';
import MyKomenGlobalStylesheet from '@salesforce/resourceUrl/MyKomenGlobalStylesheet';
import {ShowToastEvent} from "lightning/platformShowToastEvent";

export default class KhcMyMedications extends LightningElement {

    showAddMedication = false;
    currentPage = 'Medication_List';
    selectedRecordId = null;

    addANewMedication = ADD_A_MEDICATION_LABEL;
    backLabel = BACK_LABEL;
    
    get showMedicationList(){
        return ( this.currentPage == 'Medication_List' ? true : false );
    }
    get showBack(){
        return ( this.currentPage != 'Medication_List' ? true : false );
    }

    handleAddMedicationClick( evt ){
        this.currentPage = 'Add_Medication';
        this.selectedRecordId = null;
        this.showAddMedication = true;
    }

    handleBackClick(){
        if( this.currentPage == 'Add_Medication' ){
            this.currentPage = 'Medication_List';
            this.showAddMedication = false;
        }
        if( this.currentPage == 'Edit_Medication' ){
            this.currentPage = 'Medication_List';
            this.showAddMedication = false;
        }
    }

    handleEdit( evt ){
        this.selectedRecordId = evt.detail;
        this.currentPage = 'Edit_Medication';
        this.showAddMedication = true;
    }

	connectedCallback() {
		loadStyle( this, MyKomenGlobalStylesheet )
			.catch(error => {
				const evt = new ShowToastEvent({
					title: "Error",
					message: error,
					variant: "error"
				});
				this.dispatchEvent(evt);
			});
	}
}