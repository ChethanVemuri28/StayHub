public with sharing class StayHubQualityGateDemo {

    public static List<Account> getAccounts(Set<Id> accountIds) {

        if (accountIds == null || accountIds.isEmpty()) {
            return new List<Account>();
        }

        return [
            SELECT Id, Name
            FROM Account
            WHERE Id IN :accountIds
            ORDER BY Name
        ];
    }
}