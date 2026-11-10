trigger BookingRoomTrigger on Booking_Room__c (before insert, before update) {

    List<Booking_Room__c> roomsToCalculate = new List<Booking_Room__c>();

    for (Booking_Room__c room : Trigger.new) {
        if (Trigger.isInsert ||
            room.Booking__c != Trigger.oldMap.get(room.Id).Booking__c) {
            roomsToCalculate.add(room);
        }
    }

    if (!roomsToCalculate.isEmpty()) {
        BookingRoomPricingService.calculateNights(roomsToCalculate);
    }
}