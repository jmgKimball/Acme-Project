/**
 * KHC_MyInsurance screens
 *
 * @author Sabrina Perardt, Traction on Demand
 * @date 2020-09-16
 */

import {LightningElement, api, track, wire} from 'lwc';
import getPicklistValues from '@salesforce/apex/KHC_MyInsuranceController.getPicklistValues';
import getMyInsuranceProvider from '@salesforce/apex/KHC_MyInsuranceController.getMyInsuranceProvider';
import insertInsurance from '@salesforce/apex/KHC_MyInsuranceController.insertInsurance';
import deleteInsurance from '@salesforce/apex/KHC_DeleteUtility.deleteRecord';
import getImageURL from '@salesforce/apex/KHC_MyInsuranceController.getImages';
import getAccountData from '@salesforce/apex/KHC_MyInsuranceController.getAccountData';
import updateAccountData from '@salesforce/apex/KHC_MyInsuranceController.updateAccountData';

import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';

import MY_INSURANCE_LABEL from '@salesforce/label/c.My_Insurance';
import NO_INSURANCE_FOUND_LABEL from '@salesforce/label/c.No_Insurance_Found';
import EDIT_LABEL from '@salesforce/label/c.Edit';
import MEMBER_NUMBER_LABEL from '@salesforce/label/c.Member_Number';
import COVERAGE_FOR_LABEL from '@salesforce/label/c.Coverage_for';
import SUBSCRIBER_NAME_LABEL from '@salesforce/label/c.Subscriber_Number';
import DATE_OF_BIRTH_LABEL from '@salesforce/label/c.Date_of_Birth';
import ADD_NEW_INSURANCE_PROVIDER_LABEL from '@salesforce/label/c.Add_new_insurance_provider';
import ADD_NEW_INSURANCE_COVERAGE_LABEL from '@salesforce/label/c.Add_a_new_insurance_coverage';
import EDIT_INSURANCE_COVERAGE_LABEL from '@salesforce/label/c.Edit_insurance_coverage';
import INSURANCE_PROVIDER_LABEL from '@salesforce/label/c.Insurance_Provider';
import SUBSCRIBER_FIRST_NAME_LABEL from '@salesforce/label/c.Subscriber_First_Name';
import SUBSCRIBER_LAST_NAME_LABEL from '@salesforce/label/c.Subscriber_Last_Name';
import SUBSCRIBER_DATE_OF_BIRTH_LABEL from '@salesforce/label/c.Subscriber_Date_of_Birth';
import UPLOAD_INSURANCE_PHOTO_LABEL from '@salesforce/label/c.Upload_Insurance_Photo';
import ADD_A_COVERAGE_LABEL from '@salesforce/label/c.Add_a_coverage';
import UPDATE_COVERAGE_LABEL from '@salesforce/label/c.Update_coverage';
import REMOVE_COVERAGE_LABEL from '@salesforce/label/c.Remove_coverage';
import CANCEL_LABEL from '@salesforce/label/c.Cancel';
import ERROR_LABEL from '@salesforce/label/c.Error';
import ERROR_LOADING_INSURANCE_LABEL from '@salesforce/label/c.Error_Loading_Insurances';
import ERROR_LOADING_PICKLIST_LABEL from '@salesforce/label/c.Error_Loading_Pciklist_values';
import ERROR_SAVING_INSURANCE_LABEL from '@salesforce/label/c.Error_Saving_Insurance';
import UNEXPECTED_ERROR_LABEL from '@salesforce/label/c.Unexpected_Error';
import DOES_NOT_HAVE_INSURANCE from '@salesforce/label/c.DoesNotHaveInsurance';
import FORM_FACTOR from "@salesforce/client/formFactor";
import UPLOAD_INSURANCE_PHOTO_UNSAVED_LABEL from '@salesforce/label/c.Upload_Insurance_Photo_Unsaved';

import ERROR_DELETING_INSURANCE_IMAGE_LABEL from '@salesforce/label/c.Error_deleting_insurance_image';
import INSURANCE_IMAGE_CLOSE_LABEL from '@salesforce/label/c.Insurance_Image_Close';
import INSURANCE_IMAGE_PREVIEW_LABEL from '@salesforce/label/c.Insurance_Image_Preview';
import INSURANCE_IMAGE_DELETED_MSG_LABEL from '@salesforce/label/c.Insurance_Image_deleted_msg';

const IMAGE_PREFIX = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB120BY90&versionId=';

export default class KHCMyInsurance extends LightningElement {
    @api recordId;
    @api objectApiName;
    providerOptions = [];
    isInsuredOptions = [];
    @track selectedProvider;


    @track displayAddInsurance = false;
    @track displayViewInsurance = false;
    @track insuranceInfo;
    @track uploadedFiles;
    @track insuranceRecords;
    @track isAdd = true;
    @track isEdit = false;
    @track files;
    @track imageURL = [];
    @track imageURLwithId = [];

    @track isInsertValue;
    @track error;

    allowedExtensions = ['.pdf', '.jpg','.jpeg', '.png'];

    myInsuranceLabel = MY_INSURANCE_LABEL;
    editLabel = EDIT_LABEL;
    noInsuranceFoundLabel = NO_INSURANCE_FOUND_LABEL;
    memberNumberLabel = MEMBER_NUMBER_LABEL;
    coverageForLabel = COVERAGE_FOR_LABEL;
    subscriberNumberLabel = SUBSCRIBER_NAME_LABEL;
    dateOfBirthLabel = DATE_OF_BIRTH_LABEL;
    addNewInsuranceProviderLabel = ADD_NEW_INSURANCE_PROVIDER_LABEL;
    addNewInsuranceCoverageLabel = ADD_NEW_INSURANCE_COVERAGE_LABEL;
    editInsuranceCoverageLabel = EDIT_INSURANCE_COVERAGE_LABEL;
    insuranceProviderLabel = INSURANCE_PROVIDER_LABEL;
    subscriberFirstNameLabel = SUBSCRIBER_FIRST_NAME_LABEL;
    subscriberLastNameLabel = SUBSCRIBER_LAST_NAME_LABEL;
    subscriberDateOfBirthLabel = SUBSCRIBER_DATE_OF_BIRTH_LABEL;
    uploadInsurancePhotoLabel = UPLOAD_INSURANCE_PHOTO_LABEL;
    uploadInsurancePhotoUnsavedLabel = UPLOAD_INSURANCE_PHOTO_UNSAVED_LABEL;
    addNewCoverageLabel = ADD_A_COVERAGE_LABEL;
    updateCoverageLabel = UPDATE_COVERAGE_LABEL;
    removeCoverageLabel = REMOVE_COVERAGE_LABEL;
    cancelLabel = CANCEL_LABEL;
    doesNotHaveInsuranceLabel = DOES_NOT_HAVE_INSURANCE;
    insuranceImageCloseLabel = INSURANCE_IMAGE_CLOSE_LABEL;
    insuranceImagePreviewLabel = INSURANCE_IMAGE_PREVIEW_LABEL;

    isSmallScreen = false;

    constructor() {
        super();
        //Capture the Form factor
        this.isSmallScreen = (FORM_FACTOR === 'Small');
    }

    accountRecord;
    /**
     * @description Get the person account record from the backend. Must do this implicitly since getRecord doesn't support person accounts
     * @author      Scott Taylor, Traction on Demand
     * @date        2020-11-17
     */
    populateAccountRecord() {
        if (!this.recordId) {
            return;
        }

        getAccountData({
            accountId: this.recordId
        })
            .then(result => {
                this.accountRecord = result.personAccount;
                this.isInsertValue = result.personAccount.Is_Insured__pc;
            });
    }

    /**
     * @description Show a toast message
     * @author      Scott Taylor, Traction on Demand
     * @date        2020-11-17
     *
     * @param title     Title for the toast
     * @param message   Message for the toast
     * @param variant   Variant for the toast
     */
    popToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

    getInsuranceList() {
        getMyInsuranceProvider({
            currentLoggedAccount: this.recordId
        }).then(result => {
            this.insuranceRecords = result;
            this.insuranceRecords.forEach(element => {
                element.Subscriber_Date_of_Birth__c = this.formatDate(element.Subscriber_Date_of_Birth__c);
            });

            this.displayViewInsurance = true;
            this.displayAddInsurance = false;

            this.isAdd = true;
            this.isEdit = false;

        }).catch(error => {
            const evt = new ShowToastEvent({
                title: ERROR_LABEL,
                message: ERROR_LOADING_INSURANCE_LABEL,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);

        });
    }

    resetInsuranceValues() {
        this.insuranceInfo = {
            Subscriber_First_Name__c: '',
            Subscriber_Last_Name__c: '',
            Subscriber_Date_of_Birth__c: '', Subscriber_Number__c: '',
            Member_Number__c: '', Uninsured__c: false
        };
        this.selectedProvider = '';
        this.files = '';
        this.imageURL = [];
    }

    connectedCallback() {
        this.resetInsuranceValues();
        this.getInsuranceList();
        getPicklistValues({})
            .then(result => {
                this.myPicklists = result;
                result.Insurance_Provider__c.forEach(element => {
                    let myObj = {value: element, label: element};
                    this.providerOptions.push(myObj);
                });
                result.Is_Insured__pc.forEach(element => {
                    let myObj = {value: element, label: element};
                    this.isInsuredOptions.push(myObj);
                });
            }).catch(error => {
            const evt = new ShowToastEvent({
                title: ERROR_LABEL,
                message: ERROR_LOADING_PICKLIST_LABEL,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        });
        this.populateAccountRecord();
    }

    formatDate(birthdate) {
        //original date is saved in salesforce as 1972-09-13
        if (birthdate) {
            let arrDate = birthdate.split("-");
            if (arrDate) {
                birthdate = arrDate[1] + '/' + arrDate[2] + '/' + arrDate[0]; // MM/DD/YYYY
            }
        }
        return birthdate;
    }

    handleProviderChange(event) {
        this.insuranceInfo.Insurance_Provider__c = event.detail.value;
    }

    handleSubcriberFirstName(event) {
        this.insuranceInfo.Subscriber_First_Name__c = event.target.value;
    }

    handleSubcriberLastName(event) {
        this.insuranceInfo.Subscriber_Last_Name__c = event.target.value;
    }

    handleSubcriberNumber(event) {
        this.insuranceInfo.Subscriber_Number__c = event.target.value;
    }

    handleMemberNumber(event) {
        this.insuranceInfo.Member_Number__c = event.target.value;
    }

    handleBirthdayNumber(event) {
        this.insuranceInfo.Subscriber_Date_of_Birth__c = event.target.value;
    }

    changeToAddInsurance() {
        this.displayViewInsurance = false;
        this.displayAddInsurance = true;
    }

    handleUpdateInsurance() {
        insertInsurance({
            accId: this.recordId,
            myInsurance: this.insuranceInfo
        }).then(result => {
            this.navigateToViewInsurance();
        }).catch(error => {
            console.error(error);
            let message = ERROR_SAVING_INSURANCE_LABEL;
            if (error.body && error.body.pageErrors && error.body.pageErrors.length > 0) {
                message = error.body.pageErrors[0].message;
            }
            const evt = new ShowToastEvent({
                title: ERROR_LABEL,
                message,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        });
    }

    loadEditInfo(event) {
        this.insuranceInfo.Id = event.target.dataset.recordId;
        let insuranceList = Object.values(this.insuranceRecords);
        let selectedInsurance = insuranceList.find(element => element.Id === this.insuranceInfo.Id);

        this.selectedProvider = selectedInsurance.Insurance_Provider__c;
        this.insuranceInfo.Subscriber_First_Name__c = selectedInsurance.Subscriber_First_Name__c;
        this.insuranceInfo.Subscriber_Last_Name__c = selectedInsurance.Subscriber_Last_Name__c;
        this.insuranceInfo.Subscriber_Date_of_Birth__c = selectedInsurance.Subscriber_Date_of_Birth__c;
        this.insuranceInfo.Subscriber_Number__c = selectedInsurance.Subscriber_Number__c;
        this.insuranceInfo.Member_Number__c = selectedInsurance.Member_Number__c;
        this.insuranceInfo.Uninsured__c = selectedInsurance.Uninsured__c;

        getImageURL(
            {insuranceId: this.insuranceInfo.Id}
        ).then(result => {
                if (result) {

                    [...result].map(record => {
                        record.Id = IMAGE_PREFIX + (record.Id);
                    })

                }
                this.imageURL = result;
            }
        )

        this.displayAddInsurance = true;
        this.displayViewInsurance = false;
        this.isAdd = false;
        this.isEdit = true;
    }

    navigateToViewInsurance() {
        this.resetInsuranceValues();
        this.getInsuranceList();
    }

    deleteRecord() {
        deleteInsurance({rec: this.insuranceInfo })
            .then(result => {
                this.navigateToViewInsurance();
            }).catch(error => {
            console.error(error);
            const evt = new ShowToastEvent({
                title: ERROR_LABEL,
                message: UNEXPECTED_ERROR_LABEL,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        });
    }

    refreshEdit() {
        getImageURL(
            {insuranceId: this.insuranceInfo.Id}
        ).then(result => {
                if (result) {

                    [...result].map(record => {
                        record.Id = IMAGE_PREFIX + (record.Id);
                    })
                }
                this.imageURL = result;
            }
        )

        this.displayAddInsurance = true;
        this.displayViewInsurance = false;
        this.isAdd = false;
        this.isEdit = true;
    }

    @track isOpenModal = false;
    @track previewPhotoUrl=null;

    handleOpenModal(event) {
        this.previewPhotoUrl = (event.currentTarget.dataset.id).replace("rendition=THUMB120BY90", "rendition=THUMB720BY480");
        this.isOpenModal = true;
    }

    handleCloseModal() {
        this.isOpenModal = false;
    }

    @track error;
    deleteFile(event) {
        deleteRecord(event.currentTarget.dataset.id)
            .then(() => {
                this.refreshEdit();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: INSURANCE_IMAGE_DELETED_MSG_LABEL,
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                    console.error(error);
                    this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: ERROR_DELETING_INSURANCE_IMAGE_LABEL,
                        variant: 'error'
                    })
                );
            });
    }

    handleChange(event) {
        this.value = event.detail.value;
        this.accountRecord.Is_Insured__pc = event.detail.value;
        updateAccountData({
            personAccount: this.accountRecord
        })
            .then(result => {
                if (!result.isSuccess) {
                    this.popToast(ERROR_SAVING_INSURANCE_LABEL, result.message, 'error');
                }
            }).catch(error => {
            console.log(error);
        });
    }

}