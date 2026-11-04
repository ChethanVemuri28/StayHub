/**
 * @description Demonstrates a bulkified Account query for StayHub CI validation.
 */
public with sharing class StayHubQualityGateDemo {
  /**
   * @description Retrieves Accounts matching the supplied IDs in user mode.
   * @param accountIds Set of Account record IDs to retrieve.
   * @return Matching Account records, ordered by Name.
   */
  public static List<Account> getAccounts(Set<Id> accountIds) {
    if (accountIds == null || accountIds.isEmpty()) {
      return new List<Account>();
    }

    return [
      SELECT Id, Name
      FROM Account
      WHERE Id IN :accountIds
      WITH USER_MODE
      ORDER BY Name
    ];
  }

  /**
   * @description Demonstrates an intentional SOQL-in-loop violation for CI testing.
   * @param accountNames Names of Accounts to retrieve.
   * @return Matching Account records.
   */
  public static List<Account> getAccountsWithViolation(
    List<String> accountNames
  ) {
    List<Account> results = new List<Account>();

    for (String accountName : accountNames) {
      results.addAll(
        [
          SELECT Id, Name
          FROM Account
          WHERE Name = :accountName
          WITH USER_MODE
        ]
      );
    }

    return results;
  }
}
