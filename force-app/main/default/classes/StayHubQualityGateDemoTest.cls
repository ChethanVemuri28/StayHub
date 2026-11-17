/**
 * @description Unit tests for StayHubQualityGateDemo.
 */
@IsTest
private class StayHubQualityGateDemoTest {
  /**
   * @description Verifies that matching Accounts are returned.
   */
  @IsTest
  static void testGetAccounts() {
    List<Account> accounts = new List<Account>{
      new Account(Name = 'StayHub Test Account 1'),
      new Account(Name = 'StayHub Test Account 2')
    };

    insert accounts;

    Set<Id> accountIds = new Map<Id, Account>(accounts).keySet();
    User currentUser = [
      SELECT Id
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ];

    Test.startTest();
    System.runAs(currentUser) {
      List<Account> results = StayHubQualityGateDemo.getAccounts(accountIds);

      System.assertEquals(2, results.size());
    }
    Test.stopTest();
  }

  /**
   * @description Verifies that an empty input returns an empty list.
   */
  @IsTest
  static void testGetAccountsWithEmptyInput() {
    User currentUser = [
      SELECT Id
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ];

    Test.startTest();
    System.runAs(currentUser) {
      List<Account> results = StayHubQualityGateDemo.getAccounts(new Set<Id>());

      System.assertEquals(0, results.size());
    }
    Test.stopTest();
  }
}
