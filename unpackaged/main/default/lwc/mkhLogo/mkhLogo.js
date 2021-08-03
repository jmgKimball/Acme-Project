/**
 * Generic MyKomen Health Community logo component, used by various custom Login screens
 *
 * @author Grant Adamson, Traction on Demand
 * @date 2020-09-21
 */
import {LightningElement} from 'lwc';
import MyKomenHealthAssets from '@salesforce/resourceUrl/MyKomenHealthAssets';

export default class MkLogo extends LightningElement {
    myKomenHealthLogo = MyKomenHealthAssets + "/images/MyKomenHealth_Logo@2x.png";
}