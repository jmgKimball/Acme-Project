/**
 * Common Component created for generic Komen Link informations, to be added on most of the screens.
 * The component renders based on the FormFactor of the screen
 *
 * Created by vupneja on 10/19/2020.
 */

import {LightningElement} from 'lwc';
import MyKomenHealthAssets from '@salesforce/resourceUrl/MyKomenHealthAssets';
import LINK_ADDRESS_LABEL from "@salesforce/label/c.Link_Address";
import LINK_CONTACT_US_LABEL from "@salesforce/label/c.Link_Contact_Us";
import LINK_COPYRIGHT_LABEL from "@salesforce/label/c.Link_Copyright";
import LINK_TERMS_LABEL from "@salesforce/label/c.Link_Terms_Of_Use";
import LINK_PRIVACY_POLICY_LABEL from "@salesforce/label/c.Link_Privacy_Policy";
import LINK_EIN_LABEL from "@salesforce/label/c.Link_EIN";
import LINK_KOMEN_LABEL from "@salesforce/label/c.Link_Komen";
import LINK_FACEBOOK_LABEL from "@salesforce/label/c.Link_Facebook";
import LINK_INSTAGRAM_LABEL from "@salesforce/label/c.Link_Instagram";
import LINK_TWITTER_LABEL from "@salesforce/label/c.Link_Twitter";
import FORM_FACTOR from '@salesforce/client/formFactor';
import basePath from '@salesforce/community/basePath';

export default class KhcLinks extends LightningElement {
    facebookLogoLarge = MyKomenHealthAssets + "/images/facebook@2x.png";
    twitterLogoLarge = MyKomenHealthAssets + "/images/twitter@2x.png";
    instagramLogoLarge = MyKomenHealthAssets + "/images/instagram@2x.png";

    facebookLogoSmall = MyKomenHealthAssets + "/images/facebook.png";
    twitterLogoSmall = MyKomenHealthAssets + "/images/twitter.png";
    instagramLogoSmall = MyKomenHealthAssets + "/images/instagram.png";

    addresslabel = LINK_ADDRESS_LABEL;
    contactUslabel = basePath+"/contactsupport";
    copyrightlabel = LINK_COPYRIGHT_LABEL;
    termslabel = LINK_TERMS_LABEL;
    privacylabel = LINK_PRIVACY_POLICY_LABEL;
    einlabel = LINK_EIN_LABEL;
    komenlabel = LINK_KOMEN_LABEL;
    facebooklabel = LINK_FACEBOOK_LABEL;
    instagramlabel = LINK_INSTAGRAM_LABEL;
    twitterlabel = LINK_TWITTER_LABEL;
    isSmallScreen = false;

    constructor() {
        super();
        //Capture the Form factor
        this.isSmallScreen = (FORM_FACTOR === 'Small');
    }

}