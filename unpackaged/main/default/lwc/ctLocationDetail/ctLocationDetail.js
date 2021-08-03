/**
 * Component for rendering the details of a clinical trial location, including a map
 *
 * @author Grant Adamson, Traction on Demand
 * @date 2020-06-02
 */
import {LightningElement, api} from 'lwc';

export default class CtLocationDetail extends LightningElement {
    @api value;

    get mapMarkers() {
        const record = this.value.record;

        const location = {};
        if(record.Street_Address__c) {
            location.Street = record.Street_Address__c;
        }
        if(record.City__c) {
            location.City = record.City__c;
        }
        if(record.State__c) {
            location.State = record.State__c;
        }
        if(record.Country__c) {
            location.Country = record.Country__c;
        }
        if(record.Zip__c) {
            location.PostalCode = record.Zip__c;
        }

        return [{location}];
    }

    get address() {
        const record = this.value.record;

        const addressArray = []
        if(record.Street_Address__c) {
            addressArray.push(record.Street_Address__c);
        }
        if(record.City__c || record.State__c) {
            addressArray.push(this._joinAddressLineElements(record.City__c, record.State__c));
        }

        if(record.Country__c || record.Zip__c) {
            addressArray.push(this._joinAddressLineElements(record.Country__c, record.Zip__c));
        }

        return addressArray.join("\n");
    }

    _joinAddressLineElements(element1, element2) {
        const lineTwoParts = [];
        if(element1) {
            lineTwoParts.push(element1);
        }
        if(element2) {
            lineTwoParts.push(element2);
        }

        return lineTwoParts.join(", ");
    }
}