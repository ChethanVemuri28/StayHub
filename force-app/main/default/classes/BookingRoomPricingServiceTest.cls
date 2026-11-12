@IsTest
private class BookingRoomPricingServiceTest {
  @TestSetup
  static void setupData() {
    Account partner = new Account(Name = 'StayHub Test Partner');
    insert partner;

    Contact guest = new Contact(
      FirstName = 'Test',
      LastName = 'Guest',
      AccountId = partner.Id
    );
    insert guest;
  }

  private static User getRunningUser() {
    return [
      SELECT Id
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ];
  }

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

  private static Room__c createRoom(String roomNumber) {
    Account partner = [
      SELECT Id
      FROM Account
      WHERE Name = 'StayHub Test Partner'
      LIMIT 1
    ];

    Hotel__c hotel = new Hotel__c(
      Name = 'Test Hotel ' + roomNumber,
      Partner_Account__c = partner.Id,
      Street__c = '1 Test Street',
      City__c = 'Nellore',
      State__c = 'Andhra Pradesh',
      Country__c = 'India',
      Status__c = 'Active'
    );
    insert hotel;

    Room_Type__c roomType = new Room_Type__c(
      Name = 'Standard ' + roomNumber,
      Hotel__c = hotel.Id,
      Base_Price__c = 1000,
      Max_Occupancy__c = 2,
      Status__c = 'Active'
    );
    insert roomType;

    Room__c room = new Room__c(
      Name = 'Test Room ' + roomNumber,
      Room_Number__c = roomNumber,
      Room_Type__c = roomType.Id,
      Status__c = 'Available'
    );
    insert room;
    return room;
  }

  @IsTest
  static void testInitialNightCalculationAndRollup() {
    User runningUser = getRunningUser();

    System.runAs(runningUser) {
      Booking__c booking = createBooking();
      Room__c room = createRoom('101');

      Booking_Room__c bookingRoom = new Booking_Room__c(
        Booking__c = booking.Id,
        Room__c = room.Id,
        Adults__c = 2,
        Nightly_Rate__c = 1000
      );

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
        bookingRoom.Nights_for_Pricing__c,
        'The nights for pricing should be calculated correctly.'
      );
      System.assertEquals(
        Decimal.valueOf('3000'),
        bookingRoom.Room_Total__c,
        'The room total should be calculated correctly.'
      );
      System.assertEquals(
        Decimal.valueOf('3000'),
        booking.Total_Amount__c,
        'The total amount on the booking should reflect the room total.'
      );
    }
  }

  @IsTest
  static void testBookingDateChangeRecalculatesRooms() {
    User runningUser = getRunningUser();

    System.runAs(runningUser) {
      Booking__c booking = createBooking();
      Room__c room = createRoom('201');

      Booking_Room__c bookingRoom = new Booking_Room__c(
        Booking__c = booking.Id,
        Room__c = room.Id,
        Adults__c = 2,
        Nightly_Rate__c = 1000
      );
      insert bookingRoom;

      booking.Check_Out_Date__c = Date.newInstance(2026, 11, 15);

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
        bookingRoom.Nights_for_Pricing__c,
        'The nights for pricing should be recalculated correctly.'
      );
      System.assertEquals(
        Decimal.valueOf('5000'),
        bookingRoom.Room_Total__c,
        'The room total should be recalculated correctly.'
      );
      System.assertEquals(
        Decimal.valueOf('5000'),
        booking.Total_Amount__c,
        'The total amount on the booking should reflect the updated room total.'
      );
    }
  }

  @IsTest
  static void testBulkRoomCalculationAndRollup() {
    User runningUser = getRunningUser();

    System.runAs(runningUser) {
      Booking__c booking = createBooking();
      Room__c room1 = createRoom('301');
      Room__c room2 = createRoom('302');

      List<Booking_Room__c> bookingRooms = new List<Booking_Room__c>{
        new Booking_Room__c(
          Booking__c = booking.Id,
          Room__c = room1.Id,
          Adults__c = 2,
          Nightly_Rate__c = 1000
        ),
        new Booking_Room__c(
          Booking__c = booking.Id,
          Room__c = room2.Id,
          Adults__c = 2,
          Nightly_Rate__c = 1200
        )
      };

      Test.startTest();
      insert bookingRooms;
      Test.stopTest();

      bookingRooms = [
        SELECT Nights_for_Pricing__c, Room_Total__c
        FROM Booking_Room__c
        WHERE Booking__c = :booking.Id
      ];

      booking = [
        SELECT Total_Amount__c
        FROM Booking__c
        WHERE Id = :booking.Id
      ];

      System.assertEquals(
        Decimal.valueOf('6600'),
        booking.Total_Amount__c,
        'The total amount on the booking should reflect the sum of both room totals.'
      );

      for (Booking_Room__c room : [
        SELECT Nights_for_Pricing__c, Room_Total__c
        FROM Booking_Room__c
        WHERE Booking__c = :booking.Id
      ]) {
        System.assertEquals(
          Decimal.valueOf('3'),
          room.Nights_for_Pricing__c,
          'Each room should have the correct number of nights calculated.'
        );
        System.assertNotEquals(null, room.Room_Total__c);
      }
    }
  }

  @IsTest
  static void testInvalidBookingDatesRejected() {
    User runningUser = getRunningUser();

    System.runAs(runningUser) {
      Booking__c booking = createBooking();
      booking.Check_Out_Date__c = booking.Check_In_Date__c;

      Test.startTest();
      try {
        update booking;
        System.assert(
          false,
          'Expected an exception due to invalid booking dates.'
        );
      } catch (DmlException e) {
        System.assert(
          e.getMessage()
            .contains('Check-out date must be later than check-in date.'),
          'Unexpected error message: ' + e.getMessage()
        );
      }
      Test.stopTest();
    }
  }
}
