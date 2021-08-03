import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import BACK_LABEL from '@salesforce/label/c.Back';

export default class KhcBackNavigation extends NavigationMixin(LightningElement) {
    @api containerClass;
    backLabel = BACK_LABEL;

    get backHtmlClass(){
        return 'navigate-back-margin' + ( this.containerClass == null ? '' : ' ' + this.containerClass );
    }

    handleBackClick( event ){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/s/my-health-profile'
            },
        });
    }
}