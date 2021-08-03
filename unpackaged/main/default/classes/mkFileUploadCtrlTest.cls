/**
  * @description Test class for mkFileUploadCtrl
 * @author Scott Taylor, Traction on Demand
 * @date 2020-10-30
 */
@IsTest
public class mkFileUploadCtrlTest {
    private static final String FILE_NAME = 'my_test_file';
    private static final String FILE_EXT = 'jpg';

    private static ContentDocumentLinkSelector contentDocumentLinkSelector = new ContentDocumentLinkSelector();
    private static ContentVersionSelector contentVersionSelector = new ContentVersionSelector();

    @TestSetup
    static void testSetup() {
        Account acc = MKH_TestDataFactory.createPersonAccount(
                'Test',
                'Tester',
                'test@test.com',
                true
        );

        ContentVersion contentVersion = new ContentVersion(
                Title = FILE_NAME,
                PathOnClient = FILE_NAME + '.' + FILE_EXT,
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
        );
        insert contentVersion;

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        //create ContentDocumentLink  record
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = acc.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        insert cdl;
    }

    @IsTest
    static void getImageFileDataTest() {
        // get test contact
        List<Account> acc = [SELECT Id FROM Account];
        System.assertEquals(1, acc.size(), 'Unexpected number of accounts');
        Id testAccountId = acc[0].Id;

        // get contentDocumentIds
        List<ContentDocumentLink> contentDocumentLinks =
                contentDocumentLinkSelector.getContentDocumentLinksByLinkedEntityIdId(new Set<String>{testAccountId});
        System.assertEquals(1, contentDocumentLinks.size(), 'Unexpected number of contentDocumentLinks');
        Id contentDocumentId = contentDocumentLinks[0].ContentDocumentId;

        // get contentVersions
        List<ContentVersion> contentVersions =
                contentVersionSelector.getContentVersionsByContentDocumentId(new Set<Id>{contentDocumentId});
        System.assertEquals(1, contentVersions.size(), 'Unexpected number of contentVersions');
        Id contentVersionId = contentVersions[0].Id;

        mkFileUploadCtrl.Response response;

        Test.startTest();
        response = mkFileUploadCtrl.getFileData(testAccountId);
        Test.stopTest();

        System.assertNotEquals(null, response, 'Response was not populated');
        List<mkFileUploadCtrl.FileData> fileDataList = response.fileDataList;

        System.assertNotEquals(null, fileDataList, 'Response.fileDataList was not populated');
        System.assertEquals(1, fileDataList.size(), 'Size of Response.fileDataList was unexpected');

        mkFileUploadCtrl.FileData fileData = fileDataList[0];
        System.assertEquals(FILE_NAME, fileData.title, 'File title was unexpected');
        System.assertEquals(mkFileUploadCtrl.IMAGE_URL_PREFIX + contentVersionId, fileData.imageUrl, 'File image URL was unexpected');
        System.assertEquals(FILE_EXT.toUpperCase(), fileData.fileType, 'File extension was unexpected');
        System.assertEquals(contentDocumentId, fileData.contentDocumentId, 'File contentDocumentId was unexpected');
    }
}