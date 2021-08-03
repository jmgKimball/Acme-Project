/**
  * @description Selector for ContentVersion
  * @author      Scott Taylor, Traction on Demand
  * @date        2020-10-27
  */
public inherited sharing class ContentVersionSelector {

    /**
     * @description Get a list of ContentVersions for a set of parent content documents
     * @author      Scott Taylor, Traction on Demand
     * @date        2020-10-27
     *
     * @param contentDocumentIds    Ids of parent contentDocument objects
     *
     * @return      List of ContentVersion objects
     */

    public List<ContentVersion> getContentVersionsByContentDocumentId(Set<Id> contentDocumentIds) {
        return [
            SELECT Id, ContentDocumentId, Title, ContentDocument.FileType
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentDocumentIds
            ORDER BY CreatedDate DESC
        ];
    }
}