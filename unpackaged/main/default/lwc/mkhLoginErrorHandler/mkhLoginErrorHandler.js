/**
 * Component for parsing OAuth errors and redirecting to the MyKomen Health opt-in page in MyKomen where
 * applicable
 *
 * @author Grant Adamson, Traction on Demand
 * @date 2020-09-10
 */
import {LightningElement, track} from 'lwc';
import getMyKomenURL from "@salesforce/apex/MKH_SettingsService.getMyKomenURL";

import LOGIN_ERROR_HEADER_TEXT from '@salesforce/label/c.Login_Error_Header_Text';
import LOGIN_ERROR_HEADER_DETAIL from '@salesforce/label/c.Login_Error_Header_Detail';
import ERROR_CODE_LABEL from '@salesforce/label/c.Error_Code';
import ERROR_DESCRIPTION_LABEL from '@salesforce/label/c.Error_Description';

import MYKOMEN_OPT_IN_PAGE from '@salesforce/label/c.MyKomen_Opt_In_Page';

const NOT_OPTED_IN_ERROR_TYPE = "Remote_Error";
const NOT_OPTED_IN_ERROR_DESCRIPTION = "OAUTH_APP_ACCESS_DENIED";

export default class MkhLoginErrorHandler extends LightningElement {
    loginErrorHeaderText = LOGIN_ERROR_HEADER_TEXT;
    loginErrorHeaderDetail = LOGIN_ERROR_HEADER_DETAIL;
    errorCodeLabel = ERROR_CODE_LABEL;
    errorDescriptionLabel = ERROR_DESCRIPTION_LABEL;

    errorCode;
    errorDescription;

    @track showErrorDetail = false;

    async connectedCallback() {
        this.extractErrorParams();

        if(this.isOauthAppAccessDenied()) {
            await this.redirectToMyKomenHealthOptIn();
        } else {
            this.showErrorDetail = true;
        }
    }

    extractErrorParams() {
        const params = new URL(window.location.href).searchParams;

        this.errorCode = params.get("ErrorCode");
        this.errorDescription = params.get("ErrorDescription");
    }

    isOauthAppAccessDenied() {
        return this.errorCode === NOT_OPTED_IN_ERROR_TYPE && this.errorDescription === NOT_OPTED_IN_ERROR_DESCRIPTION;
    }

    async redirectToMyKomenHealthOptIn() {
        const myKomenURL = await getMyKomenURL();
        try {
            window.location.href = myKomenURL + MYKOMEN_OPT_IN_PAGE;
        } catch(e) {
            this.showErrorDetail = true;
            this.errorDescription = e.body.message;
            console.error(e.body.message);
        }
    }
}