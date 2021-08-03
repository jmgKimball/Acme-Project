/**
 *
 *
 * @author Grant Adamson, Traction on Demand
 * @date 2020-05-26
 */
import {LightningElement, api} from 'lwc';

export default class CtPaginationControls extends LightningElement {
    @api pageCount;
    @api currentPage;

    handlePrev() {
        this.dispatchEvent(new CustomEvent("prev"));
    }

    handleNext() {
        this.dispatchEvent(new CustomEvent("next"));
    }
}