@IsTest
private class BookingInquiryExpiryTest {

    @TestSetup
    static void setupData() {
        Account partner = new Account(Name = 'Inquiry Test Partner');
        insert partner;

        Contact guest = new Contact(
            FirstName = 'Inquiry',
            LastName = 'Test Guest',
            AccountId = partner.Id
        );
        insert guest;
    }

    private static Booking__c createBooking(String status) {
        Contact guest = [
            SELECT Id
            FROM Contact
            WHERE LastName = 'Test Guest'
            LIMIT 1
        ];

        Booking__c booking = new Booking__c(
            Guest__c = guest.Id,
            Booking_Date__c = System.now(),
            Check_In_Date__c = Date.today().addDays(2),
            Check_Out_Date__c = Date.today().addDays(5),
            Number_of_Adults__c = 2,
            Status__c = status
        );

        insert booking;
        return booking;
    }

    @IsTest
    static void testNewInquiryGetsSixHourExpiry() {
        Booking__c booking = createBooking('Inquiry');

        booking = [
            SELECT CreatedDate, Inquiry_Expires_At__c
            FROM Booking__c
            WHERE Id = :booking.Id
        ];

        System.assertNotEquals(
            null,
            booking.Inquiry_Expires_At__c,
            'A new Inquiry booking must receive an expiry timestamp.'
        );

        Datetime expectedExpiry = booking.CreatedDate.addHours(6);
        Long differenceMs = Math.abs(
            booking.Inquiry_Expires_At__c.getTime() -
            expectedExpiry.getTime()
        );

        System.assert(
            differenceMs <= 2000,
            'Inquiry expiry should be six hours after creation. Difference in milliseconds: ' +
            differenceMs
        );
    }

    @IsTest
    static void testInquiryEditPreservesExpiry() {
        Booking__c booking = createBooking('Inquiry');

        Datetime originalExpiry = [
            SELECT Inquiry_Expires_At__c
            FROM Booking__c
            WHERE Id = :booking.Id
        ].Inquiry_Expires_At__c;

        Booking__c updateRecord = new Booking__c(
            Id = booking.Id,
            Special_Requests__c = 'Late arrival requested'
        );
        update updateRecord;

        Datetime updatedExpiry = [
            SELECT Inquiry_Expires_At__c
            FROM Booking__c
            WHERE Id = :booking.Id
        ].Inquiry_Expires_At__c;

        System.assertEquals(
            originalExpiry,
            updatedExpiry,
            'Editing an Inquiry booking must not extend its hold.'
        );
    }

    @IsTest
    static void testConfirmedBookingClearsExpiry() {
        Booking__c booking = createBooking('Inquiry');

        update new Booking__c(
            Id = booking.Id,
            Status__c = 'Confirmed'
        );

        booking = [
            SELECT Inquiry_Expires_At__c
            FROM Booking__c
            WHERE Id = :booking.Id
        ];

        System.assertEquals(
            null,
            booking.Inquiry_Expires_At__c,
            'Confirmed bookings must not retain an Inquiry expiry.'
        );
    }

    @IsTest
    static void testReturningToInquiryStartsNewHold() {
        Booking__c booking = createBooking('Inquiry');

        update new Booking__c(
            Id = booking.Id,
            Status__c = 'Confirmed'
        );

        Booking__c confirmedBooking = [
            SELECT Inquiry_Expires_At__c
            FROM Booking__c
            WHERE Id = :booking.Id
        ];

        System.assertEquals(
            null,
            confirmedBooking.Inquiry_Expires_At__c,
            'Confirmation must clear the Inquiry expiry.'
        );

        update new Booking__c(
            Id = booking.Id,
            Status__c = 'Inquiry'
        );

        Booking__c returnedBooking = [
            SELECT Inquiry_Expires_At__c
            FROM Booking__c
            WHERE Id = :booking.Id
        ];

        System.assertNotEquals(
            null,
            returnedBooking.Inquiry_Expires_At__c,
            'Returning to Inquiry must create a new expiry.'
        );
    }

    @IsTest
    static void testConfirmedBookingHasNoInquiryExpiry() {
        Booking__c booking = createBooking('Confirmed');

        booking = [
            SELECT Inquiry_Expires_At__c
            FROM Booking__c
            WHERE Id = :booking.Id
        ];

        System.assertEquals(
            null,
            booking.Inquiry_Expires_At__c,
            'A Confirmed booking must not receive an Inquiry expiry.'
        );
    }
}