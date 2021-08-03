/**
 *
 *
 * @author Grant Adamson, Traction on Demand
 * @date 2020-05-25
 */
import {LightningElement, api} from 'lwc';

export default class CtButton extends LightningElement {
    @api icon;
    @api title;
    @api borderless = false;
    @api inverse = false;
    @api color = "#b31064";
    @api inverseColor = "white";

    get buttonClass() {
        return `slds-p-around_none button ${this.borderless ? "" : " button-bordered"}`;
    }

    get buttonStyle() {
        if(this.inverse) {
            return `background-color: ${this.color}; ` +
                `${this.inverseColor ? " color: " + this.inverseColor : ""}`;
        }

        return `color: ${this.color}`;
    }

    get svgClass() {
        return `slds-icon ${this.borderless ? "slds-icon_small" : "slds-icon_x-small"}`;
    }
}