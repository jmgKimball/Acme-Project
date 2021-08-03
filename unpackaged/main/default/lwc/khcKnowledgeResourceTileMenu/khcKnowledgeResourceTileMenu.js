/**
 * Created by mlandels on 2021-03-23.
 */
// Salesforce
import {LightningElement, api} from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

// Labels
import REPORT_A_RESOURCE_ISSUE_LABEL from '@salesforce/label/c.Report_a_Resource_Issue';
import REPORT_AN_ISSUE_LABEL from "@salesforce/label/c.Report_an_Issue";
import REMOVE_REFERRAL_LABEL from "@salesforce/label/c.Remove_Referral";
import DISMISS_RESOURCE_RECOMMENDATION_LABEL from '@salesforce/label/c.Dismiss_Resource_Recommendation'

export default class KhcKnowledgeResourceTileMenu extends LightningElement {
    // Labels
    reportResourceLabel = REPORT_A_RESOURCE_ISSUE_LABEL;
    reportAnIssueLabel = REPORT_AN_ISSUE_LABEL;
    removeReferralLabel = REMOVE_REFERRAL_LABEL;
    dismissResourceRecommendationLabel = DISMISS_RESOURCE_RECOMMENDATION_LABEL;

    // Data
    @api
    knowledge;
    knowledgeArticleIdToDismiss;

    openReferralDismissalModal(event) {
        this.knowledgeArticleIdToDismiss = this.knowledge.Id;
        let dismissReferralModal = this.template.querySelector('[data-modal-name="khc-dismiss-referral-modal"]');
        dismissReferralModal.show();
    }

    handleReferralDismissed (event) {
        let dismissReferralModal = this.template.querySelector('[data-modal-name="khc-dismiss-referral-modal"]');
        dismissReferralModal.hide();
        let tempKnowledge = {...this.knowledge};
        tempKnowledge.isReferred = false;
        this.knowledge = tempKnowledge;
    }

    openReportResourceModal() {
        let reportResourceModal = this.template.querySelector('[data-modal-name="report-resource-modal"]');
        reportResourceModal.show();
    }

    handleReportIssueSuccess () {
        let reportResourceModal = this.template.querySelector('[data-modal-name="report-resource-modal"]');
        reportResourceModal.hide();
    }
}