/**
 * Dashboard component for unauthenticated Health Cloud users to opt in
 *
 * @author Grant Adamson, Traction on Demand
 * @date 2020-11-16
 */
import {LightningElement, track} from "lwc";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import getMyKomenURL from "@salesforce/apex/MKH_SettingsService.getMyKomenURL";
import { getCurrentUrlPath } from "c/khcLwcUtils";

import OPT_IN_HEADER_TEXT from "@salesforce/label/c.Opt_In_Header_Text";
import OPT_IN_DETAIL_TEXT from "@salesforce/label/c.Opt_In_Detail_Text";
import OR_LABEL from "@salesforce/label/c.or";
import OPT_IN_DETAIL_TEXT2 from "@salesforce/label/c.Opt_In_Detail_Text_2";
import OPT_IN_LABEL from "@salesforce/label/c.Opt_In";
import REGISTER_LABEL from "@salesforce/label/c.Register";
import LOGIN_LABEL from "@salesforce/label/c.Login";
import ERROR_LABEL from "@salesforce/label/c.Error";
import UNABLE_TO_LOAD_MYKOMEN_URL_ERROR_TEXT from "@salesforce/label/c.Unable_To_Load_MyKomen_URL_Error_Text";

const LOGIN_URL = "/login?startURL=/s/";
const MYKOMEN_OPT_IN_PAGE = "HealthOptIn";
const MYKOMEN_REGISTER_PAGE = "login/SelfRegister";
const AUTH_PARAM_NAME = "c__authenticated";

export default class MkhOptIn extends LightningElement {
    optInHeaderText = OPT_IN_HEADER_TEXT;
    optInDetailText = OPT_IN_DETAIL_TEXT;
    registerLabel = REGISTER_LABEL;
    orLabel = OR_LABEL;
    loginLabel = LOGIN_LABEL;
    optInDetailText2 = OPT_IN_DETAIL_TEXT2;
    optInLabel = OPT_IN_LABEL;

    @track optInURL;
    @track registerURL;
    @track showOptIn = true;
    @track showRegisterAndLogin = true;

    async connectedCallback() {
        try {
            const myKomenURL = await getMyKomenURL();

            this.optInURL = myKomenURL + MYKOMEN_OPT_IN_PAGE;

            let registerUrl = myKomenURL + MYKOMEN_REGISTER_PAGE;
            // URL Params so NPSP knows we've come from HC, and what page we're on
            registerUrl += "?c__mkhRef=1";
            let currentPath = getCurrentUrlPath();
            if ( currentPath ) {
                registerUrl += "&c__refPath=" + currentPath;
            }
            this.registerURL = registerUrl;

            // If the user is coming directly from MyKomen, we can read a URL param to determine if they are logged in
            // but not yet opted in to MyKomen Health, or if they are not logged in at all, and show appropriate actions
            // If the parameter is not present, we'll show both the opt-in and register/login options
            const authStatus = this.extractAuthStatusFromURL();
            if(authStatus === "0") {
                this.showOptIn = false;
            } else if (authStatus === "1") {
                this.showRegisterAndLogin = false;
            }

        } catch(e) {
            console.error(e);
            this.showErrorMessage(e);
        }
    }

    extractAuthStatusFromURL() {
        return new URL(window.location.href).searchParams.get(AUTH_PARAM_NAME);
    }

    showErrorMessage(e) {
        let message = UNABLE_TO_LOAD_MYKOMEN_URL_ERROR_TEXT;
        if (e.body && e.body.message) {
            message = e.body.message;
        }

        this.dispatchEvent(new ShowToastEvent({
            title: ERROR_LABEL,
            message,
            variant: 'error',
        }));
    }

    handleOptInPressed() {
        window.location.href = this.optInURL;
    }

    handleRegisterPressed() {
        window.location.href = this.registerURL;
    }

    handleLoginPressed() {
        window.location.href = LOGIN_URL;
    }
}