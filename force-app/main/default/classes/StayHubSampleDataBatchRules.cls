/**
 * @description Provides reusable rules for StayHub sample data generation.
 */
public with sharing class StayHubSampleDataBatchRules {
  private static final String[] PAYMENT_METHODS = new List<String>{
    'Card',
    'UPI',
    'Net Banking',
    'Cash',
    'Wallet'
  };

  /**
   * @description Returns the room-code prefix for a room type.
   * @param typeIndex Index of the room type.
   * @return Room-code prefix.
   */
  public static String roomCodeFor(Integer typeIndex) {
    if (typeIndex == 0) {
      return 'STD';
    }
    if (typeIndex == 1) {
      return 'DLX';
    }
    return 'STE';
  }

  /**
   * @description Returns the generated booking status for an index.
   * @param indexValue Global booking index.
   * @return Booking status.
   */
  public static String statusFor(Integer indexValue) {
    Integer position = Math.mod(indexValue, 20);
    if (position < 4) {
      return 'Inquiry';
    }
    if (position < 10) {
      return 'Confirmed';
    }
    if (position < 13) {
      return 'Checked-in';
    }
    if (position < 18) {
      return 'Completed';
    }
    return 'Cancelled';
  }

  /**
   * @description Calculates the check-in date for a generated booking.
   * @param bookingStatus Status of the booking.
   * @param indexValue Global booking index.
   * @return Check-in date.
   */
  public static Date checkInFor(String bookingStatus, Integer indexValue) {
    if (bookingStatus == 'Completed') {
      return Date.today().addDays(-35 + Math.mod(indexValue, 10));
    }
    if (bookingStatus == 'Checked-in') {
      return Date.today().addDays(-1);
    }
    if (bookingStatus == 'Cancelled') {
      return Date.today().addDays(60 + Math.mod(indexValue, 20));
    }
    return Date.today().addDays(30 + Math.mod(indexValue, 45));
  }

  /**
   * @description Finds the rate multiplier applicable to a check-in date.
   * @param checkInDate Booking check-in date.
   * @param plans Available rate plans.
   * @return Applicable multiplier, or 1.0 if no plan matches.
   */
  public static Decimal rateMultiplier(
    Date checkInDate,
    Map<String, Rate_Plan__mdt> plans
  ) {
    for (Rate_Plan__mdt plan : plans.values()) {
      if (isPlanApplicable(plan, checkInDate)) {
        return plan.Rate_Multiplier__c;
      }
    }
    return 1.0;
  }

  /**
   * @description Returns the payment method for a generated booking.
   * @param hotelIndex Global hotel index.
   * @param sequence Booking sequence within the hotel.
   * @return Payment method.
   */
  public static String paymentMethodFor(Integer hotelIndex, Integer sequence) {
    return PAYMENT_METHODS[
      Math.mod(hotelIndex + sequence, PAYMENT_METHODS.size())
    ];
  }

  private static Boolean isPlanApplicable(
    Rate_Plan__mdt plan,
    Date checkInDate
  ) {
    return plan.Start_Date__c != null &&
      plan.End_Date__c != null &&
      checkInDate >= plan.Start_Date__c &&
      checkInDate <= plan.End_Date__c &&
      plan.Rate_Multiplier__c != null;
  }
}