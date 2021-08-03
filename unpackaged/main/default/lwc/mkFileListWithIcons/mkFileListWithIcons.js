/**
 * @description JS controller for mkFileListWithIcons
 * @author      Scott Taylor, Traction on Demand
 * @date        2020-10-23
 */
import {LightningElement, api, track} from 'lwc';
import { helper } from "./mkFileListWithIconsHelper";
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import No_Files_Uploaded from "@salesforce/label/c.No_Files_Uploaded";
import File_Deleted from "@salesforce/label/c.File_Deleted";
import Error_Deleting_File from "@salesforce/label/c.Error_Deleting_File";
import Success from "@salesforce/label/c.Success";

export default class MkFileListWithIcons extends LightningElement {
    LABELS = {
        No_Files_Uploaded,
        File_Deleted,
        Error_Deleting_File,
        Success
    };

    @track
    fileListForMarkup = [];
    get showFileList() {
        return (!!this.fileListForMarkup.length);
    }

    @api
    get fileData() {
        return this.fileListForMarkup;
    }
    set fileData(value) {
        this.fileListForMarkup = helper.formatFileDataForMarkup(value);
    }

    handleDeleteFile (event) {
        let thisId = event.target.dataset.id;
        deleteRecord(thisId)
            .then(() => {
                this.fileListForMarkup.forEach(function(f, idx){
                    if ( thisId == f.contentDocumentId ) {
                        this.fileListForMarkup.splice(idx, 1);
                    }
                }.bind(this));

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.LABELS.Success,
                        message: this.LABELS.File_Deleted,
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.LABELS.Error_Deleting_File,
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

}