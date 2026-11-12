@IsTest
private class BookingRuleServiceTest {

    @IsTest
    static void testGetInquiryHoldHours() {
        Test.startTest();
        Integer hours = BookingRuleService.getInquiryHoldHours();
        Test.stopTest();

        System.assertEquals(
            6,
            hours,
            'The configured Inquiry hold duration should be six hours.'
        );
    }

    @IsTest
    static void testCalculateInquiryExpiry() {
        Datetime startTime = Datetime.newInstanceGmt(
            2026, 11, 12, 10, 0, 0
        );

        Test.startTest();
        Datetime expiry =
            BookingRuleService.calculateInquiryExpiry(startTime);
        Test.stopTest();

        System.assertEquals(
            startTime.addHours(6),
            expiry,
            'Inquiry expiry should be six hours after the start time.'
        );
    }

    @IsTest
    static void testNullStartTimeRejected() {
        try {
            BookingRuleService.calculateInquiryExpiry(null);
            System.assert(false, 'Expected a configuration exception.');
        } catch (
            BookingRuleService.BookingRuleConfigurationException e
        ) {
            System.assert(
                e.getMessage().contains('cannot be null'),
                'Unexpected exception message.'
            );
        }
    }
}
