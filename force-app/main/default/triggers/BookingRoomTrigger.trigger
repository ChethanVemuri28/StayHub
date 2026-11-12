trigger BookingRoomTrigger on Booking_Room__c(before insert, before update) {
  BookingRoomTriggerHandler.handleBeforeSave(
    Trigger.new,
    Trigger.isInsert ? null : Trigger.oldMap
  );
}
