public with sharing class StayHubSampleDataFactory {
  public static final Id PARTNER_ACCOUNT_ID = '001HE00000N2KlTYAV';

  public static final Id GUEST_CONTACT_ID = '003HE00000LEJ3VYAX';

  public class ReferenceData {
    public Account partnerAccount;
    public Contact guestContact;
    public Map<String, Rate_Plan__mdt> ratePlans;
  }

  // Production entry point: uses existing StayHub records.
  public static ReferenceData validateReferenceData() {
    return validateReferenceData(
      PARTNER_ACCOUNT_ID,
      GUEST_CONTACT_ID,
      loadRatePlans()
    );
  }

  // Testable entry point: accepts supplied reference IDs.
  public static ReferenceData validateReferenceData(
    Id partnerAccountId,
    Id guestContactId
  ) {
    return validateReferenceData(
      partnerAccountId,
      guestContactId,
      loadRatePlans()
    );
  }

  // Testable entry point: also accepts supplied Rate Plans.
  public static ReferenceData validateReferenceData(
    Id partnerAccountId,
    Id guestContactId,
    Map<String, Rate_Plan__mdt> suppliedRatePlans
  ) {
    if (partnerAccountId == null) {
      throw new IllegalArgumentException('Partner Account ID is required.');
    }

    if (guestContactId == null) {
      throw new IllegalArgumentException('Guest Contact ID is required.');
    }

    List<Account> accounts = [
      SELECT Id, Name
      FROM Account
      WHERE Id = :partnerAccountId
      LIMIT 1
    ];

    if (accounts.isEmpty()) {
      throw new IllegalArgumentException(
        'Configured Partner Account was not found.'
      );
    }

    List<Contact> contacts = [
      SELECT Id, Name, AccountId
      FROM Contact
      WHERE Id = :guestContactId
      LIMIT 1
    ];

    if (contacts.isEmpty()) {
      throw new IllegalArgumentException(
        'Configured Guest Contact was not found.'
      );
    }

    if (contacts[0].AccountId != accounts[0].Id) {
      throw new IllegalArgumentException(
        'Guest Contact does not belong to the configured Partner Account.'
      );
    }

    if (suppliedRatePlans == null) {
      throw new IllegalArgumentException(
        'Rate Plan configuration is required.'
      );
    }

    Set<String> expectedPlans = new Set<String>{
      'Low_Season',
      'Shoulder_Season',
      'Peak_Season'
    };

    if (!suppliedRatePlans.keySet().containsAll(expectedPlans)) {
      throw new IllegalArgumentException(
        'One or more required Rate Plan records are missing.'
      );
    }

    ReferenceData references = new ReferenceData();
    references.partnerAccount = accounts[0];
    references.guestContact = contacts[0];
    references.ratePlans = suppliedRatePlans;

    return references;
  }

  private static Map<String, Rate_Plan__mdt> loadRatePlans() {
    Map<String, Rate_Plan__mdt> plans = new Map<String, Rate_Plan__mdt>();

    for (Rate_Plan__mdt plan : [
      SELECT
        DeveloperName,
        MasterLabel,
        Start_Date__c,
        End_Date__c,
        Rate_Multiplier__c,
        Length_of_Stay_Discount__c,
        Member_Discount__c,
        Tax_Percentage__c
      FROM Rate_Plan__mdt
    ]) {
      plans.put(plan.DeveloperName, plan);
    }

    return plans;
  }
}
