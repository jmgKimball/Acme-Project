/**
 * @description JS Controller for mkGlobalCssComponent
 * @author      Scott Taylor, Traction on Demand
 * @date        2020-11-12
 */
import {LightningElement} from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import MyKomenGlobalStylesheet from '@salesforce/resourceUrl/MyKomenGlobalStylesheet';
import {ShowToastEvent} from "lightning/platformShowToastEvent";

export default class MkGlobalCssComponent extends LightningElement {
    connectedCallback() {
        loadStyle( this, MyKomenGlobalStylesheet )
            .catch(error => {
            const evt = new ShowToastEvent({
                title: "Error",
                message: error,
                variant: "error"
            });
            this.dispatchEvent(evt);
        });
    }
}