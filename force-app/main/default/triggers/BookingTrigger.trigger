trigger BookingTrigger on Booking__c (
    before insert,
    before update,
    after update
) {
    if (Trigger.isBefore) {
        for (Booking__c booking : Trigger.new) {
            if (booking.Check_In_Date__c != null &&
                booking.Check_Out_Date__c != null &&
                booking.Check_Out_Date__c <= booking.Check_In_Date__c) {

                booking.Check_Out_Date__c.addError(
                    'Check-out date must be later than check-in date.'
                );
            }
        }
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        Set<Id> changedBookingIds = new Set<Id>();

        for (Booking__c booking : Trigger.new) {
            Booking__c oldBooking = Trigger.oldMap.get(booking.Id);

            if (booking.Check_In_Date__c != oldBooking.Check_In_Date__c ||
                booking.Check_Out_Date__c != oldBooking.Check_Out_Date__c) {

                if (booking.Check_In_Date__c != null &&
                    booking.Check_Out_Date__c != null &&
                    booking.Check_Out_Date__c > booking.Check_In_Date__c) {

                    changedBookingIds.add(booking.Id);
                }
            }
        }

        if (!changedBookingIds.isEmpty()) {
            BookingRoomPricingService.recalculateNightsForBookings(
                changedBookingIds
            );
        }
    }
}