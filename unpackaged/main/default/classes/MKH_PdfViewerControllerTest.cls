@IsTest
private class MKH_PdfViewerControllerTest {

    @IsTest
    static void getRelatedFilesByRecordId_existingFiles() {
        Account acc = MKH_TestDataFactory.createPersonAccount(
                'Test',
                'Tester',
                'test@test.com',
                true
        );

        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body');
        ContentVersion contentVersionToInsert = new ContentVersion(
                Title = 'Content Version',
                PathOnClient = '/ContentVersion.pdf',
                VersionData = bodyBlob,
                origin = 'H'
        );
        insert contentVersionToInsert;

        ContentVersion reQueriedContentVersion = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionToInsert.Id LIMIT 1];
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId = acc.Id;
        contentLink.ContentDocumentId = reQueriedContentVersion.ContentDocumentId;
        contentLink.ShareType = 'V';
        insert contentLink;

        Map<Id, String> contentVersionToTitle = MKH_PdfViewerController.getRelatedFilesByRecordId(acc.Id);

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.assertEquals(documents.size(), 1);
        System.assertEquals(documents[0].Id, reQueriedContentVersion.ContentDocumentId);
        System.assertEquals(documents[0].LatestPublishedVersionId, reQueriedContentVersion.Id);
        System.assertEquals(documents[0].Title, reQueriedContentVersion.Title);
        System.assertEquals(contentlink.ContentDocumentId, reQueriedContentVersion.ContentDocumentId);

        System.assertNotEquals(null, contentVersionToTitle.get(reQueriedContentVersion.ContentDocumentId));
        System.assertEquals(reQueriedContentVersion.Title, contentVersionToTitle.get(reQueriedContentVersion.ContentDocumentId));
    }

    @IsTest
    static void getRelatedFilesByRecordId_noFiles() {
        Account acc = MKH_TestDataFactory.createPersonAccount(
                'Test',
                'Tester',
                'test@test.com',
                true
        );

        Map<Id, String> contentVersionToTitle = MKH_PdfViewerController.getRelatedFilesByRecordId(acc.Id);

        System.assert(contentVersionToTitle.isEmpty());
    }
}