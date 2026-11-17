@IsTest
private class BookingRuleServiceTest {
  private static User getTestUser() {
    Profile profile = [
      SELECT Id
      FROM Profile
      WHERE Id = :UserInfo.getProfileId()
    ];

    User testUser = new User(
      Alias = 'ruletest',
      Email = 'rule.test@example.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Rule Tester',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = profile.Id,
      TimeZoneSidKey = 'Asia/Kolkata',
      Username = 'stayhub.rule.' + UserInfo.getOrganizationId() + '@example.com'
    );
    insert testUser;
    return testUser;
  }

  @IsTest
  static void testGetInquiryHoldHours() {
    User testUser = getTestUser();

    System.runAs(testUser) {
      Test.startTest();
      Integer hours = BookingRuleService.getInquiryHoldHours();
      Test.stopTest();

      System.assertEquals(
        6,
        hours,
        'The configured Inquiry hold duration should be six hours.'
      );
    }
  }

  @IsTest
  static void testCalculateInquiryExpiry() {
    User testUser = getTestUser();

    System.runAs(testUser) {
      Datetime startTime = Datetime.newInstanceGmt(2026, 11, 12, 10, 0, 0);

      Test.startTest();
      Datetime expiry = BookingRuleService.calculateInquiryExpiry(startTime);
      Test.stopTest();

      System.assertEquals(
        startTime.addHours(6),
        expiry,
        'Inquiry expiry should be six hours after the start time.'
      );
    }
  }

  @IsTest
  static void testNullStartTimeRejected() {
    User testUser = getTestUser();

    System.runAs(testUser) {
      try {
        BookingRuleService.calculateInquiryExpiry(null);
        System.assert(false, 'Expected a configuration exception.');
      } catch (BookingRuleService.BookingRuleConfigurationException e) {
        System.assert(
          e.getMessage().contains('cannot be null'),
          'Unexpected exception message.'
        );
      }
    }
  }
}
