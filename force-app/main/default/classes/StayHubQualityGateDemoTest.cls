@IsTest
private class StayHubQualityGateDemoTest {

    @IsTest
    static void testGetAccounts() {

        List<Account> accounts = new List<Account>{
            new Account(Name = 'StayHub Test Account 1'),
            new Account(Name = 'StayHub Test Account 2')
        };

        insert accounts;

        Set<Id> accountIds = new Map<Id, Account>(accounts).keySet();

        Test.startTest();
        List<Account> results =
            StayHubQualityGateDemo.getAccounts(accountIds);
        Test.stopTest();

        System.assertEquals(2, results.size());
    }

    @IsTest
    static void testGetAccountsWithEmptyInput() {

        Test.startTest();
        List<Account> results =
            StayHubQualityGateDemo.getAccounts(new Set<Id>());
        Test.stopTest();

        System.assertEquals(0, results.size());
    }
}