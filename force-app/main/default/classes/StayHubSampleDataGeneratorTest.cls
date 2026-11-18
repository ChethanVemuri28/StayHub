@IsTest
private class StayHubSampleDataGeneratorTest {
  private class ReferenceRecords {
    Account partner;
    Contact guest;
  }

  private static ReferenceRecords createReferenceRecords() {
    ReferenceRecords records = new ReferenceRecords();

    records.partner = new Account(
      Name = System.Label.StayHub_Partner_Account_Name
    );
    insert records.partner;

    records.guest = new Contact(
      LastName = System.Label.StayHub_Guest_Contact_Name,
      AccountId = records.partner.Id
    );
    insert records.guest;

    return records;
  }

  @IsTest
  static void standardCount() {
    System.assertEquals(
      7400,
      StayHubSampleDataGenerator.expectedRecordCount(200)
    );
  }

  @IsTest
  static void scaleCount() {
    System.assertEquals(
      1850000,
      StayHubSampleDataGenerator.expectedRecordCount(50000)
    );
  }

  @IsTest
  static void zeroCount() {
    System.assertEquals(0, StayHubSampleDataGenerator.expectedRecordCount(0));
  }

  @IsTest
  static void negativeCountRejected() {
    Boolean thrown = false;

    try {
      StayHubSampleDataGenerator.expectedRecordCount(-1);
    } catch (IllegalArgumentException e) {
      thrown = true;
    }

    System.assert(thrown);
  }

  @IsTest
  static void overLimitRejected() {
    Boolean thrown = false;

    try {
      new StayHubSampleDataGenerator(50001);
    } catch (IllegalArgumentException e) {
      thrown = true;
    }

    System.assert(thrown);
  }

  @IsTest
  static void zeroHotelLaunchRejected() {
    Boolean thrown = false;

    try {
      new StayHubSampleDataGenerator(0);
    } catch (IllegalArgumentException e) {
      thrown = true;
    }

    System.assert(thrown);
  }

  @IsTest
  static void batchCreatesSampleRecords() {
    ReferenceRecords records = createReferenceRecords();

    Test.startTest();
    Id jobId = StayHubSampleDataGenerator.launch(5);
    Test.stopTest();

    AsyncApexJob job = [
      SELECT Id, Status, NumberOfErrors
      FROM AsyncApexJob
      WHERE Id = :jobId
    ];

    System.assertEquals('Completed', job.Status);
    System.assertEquals(0, job.NumberOfErrors);

    List<Hotel__c> hotels = [
      SELECT Id, Name
      FROM Hotel__c
      WHERE Name LIKE 'StayHub Sample Hotel %'
    ];

    System.assertEquals(5, hotels.size());

    Set<Id> hotelIds = new Map<Id, Hotel__c>(hotels).keySet();

    System.assertEquals(
      15,
      [SELECT COUNT() FROM Room_Type__c WHERE Hotel__c IN :hotelIds]
    );

    System.assertEquals(
      75,
      [SELECT COUNT() FROM Room__c WHERE Room_Type__r.Hotel__c IN :hotelIds]
    );

    System.assertEquals(
      25,
      [SELECT COUNT() FROM Booking__c WHERE Guest__c = :records.guest.Id]
    );

    System.assertEquals(
      25,
      [
        SELECT COUNT()
        FROM Booking_Room__c
        WHERE Booking__r.Guest__c = :records.guest.Id
      ]
    );

    System.assertEquals(
      25,
      [
        SELECT COUNT()
        FROM Payment__c
        WHERE Booking__r.Guest__c = :records.guest.Id
      ]
    );

    System.assertEquals(
      15,
      [SELECT COUNT() FROM Review__c WHERE Hotel__c IN :hotelIds]
    );
  }

  @IsTest
  static void factoryValidatesReferenceDataUsingTwoIds() {
    ReferenceRecords records = createReferenceRecords();

    StayHubSampleDataFactory.ReferenceData result = StayHubSampleDataFactory.validateReferenceData(
      records.partner.Id,
      records.guest.Id
    );

    System.assertEquals(records.partner.Id, result.partnerAccount.Id);
    System.assertEquals(records.guest.Id, result.guestContact.Id);
    System.assertNotEquals(null, result.ratePlans);
  }

  @IsTest
  static void factoryValidatesReferenceDataUsingSuppliedPlans() {
    ReferenceRecords records = createReferenceRecords();

    Map<String, Rate_Plan__mdt> plans = Rate_Plan__mdt.getAll();

    StayHubSampleDataFactory.ReferenceData result = StayHubSampleDataFactory.validateReferenceData(
      records.partner.Id,
      records.guest.Id,
      plans
    );

    System.assertEquals(records.partner.Id, result.partnerAccount.Id);
    System.assertEquals(records.guest.Id, result.guestContact.Id);
    System.assertEquals(plans, result.ratePlans);
  }

  @IsTest
  static void factoryRejectsNullIds() {
    Boolean thrown = false;

    try {
      StayHubSampleDataFactory.validateReferenceData(
        null,
        null,
        Rate_Plan__mdt.getAll()
      );
    } catch (IllegalArgumentException e) {
      thrown = true;
    }

    System.assert(thrown);
  }

  @IsTest
  static void factoryRejectsMissingPartnerAccount() {
    ReferenceRecords records = createReferenceRecords();
    Boolean thrown = false;

    try {
      StayHubSampleDataFactory.validateReferenceData(
        UserInfo.getUserId(),
        records.guest.Id,
        Rate_Plan__mdt.getAll()
      );
    } catch (IllegalArgumentException e) {
      thrown = true;
    }

    System.assert(thrown);
  }

  @IsTest
  static void factoryRejectsMissingGuestContact() {
    ReferenceRecords records = createReferenceRecords();
    Boolean thrown = false;

    try {
      StayHubSampleDataFactory.validateReferenceData(
        records.partner.Id,
        UserInfo.getUserId(),
        Rate_Plan__mdt.getAll()
      );
    } catch (IllegalArgumentException e) {
      thrown = true;
    }

    System.assert(thrown);
  }

  @IsTest
  static void factoryRejectsContactFromAnotherAccount() {
    ReferenceRecords records = createReferenceRecords();

    Account otherAccount = new Account(Name = 'StayHub Other Test Account');
    insert otherAccount;

    Contact otherGuest = new Contact(
      LastName = 'StayHub Other Test Guest',
      AccountId = otherAccount.Id
    );
    insert otherGuest;

    Boolean thrown = false;

    try {
      StayHubSampleDataFactory.validateReferenceData(
        records.partner.Id,
        otherGuest.Id,
        Rate_Plan__mdt.getAll()
      );
    } catch (IllegalArgumentException e) {
      thrown = true;
    }

    System.assert(thrown);
  }

  @IsTest
  static void factoryRejectsNullRatePlans() {
    ReferenceRecords records = createReferenceRecords();
    Boolean thrown = false;

    try {
      StayHubSampleDataFactory.validateReferenceData(
        records.partner.Id,
        records.guest.Id,
        null
      );
    } catch (IllegalArgumentException e) {
      thrown = true;
    }

    System.assert(thrown);
  }

  @IsTest
  static void factoryRejectsIncompleteRatePlans() {
    ReferenceRecords records = createReferenceRecords();
    Boolean thrown = false;

    try {
      StayHubSampleDataFactory.validateReferenceData(
        records.partner.Id,
        records.guest.Id,
        new Map<String, Rate_Plan__mdt>()
      );
    } catch (IllegalArgumentException e) {
      thrown = true;
    }

    System.assert(thrown);
  }
}