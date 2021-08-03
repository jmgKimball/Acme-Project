/**
 * @description JS helper for mkFileUpload
 * @author      Scott Taylor, Traction on Demand
 * @date        2020-10-23
 */
import getFileData
    from "@salesforce/apex/mkFileUploadCtrl.getFileData";
import {ShowToastEvent} from "lightning/platformShowToastEvent";

let helper = {
    /**
     * @description Get the file list from the backend
     * @author      Scott Taylor, Traction on Demand
     * @date        2020-10-23
     *
     * @param cmp   Component reference
     */
    queryFileData: (cmp) => {
        getFileData({parentObjectId: cmp.objectRecordId})
            .then(result => {
                cmp.fileData = result.fileDataList;
            })
            .catch(error => {
                helper.toast(cmp.LABELS.error_toast, error.body.message, 'error');
            });
    },

    /**
     * @description Send data to the parent component
     * @author      Scott Taylor, Traction on Demand
     * @date        2020-10-23
     *
     * @param cmp           Component reference
     * @param eventName     Name of the event
     * @param dataPayload   Data to send
     */
    sendEventToParent: (cmp, eventName, dataPayload) => {
        const clickEvent = new CustomEvent(eventName, {
            bubbles: true,
            cancelable: false,
            detail: {dataPayload}
        });
        cmp.dispatchEvent(clickEvent);
    },

    /**
     * @description Send data to the parent component
     * @author      Scott Taylor, Traction on Demand
     * @date        2020-10-23
     *
     * @param cmp           Component reference
     * @param toastMessage  Message to toast
     * @param toastVariant  Variant for the toast theeme
     */
    toast(toastTitle, toastMessage, toastVariant) {
        const event = new ShowToastEvent({
            title: toastTitle,
            message: toastMessage,
            variant: toastVariant
        });
        dispatchEvent(event);
    }
};

export { helper };