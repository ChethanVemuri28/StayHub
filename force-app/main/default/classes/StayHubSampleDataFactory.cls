/**
 * @description Provides configured reference records and Rate Plan metadata
 * for StayHub sample data generation.
 */
@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class StayHubSampleDataFactory {
  public class ReferenceData {
    public Account partnerAccount;
    public Contact guestContact;
    public Map<String, Rate_Plan__mdt> ratePlans;
  }

  /**
   * @description Loads reference records using the configured Custom Labels.
   * @return Validated reference data.
   */
  public static ReferenceData validateReferenceData() {
    String accountName = System.Label.StayHub_Partner_Account_Name;
    String contactName = System.Label.StayHub_Guest_Contact_Name;
    validateConfiguredNames(accountName, contactName);

    Account partner = findPartnerByName(accountName);
    Contact guest = findGuestByName(contactName, partner.Id);
    return buildReferenceData(partner, guest, loadRatePlans());
  }

  /**
   * @description Validates supplied Account and Contact IDs.
   * @param partnerAccountId Configured Partner Account ID.
   * @param guestContactId Configured Guest Contact ID.
   * @return Validated reference data.
   */
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

  /**
   * @description Validates supplied reference records and Rate Plans.
   * @param partnerAccountId Partner Account ID.
   * @param guestContactId Guest Contact ID.
   * @param suppliedRatePlans Rate Plan metadata records.
   * @return Validated reference data.
   */
  public static ReferenceData validateReferenceData(
    Id partnerAccountId,
    Id guestContactId,
    Map<String, Rate_Plan__mdt> suppliedRatePlans
  ) {
    validateIds(partnerAccountId, guestContactId);
    validateObjectAccess();
    Account partner = loadPartnerAccount(partnerAccountId);
    Contact guest = loadGuestContact(guestContactId);
    validateGuestAccount(guest, partner);
    validateRatePlans(suppliedRatePlans);
    return buildReferenceData(partner, guest, suppliedRatePlans);
  }

  private static void validateConfiguredNames(
    String accountName,
    String contactName
  ) {
    if (String.isBlank(accountName) || String.isBlank(contactName)) {
      throw new IllegalArgumentException(
        'Partner Account and Guest Contact Custom Labels must be configured.'
      );
    }
  }

  private static Account findPartnerByName(String accountName) {
    List<Account> accounts = [
      SELECT Id, Name
      FROM Account
      WHERE Name = :accountName
      LIMIT 2
    ];
    if (accounts.size() != 1) {
      throw new IllegalArgumentException(
        'Expected exactly one configured Partner Account. Found: ' +
        accounts.size()
      );
    }
    return accounts[0];
  }

  private static Contact findGuestByName(String contactName, Id accountId) {
    List<Contact> contacts = [
      SELECT Id, Name, AccountId
      FROM Contact
      WHERE Name = :contactName AND AccountId = :accountId
      LIMIT 2
    ];
    if (contacts.size() != 1) {
      throw new IllegalArgumentException(
        'Expected exactly one configured Guest Contact for the Partner Account. Found: ' +
        contacts.size()
      );
    }
    return contacts[0];
  }

  private static void validateIds(Id partnerAccountId, Id guestContactId) {
    if (partnerAccountId == null || guestContactId == null) {
      throw new IllegalArgumentException(
        'Partner Account ID and Guest Contact ID are required.'
      );
    }
  }

  private static void validateObjectAccess() {
    if (!Schema.sObjectType.Account.isAccessible()) {
      throw new SecurityException('Insufficient access to Account.');
    }
    if (!Schema.sObjectType.Contact.isAccessible()) {
      throw new SecurityException('Insufficient access to Contact.');
    }
  }

  private static void validateGuestAccount(Contact guest, Account partner) {
    if (guest.AccountId != partner.Id) {
      throw new IllegalArgumentException(
        'Guest Contact does not belong to the configured Partner Account.'
      );
    }
  }

  private static ReferenceData buildReferenceData(
    Account partner,
    Contact guest,
    Map<String, Rate_Plan__mdt> plans
  ) {
    ReferenceData references = new ReferenceData();
    references.partnerAccount = partner;
    references.guestContact = guest;
    references.ratePlans = plans;
    return references;
  }

  /**
   * @description Retrieves the configured Partner Account.
   * @param accountId Partner Account ID.
   * @return Matching Account.
   */
  private static Account loadPartnerAccount(Id accountId) {
    List<Account> accounts = [
      SELECT Id, Name
      FROM Account
      WHERE Id = :accountId
      LIMIT 1
    ];
    if (accounts.isEmpty()) {
      throw new IllegalArgumentException(
        'Configured Partner Account was not found.'
      );
    }
    return accounts[0];
  }

  /**
   * @description Retrieves the configured Guest Contact.
   * @param contactId Guest Contact ID.
   * @return Matching Contact.
   */
  private static Contact loadGuestContact(Id contactId) {
    List<Contact> contacts = [
      SELECT Id, Name, AccountId
      FROM Contact
      WHERE Id = :contactId
      LIMIT 1
    ];
    if (contacts.isEmpty()) {
      throw new IllegalArgumentException(
        'Configured Guest Contact was not found.'
      );
    }
    return contacts[0];
  }

  /**
   * @description Checks that all required seasonal Rate Plans exist.
   * @param suppliedRatePlans Rate Plan metadata records.
   */
  private static void validateRatePlans(
    Map<String, Rate_Plan__mdt> suppliedRatePlans
  ) {
    if (suppliedRatePlans == null) {
      throw new IllegalArgumentException(
        'Rate Plan configuration is required.'
      );
    }
    Set<String> requiredPlans = new Set<String>{
      'Low_Season',
      'Shoulder_Season',
      'Peak_Season'
    };
    if (!suppliedRatePlans.keySet().containsAll(requiredPlans)) {
      throw new IllegalArgumentException(
        'One or more required Rate Plan records are missing.'
      );
    }
  }

  /**
   * @description Loads all configured seasonal Rate Plans.
   * @return Rate Plans keyed by DeveloperName.
   */
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
      WHERE DeveloperName != NULL
    ]) {
      plans.put(plan.DeveloperName, plan);
    }
    return plans;
  }
}
