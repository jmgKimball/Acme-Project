/**
 *
 *
 * @author Grant Adamson, Traction on Demand
 * @date 2020-05-25
 */
import {LightningElement, api} from 'lwc';

export default class CtDetailAccordion extends LightningElement {
    @api expanded = false;
    @api disabled = false;
    @api icon;
    @api title;

    handleToggle() {
        this.expanded = !this.expanded;
    }
}