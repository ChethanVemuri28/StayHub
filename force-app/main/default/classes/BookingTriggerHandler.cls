/**
 * @description Handles booking validation, Inquiry expiry and room-pricing recalculation.
 */
public without sharing class BookingTriggerHandler {

    /**
     * @description Dispatches booking trigger operations based on trigger context.
     */
    public static void run() {
        List<Booking__c> newBookings = (List<Booking__c>) Trigger.new;

        if (Trigger.isBefore) {
            validateBookingDates(newBookings);
            applyInquiryExpiry(newBookings);
        }

        if (Trigger.isAfter && Trigger.isUpdate) {
            Map<Id, Booking__c> oldBookingMap =
                (Map<Id, Booking__c>) Trigger.oldMap;

            recalculateChangedBookings(newBookings, oldBookingMap);
        }
    }

    /**
     * @description Validates booking check-in and check-out dates.
     */
    private static void validateBookingDates(List<Booking__c> bookings) {
        for (Booking__c booking : bookings) {
            if (
                booking.Check_In_Date__c != null &&
                booking.Check_Out_Date__c != null &&
                booking.Check_Out_Date__c <= booking.Check_In_Date__c
            ) {
                booking.Check_Out_Date__c.addError(
                    'Check-out date must be later than check-in date.'
                );
            }
        }
    }

    /**
     * @description Sets or clears the temporary Inquiry expiry timestamp.
     */
    private static void applyInquiryExpiry(List<Booking__c> bookings) {
        Map<Id, Booking__c> oldBookingMap =
            Trigger.isUpdate
                ? (Map<Id, Booking__c>) Trigger.oldMap
                : null;

        Datetime holdStartTime = System.now();

        for (Booking__c booking : bookings) {
            String currentStatus = String.isBlank(booking.Status__c)
                ? 'Inquiry'
                : booking.Status__c;

            if (currentStatus == 'Inquiry') {
                Boolean isNewInquiry =
                    Trigger.isInsert ||
                    oldBookingMap.get(booking.Id).Status__c != 'Inquiry';

                if (isNewInquiry || booking.Inquiry_Expires_At__c == null) {
                    booking.Inquiry_Expires_At__c =
                        BookingRuleService.calculateInquiryExpiry(
                            holdStartTime
                        );
                }
            } else {
                booking.Inquiry_Expires_At__c = null;
            }
        }
    }

    /**
     * @description Recalculates room pricing when booking dates change.
     */
    private static void recalculateChangedBookings(
        List<Booking__c> newBookings,
        Map<Id, Booking__c> oldBookingMap
    ) {
        Set<Id> changedBookingIds = new Set<Id>();

        for (Booking__c booking : newBookings) {
            Booking__c oldBooking = oldBookingMap.get(booking.Id);

            if (hasDateChanges(booking, oldBooking) && hasValidDates(booking)) {
                changedBookingIds.add(booking.Id);
            }
        }

        if (!changedBookingIds.isEmpty()) {
            BookingRoomPricingService.recalculateNightsForBookings(
                changedBookingIds
            );
        }
    }

    private static Boolean hasDateChanges(
        Booking__c booking,
        Booking__c oldBooking
    ) {
        return booking.Check_In_Date__c != oldBooking.Check_In_Date__c ||
            booking.Check_Out_Date__c != oldBooking.Check_Out_Date__c;
    }

    private static Boolean hasValidDates(Booking__c booking) {
        return booking.Check_In_Date__c != null &&
            booking.Check_Out_Date__c != null &&
            booking.Check_Out_Date__c > booking.Check_In_Date__c;
    }
}
