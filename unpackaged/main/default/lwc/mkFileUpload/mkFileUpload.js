/**
 * @description JS controller for mkFileUpload
 * @author      Scott Taylor, Traction on Demand
 * @date        2020-10-23
 */
import {LightningElement, api} from 'lwc';

import { helper } from "./mkFileUploadHelper";
import success_toast from "@salesforce/label/c.success_toast";
import error_toast from "@salesforce/label/c.error_toast";
import files_saved from "@salesforce/label/c.files_saved";
import select_files from "@salesforce/label/c.select_files";

export default class MkFileUpload extends LightningElement {
    LABELS = {
        success_toast,
        error_toast,
        files_saved,
        select_files
    };

    @api recordId;
    @api recordIdFromWrapper;

    fileData = [];

    get objectRecordId() {
        return (this.recordId || this.recordIdFromWrapper);
    }

    get acceptedFormats() {
        return ['.pdf', '.jpg', '.jpeg', '.png', '.gif', '.txt', '.doc', '.docx'];
    }

    connectedCallback() {
        helper.queryFileData(this);
    }

    /**
     * @description Handle the file upload result; if the event is sent, file uploaded successfully
     * @author      Scott Taylor, Traction on Demand
     * @date        2020-10-23
     *
     * @param event Event reference
     */
    handleUploadFinished(event) {
        helper.toast(this.LABELS.success_toast, this.LABELS.files_saved, 'success');
        helper.sendEventToParent(this, 'close');
        this.connectedCallback();
    }
}