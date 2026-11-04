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
   * @description Retrieves Accounts matching the supplied names using one SOQL query.
   * @param accountNames Set of Account names to retrieve.
   * @return Matching Account records, ordered by Name.
   */
  public static List<Account> getAccountsByNames(Set<String> accountNames) {
    if (accountNames == null || accountNames.isEmpty()) {
      return new List<Account>();
    }

    return [
      SELECT Id, Name
      FROM Account
      WHERE Name IN :accountNames
      WITH USER_MODE
      ORDER BY Name
    ];
  }
}
