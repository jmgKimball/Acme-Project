/**
 * Controller for the trial detail component, loads and displays data for a single clinical trial record
 *
 * @author Grant Adamson, Traction on Demand
 * @date 2020-05-21
 */
import {LightningElement, api, track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import loadTrial from '@salesforce/apex/CTClinicalTrialsService.loadTrial';

export default class CtTrialDetail extends NavigationMixin(LightningElement) {
    @track loadingComplete = false;
    @api recordId;
    record = {};
    locations = [];

    async connectedCallback() {
        let geo;
        try {
            geo = await this._getPosition();
        } catch (error) {
            console.log("Unable to get location: %o", error);
        }

        try {
            const params = {recordId: this.recordId};
            if(geo) {
                params.latitude = geo.coords.latitude;
                params.longitude = geo.coords.longitude;
            }
            const data = await loadTrial(params);
            this.record = data.trial;
            this.locations = data.locations.map(loc => ({record: loc, distance: Math.round(loc.dist)}));
            this.loadingComplete = true;
        } catch(error) {
            console.log(error);
        }
    }

    async _getPosition(options) {
        return new Promise(function (resolve, reject) {
            navigator.geolocation.getCurrentPosition(resolve, reject, options);
        });
    }

    get title() {
        if(this.record.Readable_Title__c) {
            return this.record.Readable_Title__c;
        }

        return this.record.Brief_Title__c;
    }

    get bookmarkId() {
        if(this.record.Clinical_Trial_Patients__r) {
            return this.record.Clinical_Trial_Patients__r[0].Id;
        }
    }

    get noConditions() {
        return !this.record.Clinical_Trial_Conditions__r ||
            this.record.Clinical_Trial_Conditions__r.filter(cond => cond.Condition__r.Description__c).length === 0;
    }

    get noInterventions() {
        return !this.record.NLM_Interventions__r ||
            this.record.NLM_Interventions__r.filter(inter => inter.Description__c).length === 0;
    }

    get description() {
        if(this.record.Readable_Brief_Description__c) {
            return this.record.Readable_Brief_Description__c;
        }

        return this.record.Clinical_Trial_Description_Brief__c;
    }

    get hasAgeRange() {
        return (this.record.Minimum_Age__c && this.record.Minimum_Age__c > 0) ||
            (this.record.Maximum_Age__c && this.record.Maximum_Age__c > 0);
    }

    get ageRange() {
        if(this.record.Minimum_Age__c && this.record.Minimum_Age__c > 0 &&
            this.record.Maximum_Age__c && this.record.Maximum_Age__c > 0) {
            return `Age Range: ${this.record.Minimum_Age__c} - ${this.record.Maximum_Age__c}`;
        }

        if(this.record.Minimum_Age__c && this.record.Minimum_Age__c > 0) {
            return `Minimum Age: ${this.record.Minimum_Age__c}`;
        }

        if(this.record.Maximum_Age__c && this.record.Maximum_Age__c > 0) {
            return `Maximum Age: ${this.record.Maximum_Age__c}`;
        }

        return null;
    }

    get hasCriteriaList() {
        return this.record.Clinical_Trial_Criteria__r;
    }

    get criteriaList() {
        const includes = [];
        const excludes = [];

        for(let criterion of this.record.Clinical_Trial_Criteria__r) {
            if(criterion.Include_Exclude__c === 'Include') {
                includes.push(criterion);
            } else if(criterion.Include_Exclude__c === 'Exclude') {
                excludes.push(criterion);
            }
        }

        return {includes, excludes};
    }

    get criteria() {
        return this.record.Readable_Eligibility_Summary__c
            ? this.record.Readable_Eligibility_Summary__c
            : this.record.Eligibility_Criteria__c;
    }

    handleBack() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Clinical_Trial__c',
                actionName: 'home',
            },
        });
    }

    handlePrint() {
        console.log("Printing");
    }

    handleMore() {
        console.log("More");
    }
}