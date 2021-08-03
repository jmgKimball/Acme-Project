/**
  * @description Selector for ContentDocumentLink
  * @author      Scott Taylor, Traction on Demand
  * @date        2020-10-27
  */
public inherited sharing class ContentDocumentLinkSelector {

    /**
     * @description Get a list of ContentDocumentLinks for a set of parent objects
     * @author      Scott Taylor, Traction on Demand
     * @date        2020-10-27
     *
     * @param LinkedEntityIds   Ids of parent objects to documents
     *
     * @return      List of ContentDocumentLink objects
     */
    public List<ContentDocumentLink> getContentDocumentLinksByLinkedEntityIdId(Set<String> LinkedEntityIds) {
        return [
            SELECT Id, ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId  IN :LinkedEntityIds
        ];
    }
}