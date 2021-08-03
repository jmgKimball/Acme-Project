/**
 * A single list item in a clinical trials list
 *
 * @author Grant Adamson, Traction on Demand
 * @date 2020-05-15
 */
import {LightningElement, api, track} from 'lwc';

export default class CtTrialListItem extends LightningElement {
    record;
    _closestLocation;
    _locations;

    @api
    set value(data) {
       this.record = data.trial;
       this._closestLocation = data.closestLocation;
       this._locations = data.locations;
    }

    get value() {

    }

    get bookmarkId() {
        if(this.record.Clinical_Trial_Patients__r) {
            return this.record.Clinical_Trial_Patients__r[0].Id;
        }
    }

    get title() {
        if(this.record.Readable_Title__c) {
            return this.record.Readable_Title__c;
        }

        return this.record.Brief_Title__c;
    }

    get joinedConditions() {
        let conditionList = [];
        if(this.record.Clinical_Trial_Conditions__r) {
            conditionList = this.record.Clinical_Trial_Conditions__r.map(condition => condition.Condition_Name__c);
        }

        return conditionList.join(", ");
    }

    get locationList() {
        if(!this._locations) {
            return null;
        }
        
        const locationList = this._locations.map(loc => loc.State__c);
        return [...new Set(locationList)].join(", "); // Dedupe the list
    }

    get hasDistance() {
        return this._closestLocation && this._closestLocation.dist;
    }

    get distance() {
        if(!this.hasDistance) {
            return null;
        }

        return Math.round(this._closestLocation.dist);
    }

    handleSelect() {
        this.dispatchEvent(new CustomEvent("select", {detail: this.record.Id}));
    }
}