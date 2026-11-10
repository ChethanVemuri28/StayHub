public without sharing class BookingRoomPricingService {
  public static void calculateNights(List<Booking_Room__c> bookingRooms) {
    Set<Id> bookingIds = new Set<Id>();

    for (Booking_Room__c bookingRoom : bookingRooms) {
      if (bookingRoom.Booking__c != null) {
        bookingIds.add(bookingRoom.Booking__c);
      }
    }

    if (bookingIds.isEmpty()) {
      return;
    }

    Map<Id, Booking__c> bookingsById = new Map<Id, Booking__c>(
      [
        SELECT Id, Check_In_Date__c, Check_Out_Date__c
        FROM Booking__c
        WHERE Id IN :bookingIds
      ]
    );

    for (Booking_Room__c bookingRoom : bookingRooms) {
      Booking__c booking = bookingsById.get(bookingRoom.Booking__c);

      if (
        booking == null ||
        booking.Check_In_Date__c == null ||
        booking.Check_Out_Date__c == null ||
        booking.Check_Out_Date__c <= booking.Check_In_Date__c
      ) {
        bookingRoom.addError(
          'The associated booking must have a check-out date later than its check-in date.'
        );
        continue;
      }

      bookingRoom.Nights_for_Pricing__c = booking.Check_In_Date__c.daysBetween(
        booking.Check_Out_Date__c
      );
    }
  }

  public static void recalculateNightsForBookings(Set<Id> bookingIds) {
    if (bookingIds == null || bookingIds.isEmpty()) {
      return;
    }

    Map<Id, Booking__c> bookingsById = new Map<Id, Booking__c>(
      [
        SELECT Id, Check_In_Date__c, Check_Out_Date__c
        FROM Booking__c
        WHERE Id IN :bookingIds
      ]
    );

    List<Booking_Room__c> roomsToUpdate = new List<Booking_Room__c>();

    for (Booking_Room__c room : [
      SELECT Id, Booking__c, Nights_for_Pricing__c
      FROM Booking_Room__c
      WHERE Booking__c IN :bookingIds
    ]) {
      Booking__c booking = bookingsById.get(room.Booking__c);

      if (
        booking != null &&
        booking.Check_In_Date__c != null &&
        booking.Check_Out_Date__c != null &&
        booking.Check_Out_Date__c > booking.Check_In_Date__c
      ) {
        Booking_Room__c roomUpdate = new Booking_Room__c(
          Id = room.Id,
          Nights_for_Pricing__c = booking.Check_In_Date__c.daysBetween(
            booking.Check_Out_Date__c
          )
        );

        roomsToUpdate.add(roomUpdate);
      }
    }

    if (!roomsToUpdate.isEmpty()) {
      update roomsToUpdate;
    }
  }
}
