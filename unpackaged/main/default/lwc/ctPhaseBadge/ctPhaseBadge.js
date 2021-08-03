/**
 *
 *
 * @author Grant Adamson, Traction on Demand
 * @date 2020-05-26
 */
import {LightningElement, api} from 'lwc';

export default class CtPhaseBadge extends LightningElement {
    @api value;

    get phase() {
        if(!this.value) {
            return "Not Known";
        }

        const phaseList = this.value.split(";");

        const cleanList = [];
        for(let phase of phaseList) {
            const trimmed = phase.trim();
            if(trimmed.length === 0) {
                continue;
            }

            cleanList.push(trimmed.replace("Phase ", ""));
        }

        return cleanList.join(", ");
    }
}