/**
 * Redirector component that sends user to the MyKomen instance that corresponds to the current MyKomen Health instance
 *
 * @author Grant Adamson, Traction on Demand
 * @date 2020-11-22
 */
import {LightningElement, api} from 'lwc';
import getRedirectorData from '@salesforce/apex/MKH_MyKomenRedirectorController.getRedirectorData';
import MYKOMEN_REDIRECTOR_TEXT from '@salesforce/label/c.MyKomen_Redirector_Text';

export default class MkhMyKomenRedirector extends LightningElement {
    headerText = MYKOMEN_REDIRECTOR_TEXT;

    @api page;

    async connectedCallback() {
        if(this.isInBuilder()) {
            return;
        }

        try {
            const data = await getRedirectorData();
            const baseURL = data.myKomenURL;

            let pageURL = '';
            if(this.page === "profile") {
                pageURL = data.profilePage;
            } else if(this.page === "account") {
                pageURL = data.accountPage;
            }

            window.location.replace(baseURL + pageURL);
        } catch (e) {
            console.error(e);
        }
    }

    isInBuilder() {
        const hostname = window.location.hostname.toLowerCase();
        return hostname.indexOf("sitepreview") >= 0 || hostname.indexOf("livepreview") >= 0;
    }
}