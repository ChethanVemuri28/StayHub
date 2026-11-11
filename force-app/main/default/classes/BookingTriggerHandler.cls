/**
 * @description Handles booking validation and room-pricing recalculation.
 */
public without sharing class BookingTriggerHandler {
  /**
   * @description Dispatches booking trigger operations based on trigger context.
   */
  public static void run() {
    if (Trigger.isBefore) {
      validateBookingDates(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
      recalculateChangedBookings(Trigger.new, Trigger.oldMap);
    }
  }

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
      BookingRoomPricingService.recalculateNightsForBookings(changedBookingIds);
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
