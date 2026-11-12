/**
 * @description Handles booking-room trigger operations.
 */
public without sharing class BookingRoomTriggerHandler {
  /**
   * @description Calculates nights when a booking room is inserted or its
   * associated booking changes.
   * @param newRooms Booking-room records from the trigger.
   * @param oldRoomMap Previous booking-room records, or null during insert.
   */
  public static void handleBeforeSave(
    List<Booking_Room__c> newRooms,
    Map<Id, Booking_Room__c> oldRoomMap
  ) {
    List<Booking_Room__c> roomsToCalculate = new List<Booking_Room__c>();

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
}
