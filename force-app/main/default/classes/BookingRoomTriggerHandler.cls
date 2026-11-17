/**
 * @description Handles booking-room trigger operations.
 */
public without sharing class BookingRoomTriggerHandler {
  /**
   * @description Holds the data needed to validate hotel consistency.
   */
  private class HotelValidationContext {
    List<Booking_Room__c> newRooms;
    Map<Id, Id> hotelByRoomId;
    Map<Id, Set<Id>> hotelsByBooking;
    Set<Id> bookingsWithUnknownHotel;
  }

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
    calculateChangedRoomNights(newRooms, oldRoomMap);
  }

  /**
   * @description Calculates nights only for newly inserted or reassigned rooms.
   * @param newRooms Booking-room records from the trigger.
   * @param oldRoomMap Previous booking-room records, or null during insert.
   */
  private static void calculateChangedRoomNights(
    List<Booking_Room__c> newRooms,
    Map<Id, Booking_Room__c> oldRoomMap
  ) {
    List<Booking_Room__c> roomsToCalculate = new List<Booking_Room__c>();

    for (Booking_Room__c room : newRooms) {
      Booking_Room__c oldRoom = oldRoomMap == null
        ? null
        : oldRoomMap.get(room.Id);
      if (oldRoomMap == null || room.Booking__c != oldRoom.Booking__c) {
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
    Set<Id> bookingIds = collectBookingIds(newRooms);
    if (bookingIds.isEmpty()) {
      return;
    }

    Set<Id> currentRoomIds = collectCurrentRoomIds(newRooms);
    Set<Id> selectedRoomIds = collectSelectedRoomIds(newRooms);
    Map<Id, Set<Id>> hotelsByBooking = loadExistingBookingHotels(
      bookingIds,
      currentRoomIds
    );
    Set<Id> bookingsWithUnknownHotel = loadBookingsWithUnknownHotel(
      bookingIds,
      currentRoomIds
    );
    Map<Id, Id> hotelByRoomId = loadSelectedRoomHotels(selectedRoomIds);

    HotelValidationContext context = new HotelValidationContext();
    context.newRooms = newRooms;
    context.hotelByRoomId = hotelByRoomId;
    context.hotelsByBooking = hotelsByBooking;
    context.bookingsWithUnknownHotel = bookingsWithUnknownHotel;

    addIncomingRoomsToHotelMap(context);
    rejectBookingsWithMultipleHotels(newRooms, hotelsByBooking);
  }

  private static Set<Id> collectBookingIds(List<Booking_Room__c> rooms) {
    Set<Id> ids = new Set<Id>();
    for (Booking_Room__c room : rooms) {
      if (room.Booking__c != null) {
        ids.add(room.Booking__c);
      }
    }
    return ids;
  }

  private static Set<Id> collectCurrentRoomIds(List<Booking_Room__c> rooms) {
    Set<Id> ids = new Set<Id>();
    for (Booking_Room__c room : rooms) {
      if (room.Id != null) {
        ids.add(room.Id);
      }
    }
    return ids;
  }

  private static Set<Id> collectSelectedRoomIds(List<Booking_Room__c> rooms) {
    Set<Id> ids = new Set<Id>();
    for (Booking_Room__c room : rooms) {
      if (room.Room__c != null) {
        ids.add(room.Room__c);
      }
    }
    return ids;
  }

  private static Map<Id, Set<Id>> loadExistingBookingHotels(
    Set<Id> bookingIds,
    Set<Id> currentRoomIds
  ) {
    Map<Id, Set<Id>> hotelsByBooking = new Map<Id, Set<Id>>();
    for (Booking_Room__c existingRoom : [
      SELECT Id, Booking__c, Room__r.Room_Type__r.Hotel__c
      FROM Booking_Room__c
      WHERE Booking__c IN :bookingIds AND Id NOT IN :currentRoomIds
      WITH SYSTEM_MODE
    ]) {
      Id hotelId = existingRoom.Room__r?.Room_Type__r?.Hotel__c;
      if (hotelId != null) {
        addHotel(hotelsByBooking, existingRoom.Booking__c, hotelId);
      }
    }
    return hotelsByBooking;
  }

  private static Set<Id> loadBookingsWithUnknownHotel(
    Set<Id> bookingIds,
    Set<Id> currentRoomIds
  ) {
    Set<Id> unknownBookings = new Set<Id>();
    for (Booking_Room__c existingRoom : [
      SELECT Id, Booking__c, Room__r.Room_Type__r.Hotel__c
      FROM Booking_Room__c
      WHERE Booking__c IN :bookingIds AND Id NOT IN :currentRoomIds
      WITH SYSTEM_MODE
    ]) {
      if (existingRoom.Room__r?.Room_Type__r?.Hotel__c == null) {
        unknownBookings.add(existingRoom.Booking__c);
      }
    }
    return unknownBookings;
  }

  private static Map<Id, Id> loadSelectedRoomHotels(Set<Id> roomIds) {
    Map<Id, Id> hotelByRoomId = new Map<Id, Id>();
    if (roomIds.isEmpty()) {
      return hotelByRoomId;
    }

    for (Room__c room : [
      SELECT Id, Room_Type__r.Hotel__c
      FROM Room__c
      WHERE Id IN :roomIds
      WITH SYSTEM_MODE
    ]) {
      hotelByRoomId.put(room.Id, room.Room_Type__r?.Hotel__c);
    }
    return hotelByRoomId;
  }

  private static void addIncomingRoomsToHotelMap(
    HotelValidationContext context
  ) {
    for (Booking_Room__c room : context.newRooms) {
      if (room.Booking__c == null) {
        room.addError('A booking is required.');
        continue;
      }

      Id hotelId = context.hotelByRoomId.get(room.Room__c);
      if (hotelId == null) {
        room.addError('The selected room must belong to a valid hotel.');
        continue;
      }

      if (context.bookingsWithUnknownHotel.contains(room.Booking__c)) {
        room.addError(
          'The hotel for an existing room could not be determined.'
        );
        continue;
      }
      addHotel(context.hotelsByBooking, room.Booking__c, hotelId);
    }
  }

  private static void addHotel(
    Map<Id, Set<Id>> hotelsByBooking,
    Id bookingId,
    Id hotelId
  ) {
    if (!hotelsByBooking.containsKey(bookingId)) {
      hotelsByBooking.put(bookingId, new Set<Id>());
    }
    hotelsByBooking.get(bookingId).add(hotelId);
  }

  private static void rejectBookingsWithMultipleHotels(
    List<Booking_Room__c> newRooms,
    Map<Id, Set<Id>> hotelsByBooking
  ) {
    for (Booking_Room__c room : newRooms) {
      Set<Id> hotelIds = hotelsByBooking.get(room.Booking__c);
      if (room.Booking__c != null && hotelIds != null && hotelIds.size() > 1) {
        room.addError('All rooms in a booking must belong to the same hotel.');
      }
    }
  }
}
