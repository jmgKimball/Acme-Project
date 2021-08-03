/**
  * @description Controller for mkFileUpload LWC
  * @author      Scott Taylor, Traction on Demand
  * @date        2020-10-27
  */
public with sharing class mkFileUploadCtrl {
    private static ContentDocumentLinkSelector contentDocumentLinkSelector = new ContentDocumentLinkSelector();
    private static ContentVersionSelector contentVersionSelector = new ContentVersionSelector();

    private final static Set<String> IMAGE_FILE_TYPES = new Set<String>{'JPG', 'JPEG', 'PNG', 'GIF'};
    public final static String IMAGE_URL_PREFIX = '/sfc/servlet.shepherd/version/download/';

    /**
     * @description Get the list of files for a parent object
     * @author      Scott Taylor, Traction on Demand
     * @date        2020-10-30
     *
     * @param parentObjectId    Id of the file's parent object
     *
     * @return      Response object containing the file list
     */
    @AuraEnabled
    public static Response getFileData(String parentObjectId) {
        List<FileData> fileDataList = new List<FileData>();

        // get contentDocumentIds
        List<ContentDocumentLink> contentDocumentLinks =
            contentDocumentLinkSelector.getContentDocumentLinksByLinkedEntityIdId(new Set<String>{ parentObjectId });

        if (contentDocumentLinks.isEmpty()) {
            return new Response(fileDataList);
        }

        // collect ContentDocumentIds
        Set<Id> contentDocumentIds = new Set<Id>();
        for (ContentDocumentLink contentDocumentLink : contentDocumentLinks) {
            contentDocumentIds.add(contentDocumentLink.ContentDocumentId);
        }

        // get contentVersions
        List<ContentVersion> contentVersions = contentVersionSelector.getContentVersionsByContentDocumentId(contentDocumentIds);

        if (contentVersions.isEmpty()) {
            return new Response(fileDataList);
        }

        // build file lines
        for (ContentVersion contentVersion : contentVersions) {
            FileData fileToAdd = new FileData(
                contentVersion.ContentDocumentId,
                contentVersion.Title,
                contentVersion.ContentDocument.FileType
            );

            // extension-specific values
            // in case of image, add image Url
            if (IMAGE_FILE_TYPES.contains(contentVersion.ContentDocument.FileType)) {
                fileToAdd.imageUrl = IMAGE_URL_PREFIX + contentVersion.Id;
            }

            fileDataList.add(fileToAdd);
        }

        return new Response(fileDataList);
    }

    /**
     * @description Represents a single file
     * @author      Scott Taylor, Traction on Demand
     * @date        2020-10-30
     */
    public class FileData {
        @AuraEnabled public String contentDocumentId { get; private set; }
        @AuraEnabled public String title { get; private set; }
        @AuraEnabled public String fileType { get; private set; }

        @AuraEnabled public String imageUrl;

        public FileData(String contentDocumentId, String title, String fileType) {
            this.contentDocumentId = contentDocumentId;
            this.title = title;
            this.fileType = fileType;
        }
    }

    /**
     * @description Response object
     * @author      Scott Taylor, Traction on Demand
     * @date        2020-10-30
     */
    public class Response {
        @AuraEnabled public List<FileData> fileDataList { get; private set; }

        public Response(List<FileData> fileDataList) {
            this.fileDataList = fileDataList;
        }
    }
}