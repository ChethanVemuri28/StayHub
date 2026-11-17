public with sharing class StayHubSampleDataGenerator implements Database.Batchable<Integer> {
  private Integer hotelCount;

  private static final Integer SCOPE_SIZE = 10;
  private static final String PREFIX = 'StayHub Sample Hotel ';

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

  private static final String[] METHODS = new List<String>{
    'Card',
    'UPI',
    'Net Banking',
    'Cash',
    'Wallet'
  };

  private class Bundle {
    Integer n;
    Hotel__c hotel;
    List<Room_Type__c> types = new List<Room_Type__c>();
    List<Room__c> rooms = new List<Room__c>();
    List<Booking__c> bookings = new List<Booking__c>();
  }

  public StayHubSampleDataGenerator(Integer count) {
    if (count == null || count < 1 || count > 50000) {
      throw new IllegalArgumentException(
        'Hotel count must be between 1 and 50000.'
      );
    }

    hotelCount = count;
  }

  public static Id launch(Integer count) {
    return Database.executeBatch(
      new StayHubSampleDataGenerator(count),
      SCOPE_SIZE
    );
  }

  public static Integer expectedRecordCount(Integer count) {
    if (count == null || count < 0) {
      throw new IllegalArgumentException('Hotel count cannot be negative.');
    }

    return count * 37;
  }

  public Iterable<Integer> start(Database.BatchableContext bc) {
    List<Integer> indexes = new List<Integer>();

    for (Integer i = 0; i < hotelCount; i++) {
      indexes.add(i);
    }

    return indexes;
  }

  public void execute(Database.BatchableContext bc, List<Integer> scope) {
    if (scope.isEmpty()) {
      return;
    }

    StayHubSampleDataFactory.ReferenceData referenceData = StayHubSampleDataFactory.validateReferenceData();

    Account partner = referenceData.partnerAccount;
    Contact guest = referenceData.guestContact;
    Map<String, Rate_Plan__mdt> plans = referenceData.ratePlans;

    Set<String> names = new Set<String>();

    for (Integer n : scope) {
      names.add(hotelName(n));
    }

    Set<String> existing = new Set<String>();

    for (Hotel__c h : [
      SELECT Name
      FROM Hotel__c
      WHERE Name IN :names
    ]) {
      existing.add(h.Name);
    }

    List<Bundle> bundles = new List<Bundle>();
    List<Hotel__c> hotels = new List<Hotel__c>();

    for (Integer n : scope) {
      if (existing.contains(hotelName(n))) {
        continue;
      }

      Integer c = Math.mod(n, CITIES.size());
      Bundle b = new Bundle();
      b.n = n;

      b.hotel = new Hotel__c(
        Name = hotelName(n),
        City__c = CITIES[c],
        State__c = 'Andhra Pradesh',
        Country__c = 'India',
        Street__c = String.valueOf(100 + Math.mod(n, 900)) + ' ' + STREETS[c],
        Partner_Account__c = partner.Id,
        Status__c = 'Active'
      );

      bundles.add(b);
      hotels.add(b.hotel);
    }

    if (bundles.isEmpty()) {
      return;
    }

    insert hotels;

    List<Room_Type__c> typesToInsert = new List<Room_Type__c>();

    for (Bundle b : bundles) {
      for (Integer t = 0; t < 3; t++) {
        Room_Type__c rt = new Room_Type__c(
          Name = TYPE_NAMES[t],
          Hotel__c = b.hotel.Id,
          Base_Price__c = PRICES[t],
          Max_Occupancy__c = CAPACITY[t],
          Status__c = 'Active'
        );

        b.types.add(rt);
        typesToInsert.add(rt);
      }
    }

    insert typesToInsert;

    List<Room__c> roomsToInsert = new List<Room__c>();

    for (Bundle b : bundles) {
      for (Integer t = 0; t < 3; t++) {
        String code = t == 0 ? 'STD' : (t == 1 ? 'DLX' : 'STE');

        for (Integer r = 1; r <= 5; r++) {
          String roomNumber = code + '-' + String.valueOf(r).leftPad(3, '0');

          Room__c room = new Room__c(
            Name = roomNumber,
            Room_Type__c = b.types[t].Id,
            Room_Number__c = roomNumber,
            Status__c = 'Available'
          );

          b.rooms.add(room);
          roomsToInsert.add(room);
        }
      }
    }

    insert roomsToInsert;

    List<Booking__c> bookingsToInsert = new List<Booking__c>();

    for (Bundle b : bundles) {
      for (Integer s = 0; s < 5; s++) {
        Integer globalIndex = b.n * 5 + s;
        String status = statusFor(globalIndex);
        Date checkIn = checkInFor(status, globalIndex);

        Booking__c booking = new Booking__c(
          Guest__c = guest.Id,
          Booking_Date__c = System.now().addMinutes(globalIndex),
          Check_In_Date__c = checkIn,
          Check_Out_Date__c = checkIn.addDays(2),
          Number_of_Adults__c = 1,
          Status__c = status,
          Special_Requests__c = 'Generated sample booking ' +
            String.valueOf(globalIndex + 1)
        );

        b.bookings.add(booking);
        bookingsToInsert.add(booking);
      }
    }

    insert bookingsToInsert;

    List<Booking_Room__c> bookingRooms = new List<Booking_Room__c>();

    List<Payment__c> payments = new List<Payment__c>();

    for (Bundle b : bundles) {
      for (Integer s = 0; s < 5; s++) {
        Booking__c booking = b.bookings[s];
        Integer typeIndex = Math.mod(s, 3);
        Room__c room = b.rooms[(typeIndex * 5) + s];

        Decimal nightly =
          PRICES[typeIndex] * rateMultiplier(booking.Check_In_Date__c, plans);

        Integer nights = booking.Check_In_Date__c.daysBetween(
          booking.Check_Out_Date__c
        );

        bookingRooms.add(
          new Booking_Room__c(
            Booking__c = booking.Id,
            Room__c = room.Id,
            Adults__c = 1,
            Nightly_Rate__c = nightly
          )
        );

        Boolean cancelled = booking.Status__c == 'Cancelled';

        payments.add(
          new Payment__c(
            Booking__c = booking.Id,
            Amount__c = nightly * nights,
            Payment_Date__c = System.now(),
            Payment_Method__c = METHODS[Math.mod(b.n + s, METHODS.size())],
            Payment_Status__c = booking.Status__c == 'Inquiry'
              ? 'Initiated'
              : (cancelled ? 'Refunded' : 'Successful'),
            Payment_Type__c = cancelled ? 'Refund' : 'Payment',
            Transaction_Reference__c = 'SH-SAMPLE-PAY-' +
              String.valueOf((b.n * 5) + s + 1)
          )
        );
      }
    }

    insert bookingRooms;
    upsert payments Payment__c.Transaction_Reference__c;

    List<Review__c> reviews = new List<Review__c>();

    for (Bundle b : bundles) {
      for (Integer r = 0; r < 3; r++) {
        reviews.add(
          new Review__c(
            Hotel__c = b.hotel.Id,
            Guest__c = guest.Id,
            Rating__c = 3 + r,
            Comments__c = 'Generated sample review ' +
              String.valueOf((b.n * 3) + r + 1),
            Review_Date__c = System.now().addMinutes((b.n * 3) + r),
            Status__c = 'Published'
          )
        );
      }
    }

    insert reviews;
  }

  public void finish(Database.BatchableContext bc) {
    // No post-processing is required.
  }

  private static String hotelName(Integer n) {
    return PREFIX + String.valueOf(n + 1).leftPad(5, '0');
  }

  private static String statusFor(Integer n) {
    Integer p = Math.mod(n, 20);

    if (p < 4) {
      return 'Inquiry';
    }

    if (p < 10) {
      return 'Confirmed';
    }

    if (p < 13) {
      return 'Checked-in';
    }

    if (p < 18) {
      return 'Completed';
    }

    return 'Cancelled';
  }

  private static Date checkInFor(String status, Integer n) {
    if (status == 'Completed') {
      return Date.today().addDays(-35 + Math.mod(n, 10));
    }

    if (status == 'Checked-in') {
      return Date.today().addDays(-1);
    }

    if (status == 'Cancelled') {
      return Date.today().addDays(60 + Math.mod(n, 20));
    }

    return Date.today().addDays(30 + Math.mod(n, 45));
  }

  private static Decimal rateMultiplier(
    Date d,
    Map<String, Rate_Plan__mdt> plans
  ) {
    for (Rate_Plan__mdt p : plans.values()) {
      if (
        p.Start_Date__c != null &&
        p.End_Date__c != null &&
        d >= p.Start_Date__c &&
        d <= p.End_Date__c &&
        p.Rate_Multiplier__c != null
      ) {
        return p.Rate_Multiplier__c;
      }
    }

    return 1.0;
  }
}
