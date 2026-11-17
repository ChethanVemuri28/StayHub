
/**
 * @description Handles booking-room trigger operations.
 */
public without sharing class BookingRoomTriggerHandler {

  /**
   * @description Coordinates booking-room validation and pricing.
   * @param newRooms Booking-room records from the trigger.
   * @param oldRoomMap Previous booking-room records, or null during insert.
   */
  public static void handleBeforeSave(
    List<Booking_Room__c> newRooms,
    Map<Id, Booking_Room__c> oldRoomMap
  ) {
    validateSingleHotelPerBooking(newRooms);

    List<Booking_Room__c> roomsToCalculate =
      new List<Booking_Room__c>();

    for (Booking_Room__c room : newRooms) {
      Boolean shouldCalculate =
        oldRoomMap == null ||
        room.Booking__c != oldRoomMap.get(room.Id).Booking__c;

      if (shouldCalculate) {
        roomsToCalculate.add(room);
      }
    }

    if (!roomsToCalculate.isEmpty()) {
      BookingRoomPricingService.calculateNights(roomsToCalculate);
    }
  }

  /**
   * @description Ensures every room associated with a booking belongs
   * to the same hotel.
   * @param newRooms Booking-room records being inserted or updated.
   */
  private static void validateSingleHotelPerBooking(
    List<Booking_Room__c> newRooms
  ) {
    Set<Id> bookingIds = new Set<Id>();
    Set<Id> currentRoomIds = new Set<Id>();
    Set<Id> selectedRoomIds = new Set<Id>();

    for (Booking_Room__c bookingRoom : newRooms) {
      if (bookingRoom.Booking__c != null) {
        bookingIds.add(bookingRoom.Booking__c);
      }

      if (bookingRoom.Id != null) {
        currentRoomIds.add(bookingRoom.Id);
      }

      if (bookingRoom.Room__c != null) {
        selectedRoomIds.add(bookingRoom.Room__c);
      }
    }

    if (bookingIds.isEmpty()) {
      return;
    }

    Map<Id, Set<Id>> hotelsByBooking = new Map<Id, Set<Id>>();
    Set<Id> bookingsWithUnknownHotel = new Set<Id>();

    // Retrieve rooms already associated with these bookings.
    for (Booking_Room__c existingRoom : [
      SELECT
        Id,
        Booking__c,
        Room__c,
        Room__r.Room_Type__r.Hotel__c
      FROM Booking_Room__c
      WHERE Booking__c IN :bookingIds
      AND Id NOT IN :currentRoomIds
      WITH SYSTEM_MODE
    ]) {
      Id hotelId = existingRoom.Room__r?.Room_Type__r?.Hotel__c;

      if (hotelId == null) {
        bookingsWithUnknownHotel.add(existingRoom.Booking__c);
      } else {
        if (!hotelsByBooking.containsKey(existingRoom.Booking__c)) {
          hotelsByBooking.put(
            existingRoom.Booking__c,
            new Set<Id>()
          );
        }

        hotelsByBooking.get(existingRoom.Booking__c).add(hotelId);
      }
    }

    // Resolve the hotels belonging to the selected rooms.
    Map<Id, Id> hotelByRoomId = new Map<Id, Id>();

    if (!selectedRoomIds.isEmpty()) {
      for (Room__c room : [
        SELECT Id, Room_Type__r.Hotel__c
        FROM Room__c
        WHERE Id IN :selectedRoomIds
        WITH SYSTEM_MODE
      ]) {
        hotelByRoomId.put(
          room.Id,
          room.Room_Type__r?.Hotel__c
        );
      }
    }

    // Add the incoming rooms to the hotel mapping.
    for (Booking_Room__c bookingRoom : newRooms) {
      if (bookingRoom.Booking__c == null) {
        bookingRoom.addError('A booking is required.');
        continue;
      }

      Id hotelId = hotelByRoomId.get(bookingRoom.Room__c);

      if (hotelId == null) {
        bookingRoom.addError(
          'The selected room must belong to a valid hotel.'
        );
        continue;
      }

      if (bookingsWithUnknownHotel.contains(bookingRoom.Booking__c)) {
        bookingRoom.addError(
          'The hotel for an existing room could not be determined.'
        );
        continue;
      }

      if (!hotelsByBooking.containsKey(bookingRoom.Booking__c)) {
        hotelsByBooking.put(
          bookingRoom.Booking__c,
          new Set<Id>()
        );
      }

      hotelsByBooking.get(bookingRoom.Booking__c).add(hotelId);
    }

    // Reject every incoming room belonging to a conflicting booking.
    for (Booking_Room__c bookingRoom : newRooms) {
      if (
        bookingRoom.Booking__c != null &&
        hotelsByBooking.containsKey(bookingRoom.Booking__c) &&
        hotelsByBooking.get(bookingRoom.Booking__c).size() > 1
      ) {
        bookingRoom.addError(
          'All rooms in a booking must belong to the same hotel.'
        );
      }
    }
  }
}
