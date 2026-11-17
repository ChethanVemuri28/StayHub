/**
 * @description Builds and inserts one batch scope of StayHub sample records.
 */
@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class StayHubSampleDataBatchProcessor {
  private static final String HOTEL_PREFIX = 'StayHub Sample Hotel ';
  private static final String[] CITIES = new List<String>{
    'Hyderabad',
    'Nellore',
    'Vijayawada',
    'Visakhapatnam',
    'Tirupati'
  };
  private static final String[] STREETS = new List<String>{
    'MG Road',
    'Main Road',
    'Gandhi Nagar',
    'Lake View Road',
    'Market Street'
  };
  private static final String[] TYPE_NAMES = new List<String>{
    'Standard',
    'Deluxe',
    'Suite'
  };
  private static final Decimal[] PRICES = new List<Decimal>{ 2500, 4000, 6000 };
  private static final Integer[] CAPACITY = new List<Integer>{ 2, 3, 4 };

  /**
   * @description Holds all records belonging to one generated hotel.
   */
  private class HotelBundle {
    Integer indexValue;
    Hotel__c hotel;
    List<Room_Type__c> roomTypes = new List<Room_Type__c>();
    List<Room__c> rooms = new List<Room__c>();
    List<Booking__c> bookings = new List<Booking__c>();
  }

  /**
   * @description Groups the records needed to build booking details.
   */
  private class BookingDetailsContext {
    HotelBundle bundle;
    Map<String, Rate_Plan__mdt> plans;
    List<Booking_Room__c> bookingRooms;
    List<Payment__c> payments;
  }

  /**
   * @description Groups the values needed to construct a payment.
   */
  private class PaymentBuildContext {
    Integer hotelIndex;
    Integer sequence;
    Booking__c booking;
    Decimal nightlyRate;
    Integer nights;
  }

  /**
   * @description Processes one batch scope and inserts its related records.
   * @param indexes Hotel indexes supplied by the batch framework.
   */
  public static void process(List<Integer> indexes) {
    if (indexes == null || indexes.isEmpty()) {
      return;
    }

    StayHubSampleDataFactory.ReferenceData references = StayHubSampleDataFactory.validateReferenceData();
    List<HotelBundle> bundles = createNewHotelBundles(
      indexes,
      references.partnerAccount
    );
    if (bundles.isEmpty()) {
      return;
    }

    insertHotels(bundles);
    insertRoomTypes(bundles);
    insertRooms(bundles);
    insertBookings(bundles, references.guestContact);
    insertBookingRoomsAndPayments(bundles, references.ratePlans);
    insertReviews(bundles, references.guestContact);
  }

  private static List<HotelBundle> createNewHotelBundles(
    List<Integer> indexes,
    Account partner
  ) {
    Set<String> requestedNames = new Set<String>();
    for (Integer indexValue : indexes) {
      requestedNames.add(hotelName(indexValue));
    }
    Set<String> existingNames = findExistingHotelNames(requestedNames);
    List<HotelBundle> bundles = new List<HotelBundle>();
    for (Integer indexValue : indexes) {
      if (!existingNames.contains(hotelName(indexValue))) {
        bundles.add(buildHotelBundle(indexValue, partner));
      }
    }
    return bundles;
  }

  private static Set<String> findExistingHotelNames(Set<String> names) {
    Set<String> existingNames = new Set<String>();
    for (Hotel__c hotel : [SELECT Name FROM Hotel__c WHERE Name IN :names]) {
      existingNames.add(hotel.Name);
    }
    return existingNames;
  }

  private static HotelBundle buildHotelBundle(
    Integer indexValue,
    Account partner
  ) {
    Integer cityIndex = Math.mod(indexValue, CITIES.size());
    HotelBundle bundle = new HotelBundle();
    bundle.indexValue = indexValue;
    bundle.hotel = new Hotel__c(
      Name = hotelName(indexValue),
      City__c = CITIES[cityIndex],
      State__c = 'Andhra Pradesh',
      Country__c = 'India',
      Street__c = String.valueOf(100 + Math.mod(indexValue, 900)) +
        ' ' +
        STREETS[cityIndex],
      Partner_Account__c = partner.Id,
      Status__c = 'Active'
    );
    return bundle;
  }

  private static void insertHotels(List<HotelBundle> bundles) {
    List<Hotel__c> hotels = new List<Hotel__c>();
    for (HotelBundle bundle : bundles) {
      hotels.add(bundle.hotel);
    }
    insert hotels;
  }

  private static void insertRoomTypes(List<HotelBundle> bundles) {
    List<Room_Type__c> records = new List<Room_Type__c>();
    for (HotelBundle bundle : bundles) {
      for (Integer typeIndex = 0; typeIndex < TYPE_NAMES.size(); typeIndex++) {
        Room_Type__c roomType = new Room_Type__c(
          Name = TYPE_NAMES[typeIndex],
          Hotel__c = bundle.hotel.Id,
          Base_Price__c = PRICES[typeIndex],
          Max_Occupancy__c = CAPACITY[typeIndex],
          Status__c = 'Active'
        );
        bundle.roomTypes.add(roomType);
        records.add(roomType);
      }
    }
    insert records;
  }

  private static void insertRooms(List<HotelBundle> bundles) {
    List<Room__c> records = new List<Room__c>();
    for (HotelBundle bundle : bundles) {
      addBundleRooms(bundle, records);
    }
    insert records;
  }

  private static void addBundleRooms(
    HotelBundle bundle,
    List<Room__c> records
  ) {
    for (Integer typeIndex = 0; typeIndex < TYPE_NAMES.size(); typeIndex++) {
      String roomCode = StayHubSampleDataBatchRules.roomCodeFor(typeIndex);
      for (Integer roomIndex = 1; roomIndex <= 5; roomIndex++) {
        String roomNumber =
          roomCode +
          '-' +
          String.valueOf(roomIndex).leftPad(3, '0');
        Room__c room = new Room__c(
          Name = roomNumber,
          Room_Type__c = bundle.roomTypes[typeIndex].Id,
          Room_Number__c = roomNumber,
          Status__c = 'Available'
        );
        bundle.rooms.add(room);
        records.add(room);
      }
    }
  }

  private static void insertBookings(List<HotelBundle> bundles, Contact guest) {
    List<Booking__c> records = new List<Booking__c>();
    for (HotelBundle bundle : bundles) {
      addBundleBookings(bundle, guest, records);
    }
    insert records;
  }

  private static void addBundleBookings(
    HotelBundle bundle,
    Contact guest,
    List<Booking__c> records
  ) {
    for (Integer sequence = 0; sequence < 5; sequence++) {
      Integer globalIndex = bundle.indexValue * 5 + sequence;
      String bookingStatus = StayHubSampleDataBatchRules.statusFor(globalIndex);
      Date checkInDate = StayHubSampleDataBatchRules.checkInFor(
        bookingStatus,
        globalIndex
      );
      Booking__c booking = new Booking__c(
        Guest__c = guest.Id,
        Booking_Date__c = System.now().addMinutes(globalIndex),
        Check_In_Date__c = checkInDate,
        Check_Out_Date__c = checkInDate.addDays(2),
        Number_of_Adults__c = 1,
        Status__c = bookingStatus,
        Special_Requests__c = 'Generated sample booking ' +
          String.valueOf(globalIndex + 1)
      );
      bundle.bookings.add(booking);
      records.add(booking);
    }
  }

  private static void insertBookingRoomsAndPayments(
    List<HotelBundle> bundles,
    Map<String, Rate_Plan__mdt> plans
  ) {
    List<Booking_Room__c> bookingRooms = new List<Booking_Room__c>();
    List<Payment__c> payments = new List<Payment__c>();
    for (HotelBundle bundle : bundles) {
      BookingDetailsContext context = new BookingDetailsContext();
      context.bundle = bundle;
      context.plans = plans;
      context.bookingRooms = bookingRooms;
      context.payments = payments;
      addBundleBookingDetails(context);
    }
    insert bookingRooms;
    upsert payments Payment__c.Transaction_Reference__c;
  }

  private static void addBundleBookingDetails(BookingDetailsContext context) {
    for (Integer sequence = 0; sequence < 5; sequence++) {
      Booking__c booking = context.bundle.bookings[sequence];
      Integer typeIndex = Math.mod(sequence, TYPE_NAMES.size());
      Room__c room = context.bundle.rooms[(typeIndex * 5) + sequence];
      Decimal nightlyRate =
        PRICES[typeIndex] *
        StayHubSampleDataBatchRules.rateMultiplier(
          booking.Check_In_Date__c,
          context.plans
        );
      Integer nights = booking.Check_In_Date__c.daysBetween(
        booking.Check_Out_Date__c
      );
      context.bookingRooms.add(buildBookingRoom(booking, room, nightlyRate));

      PaymentBuildContext paymentContext = new PaymentBuildContext();
      paymentContext.hotelIndex = context.bundle.indexValue;
      paymentContext.sequence = sequence;
      paymentContext.booking = booking;
      paymentContext.nightlyRate = nightlyRate;
      paymentContext.nights = nights;
      context.payments.add(buildPayment(paymentContext));
    }
  }

  private static Booking_Room__c buildBookingRoom(
    Booking__c booking,
    Room__c room,
    Decimal nightlyRate
  ) {
    return new Booking_Room__c(
      Booking__c = booking.Id,
      Room__c = room.Id,
      Adults__c = 1,
      Nightly_Rate__c = nightlyRate
    );
  }

  private static Payment__c buildPayment(PaymentBuildContext context) {
    Boolean cancelled = context.booking.Status__c == 'Cancelled';
    String paymentStatus = context.booking.Status__c == 'Inquiry'
      ? 'Initiated'
      : (cancelled ? 'Refunded' : 'Successful');
    return new Payment__c(
      Booking__c = context.booking.Id,
      Amount__c = context.nightlyRate * context.nights,
      Payment_Date__c = System.now(),
      Payment_Method__c = StayHubSampleDataBatchRules.paymentMethodFor(
        context.hotelIndex,
        context.sequence
      ),
      Payment_Status__c = paymentStatus,
      Payment_Type__c = cancelled ? 'Refund' : 'Payment',
      Transaction_Reference__c = 'SH-SAMPLE-PAY-' +
        String.valueOf((context.hotelIndex * 5) + context.sequence + 1)
    );
  }

  private static void insertReviews(List<HotelBundle> bundles, Contact guest) {
    List<Review__c> records = new List<Review__c>();
    for (HotelBundle bundle : bundles) {
      for (Integer reviewIndex = 0; reviewIndex < 3; reviewIndex++) {
        records.add(
          new Review__c(
            Hotel__c = bundle.hotel.Id,
            Guest__c = guest.Id,
            Rating__c = 3 + reviewIndex,
            Comments__c = 'Generated sample review ' +
              String.valueOf((bundle.indexValue * 3) + reviewIndex + 1),
            Review_Date__c = System.now()
              .addMinutes((bundle.indexValue * 3) + reviewIndex),
            Status__c = 'Published'
          )
        );
      }
    }
    insert records;
  }

  private static String hotelName(Integer indexValue) {
    return HOTEL_PREFIX + String.valueOf(indexValue + 1).leftPad(5, '0');
  }
}
