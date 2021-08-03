/**
 * Created by chris on 2020-11-20.
 */

@IsTest
private class MK_FooterContactControllerTest {
	@IsTest
	static void getData() {
		MK_FooterContactController.Data data = MK_FooterContactController.getData();
		System.assertNotEquals(null, data.orgId);
		System.assertNotEquals(null, data.caseRecordTypeId);
		System.assertNotEquals(null, data.userEmail);
		System.assertNotEquals(null, data.userFullName);
	}
}