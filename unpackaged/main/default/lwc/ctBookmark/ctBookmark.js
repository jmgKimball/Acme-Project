/**
 *
 *
 * @author Grant Adamson, Traction on Demand
 * @date 2020-05-25
 */
import {LightningElement, api} from 'lwc';
import bookmarkTrial from '@salesforce/apex/CTClinicalTrialsService.bookmarkTrial';
import removeBookmark from '@salesforce/apex/CTClinicalTrialsService.removeBookmark';

export default class CtBookmark extends LightningElement {
    @api recordId;
    @api trialId;

    async handleClick() {
        try {
            if(this.recordId) {
                await removeBookmark({recordId: this.recordId});
                this.recordId = null;
            } else {
                this.recordId = await bookmarkTrial({trialId: this.trialId});
            }
        } catch(error) {
            console.log("Error: %o", error);
        }
    }
}