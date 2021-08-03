/**
 * Site Feedback form component for MyKomen Health
 *
 * @author Grant Adamson, Traction on Demand
 * @date 2020-11-12
 */
import {LightningElement, track} from "lwc";
import insertFeedback from "@salesforce/apex/MKH_SiteFeedbackController.insertFeedback";
import Id from "@salesforce/user/Id";
import {ShowToastEvent} from "lightning/platformShowToastEvent";

import FEEDBACK_HEADER_TEXT from "@salesforce/label/c.Feedback_Header_Text";
import LIKE_LABEL from "@salesforce/label/c.Feedback_Like";
import DISLIKE_LABEL from "@salesforce/label/c.Feedback_Dislike";
import COMMENTS_LABEL from "@salesforce/label/c.Comments";
import SUBMIT_FEEDBACK_LABEL from "@salesforce/label/c.Submit_Feedback";
import UNABLE_TO_SAVE_FEEDBACK_ERROR_MSG from "@salesforce/label/c.Unable_To_Save_Feedback_Error_Msg";
import ERROR_TITLE from "@salesforce/label/c.Error";
import FEEDBACK_THANK_YOU_HEADER_TEXT from "@salesforce/label/c.Feedback_Thank_You_Header_Text";
import CLOSE_LABEL from "@salesforce/label/c.Close";
import FEEDBACK_MISSING_ERROR_TEXT from "@salesforce/label/c.Feedback_Missing_Error_Text";

export default class MkhSiteFeedbackForm extends LightningElement {
    feedbackHeaderText = FEEDBACK_HEADER_TEXT;
    likeLabel = LIKE_LABEL;
    dislikeLabel = DISLIKE_LABEL;
    feedbackMissingErrorText = FEEDBACK_MISSING_ERROR_TEXT;
    commentsLabel = COMMENTS_LABEL;
    submitFeedbackLabel = SUBMIT_FEEDBACK_LABEL;
    feedbackThankYouHeaderText = FEEDBACK_THANK_YOU_HEADER_TEXT;
    closeLabel = CLOSE_LABEL;

    @track isCompleted = false;
    @track comments;
    @track isThumbsUpSelected = false;
    @track isThumbsDownSelected = false;
    @track showError = false;

    handleSelectionChange(event) {
        const selectionName = event.target.name;

        if (selectionName === "like") {
            this.isThumbsUpSelected = true;
            this.isThumbsDownSelected = false;
        } else if (selectionName === "dislike") {
            this.isThumbsUpSelected = false;
            this.isThumbsDownSelected = true;
        }
    }

	handleResponseChange(event) {
		const selectionName = event.currentTarget.dataset.name;

		if (selectionName === "like") {
			this.isThumbsUpSelected = true;
			this.isThumbsDownSelected = false;
		} else if (selectionName === "dislike") {
			this.isThumbsUpSelected = false;
			this.isThumbsDownSelected = true;
		}
	}

    handleCommentsChange(event) {
	    this.comments = event.currentTarget.value;
    }

    async handleSubmit() {
        if(this.isThumbsUpSelected || this.isThumbsDownSelected) {
            this.showError = false;
            await this.createAndInsertFeedbackRecord();
        } else {
            this.showError = true;
        }
    }

    async createAndInsertFeedbackRecord() {
        const feedback = {
            user: Id,
            positive: this.isThumbsUpSelected,
            comments: this.comments,
            page: window.location.pathname
        };

        try {
            await insertFeedback({feedback});
            this.isCompleted = true;
        } catch (e) {
            console.error(e);
            this.showErrorToast(e);
        }
    }

    showErrorToast(e) {
        let errorMsg = UNABLE_TO_SAVE_FEEDBACK_ERROR_MSG;
        if (e.body && e.body.message) {
            errorMsg = e.body.message;
        }

        this.dispatchEvent(
            new ShowToastEvent({
                title: ERROR_TITLE,
                message: errorMsg,
                variant: "error",
            }),
        );
    }

    handleClose() {
        // Signal the outer component that it should close the modal
        this.dispatchEvent(new CustomEvent('close'));
    }
}