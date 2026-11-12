/**
 * @description Reads global booking rules from Custom Metadata.
 */
public inherited sharing class BookingRuleService {

    public static Integer getInquiryHoldHours() {
        Booking_Rule__mdt rule =
            Booking_Rule__mdt.getInstance('Default');

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

    public static Datetime calculateInquiryExpiry(Datetime startTime) {
        if (startTime == null) {
            throw new BookingRuleConfigurationException(
                'Inquiry hold start time cannot be null.'
            );
        }

        return startTime.addHours(getInquiryHoldHours());
    }

    public class BookingRuleConfigurationException extends Exception {}
}