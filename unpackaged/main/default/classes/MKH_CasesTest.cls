/**
 * Created by cwico@tractionondemand.com on 2021-01-18.
 */

@IsTest
private class MKH_CasesTest {

	@IsTest
	static void getCases() {
		insert new Case(Subject='Test');

		System.assertNotEquals(0, MKH_Cases.getCases().size(), 'Should have more case record.');
	}

}