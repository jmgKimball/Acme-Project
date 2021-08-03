/**
 * Displays the feedback form in a modal when the feedback link is clicked
 *
 * @author Grant Adamson, Traction on Demand
 * @date 2020-11-16
 */
import {LightningElement, track} from 'lwc';

const FEEDBACK_LABEL = "Feedback";
export default class MkhSiteFeedback extends LightningElement {
    feedbackLabel = FEEDBACK_LABEL;

    @track showForm = false

    handleShowFeedbackForm() {
        this.showForm = true;
    }

    handleClosePressed() {
	    this.showForm = false;
    }

}