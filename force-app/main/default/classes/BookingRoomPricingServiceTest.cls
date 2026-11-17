
@IsTest
private class BookingRoomPricingServiceTest {

  @TestSetup
  static void setupData() {
    Account partner = new Account(
      Name = 'StayHub Test Partner'
    );
    insert partner;

    Contact guest = new Contact(
      FirstName = 'Test',
      LastName = 'Guest',
      AccountId = partner.Id
    );
    insert guest;
  }

  // ------------------------------------------------------------
  // TEST DATA FACTORY METHODS
  // ------------------------------------------------------------

  private static Booking__c createBooking() {
    Contact guest = [
      SELECT Id
      FROM Contact
      WHERE LastName = 'Guest'
      LIMIT 1
    ];

    Booking__c booking = new Booking__c(
      Guest__c = guest.Id,
      Check_In_Date__c = Date.newInstance(2026, 11, 10),
      Check_Out_Date__c = Date.newInstance(2026, 11, 13),
      Booking_Date__c = System.now(),
      Number_of_Adults__c = 2,
      Status__c = 'Inquiry'
    );

    insert booking;
    return booking;
  }

  private static Hotel__c createHotel(String hotelName) {
    Account partner = [
      SELECT Id
      FROM Account
      WHERE Name = 'StayHub Test Partner'
      LIMIT 1
    ];

    Hotel__c hotel = new Hotel__c(
      Name = hotelName,
      Partner_Account__c = partner.Id,
      Street__c = '1 Test Street',
      City__c = 'Nellore',
      State__c = 'Andhra Pradesh',
      Country__c = 'India',
      Status__c = 'Active'
    );

    insert hotel;
    return hotel;
  }

  private static Room_Type__c createRoomType(
    Id hotelId,
    String typeName
  ) {
    Room_Type__c roomType = new Room_Type__c(
      Name = typeName,
      Hotel__c = hotelId,
      Base_Price__c = 1000,
      Max_Occupancy__c = 2,
      Status__c = 'Active'
    );

    insert roomType;
    return roomType;
  }

  private static Room__c createRoom(
    Id roomTypeId,
    String roomNumber
  ) {
    Room__c room = new Room__c(
      Name = 'Test Room ' + roomNumber,
      Room_Number__c = roomNumber,
      Room_Type__c = roomTypeId,
      Status__c = 'Available'
    );

    insert room;
    return room;
  }

  private static Booking_Room__c createBookingRoom(
    Id bookingId,
    Id roomId,
    Decimal nightlyRate
  ) {
    return new Booking_Room__c(
      Booking__c = bookingId,
      Room__c = roomId,
      Adults__c = 2,
      Nightly_Rate__c = nightlyRate
    );
  }

  // ------------------------------------------------------------
  // PRICING AND ROLLUP TESTS
  // ------------------------------------------------------------

  @IsTest
  static void testInitialNightCalculationAndRollup() {
    Booking__c booking = createBooking();
    Hotel__c hotel = createHotel('Test Hotel 101');

    Room_Type__c roomType = createRoomType(
      hotel.Id,
      'Standard 101'
    );

    Room__c room = createRoom(roomType.Id, '101');

    Booking_Room__c bookingRoom =
      createBookingRoom(booking.Id, room.Id, 1000);

    Test.startTest();
    insert bookingRoom;
    Test.stopTest();

    bookingRoom = [
      SELECT Nights_for_Pricing__c, Room_Total__c
      FROM Booking_Room__c
      WHERE Id = :bookingRoom.Id
    ];

    booking = [
      SELECT Total_Amount__c
      FROM Booking__c
      WHERE Id = :booking.Id
    ];

    System.assertEquals(
      Decimal.valueOf('3'),
      bookingRoom.Nights_for_Pricing__c
    );

    System.assertEquals(
      Decimal.valueOf('3000'),
      bookingRoom.Room_Total__c
    );

    System.assertEquals(
      Decimal.valueOf('3000'),
      booking.Total_Amount__c
    );
  }

  @IsTest
  static void testBookingDateChangeRecalculatesRooms() {
    Booking__c booking = createBooking();
    Hotel__c hotel = createHotel('Test Hotel 201');

    Room_Type__c roomType = createRoomType(
      hotel.Id,
      'Standard 201'
    );

    Room__c room = createRoom(roomType.Id, '201');

    Booking_Room__c bookingRoom =
      createBookingRoom(booking.Id, room.Id, 1000);

    insert bookingRoom;

    booking.Check_Out_Date__c =
      Date.newInstance(2026, 11, 15);

    Test.startTest();
    update booking;
    Test.stopTest();

    bookingRoom = [
      SELECT Nights_for_Pricing__c, Room_Total__c
      FROM Booking_Room__c
      WHERE Id = :bookingRoom.Id
    ];

    booking = [
      SELECT Total_Amount__c
      FROM Booking__c
      WHERE Id = :booking.Id
    ];

    System.assertEquals(
      Decimal.valueOf('5'),
      bookingRoom.Nights_for_Pricing__c
    );

    System.assertEquals(
      Decimal.valueOf('5000'),
      bookingRoom.Room_Total__c
    );

    System.assertEquals(
      Decimal.valueOf('5000'),
      booking.Total_Amount__c
    );
  }

  @IsTest
  static void testBulkRoomCalculationAndRollupSameHotel() {
    Booking__c booking = createBooking();
    Hotel__c hotel = createHotel('Test Hotel 301');

    Room_Type__c roomType = createRoomType(
      hotel.Id,
      'Standard 301'
    );

    Room__c room1 = createRoom(roomType.Id, '301');
    Room__c room2 = createRoom(roomType.Id, '302');

    List<Booking_Room__c> bookingRooms =
      new List<Booking_Room__c>{
        createBookingRoom(booking.Id, room1.Id, 1000),
        createBookingRoom(booking.Id, room2.Id, 1200)
      };

    Test.startTest();
    insert bookingRooms;
    Test.stopTest();

    booking = [
      SELECT Total_Amount__c
      FROM Booking__c
      WHERE Id = :booking.Id
    ];

    System.assertEquals(
      Decimal.valueOf('6600'),
      booking.Total_Amount__c
    );

    for (Booking_Room__c room : [
      SELECT Nights_for_Pricing__c, Room_Total__c
      FROM Booking_Room__c
      WHERE Booking__c = :booking.Id
    ]) {
      System.assertEquals(
        Decimal.valueOf('3'),
        room.Nights_for_Pricing__c
      );

      System.assertNotEquals(
        null,
        room.Room_Total__c
      );
    }
  }

  // ------------------------------------------------------------
  // ONE-HOTEL-PER-BOOKING VALIDATION TESTS
  // ------------------------------------------------------------

  @IsTest
  static void testDifferentHotelsRejectedForSameBooking() {
    Booking__c booking = createBooking();

    Hotel__c hotel1 = createHotel('Hotel One');
    Hotel__c hotel2 = createHotel('Hotel Two');

    Room_Type__c type1 = createRoomType(
      hotel1.Id,
      'Standard One'
    );

    Room_Type__c type2 = createRoomType(
      hotel2.Id,
      'Standard Two'
    );

    Room__c room1 = createRoom(type1.Id, '401');
    Room__c room2 = createRoom(type2.Id, '402');

    List<Booking_Room__c> bookingRooms =
      new List<Booking_Room__c>{
        createBookingRoom(booking.Id, room1.Id, 1000),
        createBookingRoom(booking.Id, room2.Id, 1000)
      };

    Test.startTest();

    Database.SaveResult[] results =
      Database.insert(bookingRooms, false);

    Test.stopTest();

    System.assertEquals(false, results[0].isSuccess());
    System.assertEquals(false, results[1].isSuccess());

    System.assert(
      results[0].getErrors()[0].getMessage().contains(
        'All rooms in a booking must belong to the same hotel.'
      )
    );
  }

  @IsTest
  static void testDifferentHotelRejectedWhenAddedLater() {
    Booking__c booking = createBooking();

    Hotel__c hotel1 = createHotel('Hotel Existing');
    Hotel__c hotel2 = createHotel('Hotel New');

    Room_Type__c type1 = createRoomType(
      hotel1.Id,
      'Existing Type'
    );

    Room_Type__c type2 = createRoomType(
      hotel2.Id,
      'New Type'
    );

    Room__c room1 = createRoom(type1.Id, '501');
    Room__c room2 = createRoom(type2.Id, '502');

    insert createBookingRoom(
      booking.Id,
      room1.Id,
      1000
    );

    Booking_Room__c secondRoom =
      createBookingRoom(booking.Id, room2.Id, 1000);

    Test.startTest();

    Database.SaveResult result =
      Database.insert(secondRoom, false);

    Test.stopTest();

    System.assertEquals(false, result.isSuccess());

    System.assert(
      result.getErrors()[0].getMessage().contains(
        'All rooms in a booking must belong to the same hotel.'
      )
    );
  }

  @IsTest
  static void testRoomCanBeChangedWithinSameHotel() {
    Booking__c booking = createBooking();

    Hotel__c hotel = createHotel('Hotel Same');

    Room_Type__c roomType = createRoomType(
      hotel.Id,
      'Standard Same'
    );

    Room__c room1 = createRoom(roomType.Id, '601');
    Room__c room2 = createRoom(roomType.Id, '602');

    Booking_Room__c bookingRoom =
      createBookingRoom(booking.Id, room1.Id, 1000);

    insert bookingRoom;

    // Update only the Room lookup field.
    Booking_Room__c roomUpdate = new Booking_Room__c(
      Id = bookingRoom.Id,
      Room__c = room2.Id
    );

    Test.startTest();
    update roomUpdate;
    Test.stopTest();

    Booking_Room__c savedRoom = [
      SELECT Room__c
      FROM Booking_Room__c
      WHERE Id = :bookingRoom.Id
    ];

    System.assertEquals(
      room2.Id,
      savedRoom.Room__c
    );
  }

  @IsTest
  static void testRoomCannotBeChangedToDifferentHotel() {
    Booking__c booking = createBooking();

    Hotel__c hotel1 = createHotel('Hotel Original');
    Hotel__c hotel2 = createHotel('Hotel Replacement');

    Room_Type__c type1 = createRoomType(
      hotel1.Id,
      'Original Type'
    );

    Room_Type__c type2 = createRoomType(
      hotel2.Id,
      'Replacement Type'
    );

    Room__c room1 = createRoom(type1.Id, '701');
    Room__c room2 = createRoom(type1.Id, '702');
    Room__c room3 = createRoom(type2.Id, '703');

    Booking_Room__c firstRoom =
      createBookingRoom(booking.Id, room1.Id, 1000);

    Booking_Room__c secondRoom =
      createBookingRoom(booking.Id, room2.Id, 1000);

    insert new List<Booking_Room__c>{
      firstRoom,
      secondRoom
    };

    // Update only the Room lookup field.
    Booking_Room__c roomUpdate = new Booking_Room__c(
      Id = secondRoom.Id,
      Room__c = room3.Id
    );

    Test.startTest();

    Database.SaveResult result =
      Database.update(roomUpdate, false);

    Test.stopTest();

    System.assertEquals(
      false,
      result.isSuccess(),
      'Changing one room to another hotel must be rejected.'
    );

    System.assert(
      result.getErrors()[0].getMessage().contains(
        'All rooms in a booking must belong to the same hotel.'
      ),
      'Unexpected error: ' + result.getErrors()[0].getMessage()
    );
  }

  @IsTest
  static void testSingleRoomCanMoveToAnotherHotel() {
    Booking__c booking = createBooking();

    Hotel__c hotel1 = createHotel('Hotel Before');
    Hotel__c hotel2 = createHotel('Hotel After');

    Room_Type__c type1 = createRoomType(
      hotel1.Id,
      'Before Type'
    );

    Room_Type__c type2 = createRoomType(
      hotel2.Id,
      'After Type'
    );

    Room__c room1 = createRoom(type1.Id, '801');
    Room__c room2 = createRoom(type2.Id, '802');

    Booking_Room__c bookingRoom =
      createBookingRoom(booking.Id, room1.Id, 1000);

    insert bookingRoom;

    // A single-room booking can change hotels.
    Booking_Room__c roomUpdate = new Booking_Room__c(
      Id = bookingRoom.Id,
      Room__c = room2.Id
    );

    Test.startTest();
    update roomUpdate;
    Test.stopTest();

    Booking_Room__c savedRoom = [
      SELECT Room__c
      FROM Booking_Room__c
      WHERE Id = :bookingRoom.Id
    ];

    System.assertEquals(
      room2.Id,
      savedRoom.Room__c
    );
  }

  // ------------------------------------------------------------
  // RELATIONSHIP DIAGNOSTIC TESTS
  // ------------------------------------------------------------

  @IsTest
  static void testRoomHotelRelationshipResolution() {
    Hotel__c hotel = createHotel(
      'Relationship Test Hotel'
    );

    Room_Type__c roomType = createRoomType(
      hotel.Id,
      'Relationship Test Type'
    );

    Room__c room = createRoom(
      roomType.Id,
      '901'
    );

    Room__c queriedRoom = [
      SELECT Id, Room_Type__r.Hotel__c
      FROM Room__c
      WHERE Id = :room.Id
    ];

    System.assertEquals(
      hotel.Id,
      queriedRoom.Room_Type__r.Hotel__c,
      'The Room to Room Type to Hotel relationship should resolve correctly.'
    );
  }

  @IsTest
  static void testHotelRelationshipInSystemMode() {
    Hotel__c hotel1 = createHotel(
      'System Mode Hotel One'
    );

    Hotel__c hotel2 = createHotel(
      'System Mode Hotel Two'
    );

    Room_Type__c type1 = createRoomType(
      hotel1.Id,
      'System Mode Type One'
    );

    Room_Type__c type2 = createRoomType(
      hotel2.Id,
      'System Mode Type Two'
    );

    Room__c room1 = createRoom(type1.Id, '911');
    Room__c room2 = createRoom(type2.Id, '912');

    Set<Id> roomIds = new Set<Id>{
      room1.Id,
      room2.Id
    };

    Map<Id, Id> hotelByRoomId = new Map<Id, Id>();

    for (Room__c room : [
      SELECT Id, Room_Type__r.Hotel__c
      FROM Room__c
      WHERE Id IN :roomIds
      WITH SYSTEM_MODE
    ]) {
      hotelByRoomId.put(
        room.Id,
        room.Room_Type__r?.Hotel__c
      );
    }

    System.assertEquals(
      hotel1.Id,
      hotelByRoomId.get(room1.Id)
    );

    System.assertEquals(
      hotel2.Id,
      hotelByRoomId.get(room2.Id)
    );

    System.assertNotEquals(
      hotelByRoomId.get(room1.Id),
      hotelByRoomId.get(room2.Id),
      'The two rooms must resolve to different hotels.'
    );
  }

  @IsTest
  static void testHandlerRejectsDifferentHotelsDirectly() {
    Booking__c booking = createBooking();

    Hotel__c hotel1 = createHotel(
      'Direct Test Hotel One'
    );

    Hotel__c hotel2 = createHotel(
      'Direct Test Hotel Two'
    );

    Room_Type__c type1 = createRoomType(
      hotel1.Id,
      'Direct Test Type One'
    );

    Room_Type__c type2 = createRoomType(
      hotel2.Id,
      'Direct Test Type Two'
    );

    Room__c room1 = createRoom(type1.Id, '921');
    Room__c room2 = createRoom(type2.Id, '922');

    List<Booking_Room__c> bookingRooms =
      new List<Booking_Room__c>{
        createBookingRoom(booking.Id, room1.Id, 1000),
        createBookingRoom(booking.Id, room2.Id, 1000)
      };

    Test.startTest();

    BookingRoomTriggerHandler.handleBeforeSave(
      bookingRooms,
      null
    );

    Test.stopTest();

    System.assertEquals(
      true,
      bookingRooms[0].hasErrors(),
      'The first room should have a validation error.'
    );

    System.assertEquals(
      true,
      bookingRooms[1].hasErrors(),
      'The second room should have a validation error.'
    );
  }

  // ------------------------------------------------------------
  // BOOKING DATE VALIDATION TEST
  // ------------------------------------------------------------

  @IsTest
  static void testInvalidBookingDatesRejected() {
    Booking__c booking = createBooking();

    booking.Check_Out_Date__c =
      booking.Check_In_Date__c;

    Test.startTest();

    try {
      update booking;

      System.assert(
        false,
        'Expected an exception due to invalid booking dates.'
      );

    } catch (DmlException e) {
      System.assert(
        e.getMessage().contains(
          'Check-out date must be later than check-in date.'
        ),
        'Unexpected error message: ' + e.getMessage()
      );
    }

    Test.stopTest();
  }
}
