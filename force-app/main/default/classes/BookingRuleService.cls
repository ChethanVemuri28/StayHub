/**
 * @description Reads global booking rules from Custom Metadata
 * and calculates temporary Inquiry expiry timestamps.
 */
public inherited sharing class BookingRuleService {
  /**
   * @description Retrieves the configured Inquiry hold duration.
   * @return The configured hold duration in hours.
   * @throws BookingRuleConfigurationException When the configuration is
   * missing or the configured duration is invalid.
   */
  public static Integer getInquiryHoldHours() {
    Booking_Rule__mdt rule = Booking_Rule__mdt.getInstance('Default');

    if (rule == null || rule.Inquiry_Hold_Hours__c == null) {
      throw new BookingRuleConfigurationException(
        'Default booking rule or Inquiry hold duration is missing.'
      );
    }

    Integer hours = rule.Inquiry_Hold_Hours__c.intValue();

    if (hours <= 0) {
      throw new BookingRuleConfigurationException(
        'Inquiry hold duration must be greater than zero.'
      );
    }

    return hours;
  }

  /**
   * @description Calculates the expiry timestamp using the configured hold duration.
   * @param startTime The date and time when the Inquiry hold begins.
   * @return The calculated Inquiry expiry timestamp.
   * @throws BookingRuleConfigurationException When startTime is null
   * or the booking rule configuration is invalid.
   */
  public static Datetime calculateInquiryExpiry(Datetime startTime) {
    if (startTime == null) {
      throw new BookingRuleConfigurationException(
        'Inquiry hold start time cannot be null.'
      );
    }

    return startTime.addHours(getInquiryHoldHours());
  }

  /**
   * @description Exception raised when booking-rule configuration is invalid.
   */
  public class BookingRuleConfigurationException extends Exception {
  }
}
