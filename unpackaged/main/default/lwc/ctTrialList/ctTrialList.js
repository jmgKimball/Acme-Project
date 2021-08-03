/**
 * A control for displaying a list of clinical trial records
 *
 * @author Grant Adamson, Traction on Demand
 * @date 2020-05-15
 */
import {LightningElement, track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import loadTrials from '@salesforce/apex/CTClinicalTrialsService.loadTrials';
import {CtPaginationController} from 'c/ctPaginationController';

const RECORD_LIMIT = 100;
const PAGE_SIZE = 10;

export default class CtTrialList extends NavigationMixin(LightningElement) {
    @track loadingComplete = false;
    @track records = [];
    _paginationController = new CtPaginationController(PAGE_SIZE);

    async connectedCallback() {
        let location;
        try {
            location = await this.getPosition();
        } catch (error) {
            console.log("Unable to obtain user's location: %o", error);
        }

        try {
            const params = {recordLimit: RECORD_LIMIT};
            if(location) {
                params.latitude = location.coords.latitude;
                params.longitude = location.coords.longitude;
            }
            const trials = await loadTrials(params);
            this._paginationController.setRecords(trials);
            this.records = this._paginationController.getPage();
            this.loadingComplete = true;
        } catch(error) {
            console.log("Error: %o", error);
        }
    }

    async getPosition(options) {
        return new Promise(function (resolve, reject) {
            navigator.geolocation.getCurrentPosition(resolve, reject, options);
        });
    }

    get showPagination() {
        return this._paginationController.pageCount > 1;
    }

    get pageCount() {
        return this._paginationController.pageCount;
    }

    get currentPage() {
        return this._paginationController.currentPage;
    }

    get totalRecords() {
        return this._paginationController.recordCount;
    }

    handleBack() {
        console.log("Back pressed");
    }

    handleChangeFilter() {
        console.log("Change Filter pressed");
    }

    handleSelect(event) {
        const recordId = event.detail;

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }

    handlePrev() {
        this.records = this._paginationController.getPrev();
        this._scrollToTop();
    }

    handleNext() {
        this.records = this._paginationController.getNext();
        this._scrollToTop();
    }

    _scrollToTop() {
        window.scrollTo(0,0);
    }
}