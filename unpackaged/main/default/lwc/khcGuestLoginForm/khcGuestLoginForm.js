/**
 * Created by mlandels on 2021-06-03.
 */

import {LightningElement} from 'lwc';
//Util
import { getCurrentUrlPath } from "c/khcLwcUtils";
// Labels
import LOG_IN_OR_REGISTER_LABEL from "@salesforce/label/c.Log_In_or_Register";
import GUEST_REGISTER_MESSAGE_LABEL from "@salesforce/label/c.Resource_Repository_Register_Message";

export default class KhcGuestLoginForm extends LightningElement {
    logInOrRegisterLabel = LOG_IN_OR_REGISTER_LABEL;
    guestRegisterMessageLabel = GUEST_REGISTER_MESSAGE_LABEL;
    navigateToLoginUrl () {
        let loginLink = '/login?startURL=';

        // If we're on a subpage, set the path so we can return to the same page
        let currentPath = getCurrentUrlPath();
        if ( currentPath ) {
            loginLink += currentPath;
        } else {
            loginLink += '/s/';
        }

        window.location.href = loginLink;
    }
}