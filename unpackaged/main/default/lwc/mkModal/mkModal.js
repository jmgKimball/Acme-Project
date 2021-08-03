/**
 * Generic modal component used by MyKomen
 *
 * @author Grant Adamson, Traction on Demand
 * @date 2020-09-16
 */
import {LightningElement, api, track} from 'lwc';

export default class MkModal extends LightningElement {
    @track visible;

    @api
    show() {
        this.visible = true;
    }

    @api
    hide() {
        this.visible = false;
    }

    onClose() {
        this.hide();
        // TODO: Fire close event for parents to hook into
    }
}