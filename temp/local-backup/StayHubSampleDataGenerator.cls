
public with sharing class StayHubSampleDataGenerator {

    public class GenerationPlan {

        public Integer hotels = 200;
        public Integer roomTypes = 600;
        public Integer rooms = 3000;
        public Integer bookings = 1000;
        public Integer bookingRooms = 1000;
        public Integer payments = 1000;
        public Integer reviews = 600;

        // Recommended Batch Apex scope size.
        public Integer batchSize = 200;

        // Requirement 16: 200 hotels.
        public static GenerationPlan requirement16() {
            return forHotelCount(200);
        }

        // Requirement 17: 50,000 hotels.
        public static GenerationPlan requirement17() {
            return forHotelCount(50000);
        }

        // Reusable configuration for any hotel count.
        public static GenerationPlan forHotelCount(
            Integer hotelCount
        ) {
            if (hotelCount == null || hotelCount <= 0) {
                throw new IllegalArgumentException(
                    'Hotel count must be greater than zero.'
                );
            }

            GenerationPlan plan = new GenerationPlan();

            plan.hotels = hotelCount;
            plan.roomTypes = hotelCount * 3;
            plan.rooms = hotelCount * 15;
            plan.bookings = hotelCount * 5;
            plan.bookingRooms = hotelCount * 5;
            plan.payments = hotelCount * 5;
            plan.reviews = hotelCount * 3;

            return plan;
        }

        public Integer totalRecords() {
            return hotels +
                   roomTypes +
                   rooms +
                   bookings +
                   bookingRooms +
                   payments +
                   reviews;
        }
    }

    // Existing production dry-run entry point.
    public static void runDryRun() {
        runDryRun(
            StayHubSampleDataFactory.PARTNER_ACCOUNT_ID,
            StayHubSampleDataFactory.GUEST_CONTACT_ID,
            null
        );
    }

    // Existing testable dry-run entry point.
    public static void runDryRun(
        Id partnerAccountId,
        Id guestContactId,
        Map<String, Rate_Plan__mdt> suppliedRatePlans
    ) {
        System.debug('================================');
        System.debug('STAYHUB DATA GENERATOR - DRY RUN');
        System.debug('================================');

        StayHubSampleDataFactory.ReferenceData references;

        if (suppliedRatePlans == null) {
            references =
                StayHubSampleDataFactory.validateReferenceData(
                    partnerAccountId,
                    guestContactId
                );
        } else {
            references =
                StayHubSampleDataFactory.validateReferenceData(
                    partnerAccountId,
                    guestContactId,
                    suppliedRatePlans
                );
        }

        System.debug(
            'Partner Account: ' +
            references.partnerAccount.Name
        );

        System.debug(
            'Guest Contact: ' +
            references.guestContact.Name
        );

        System.debug(
            'Rate Plans verified: ' +
            references.ratePlans.size()
        );

        GenerationPlan plan = GenerationPlan.requirement16();

        System.debug('--- PLANNED RECORD COUNTS ---');
        System.debug('Hotels: ' + plan.hotels);
        System.debug('Room Types: ' + plan.roomTypes);
        System.debug('Rooms: ' + plan.rooms);
        System.debug('Bookings: ' + plan.bookings);
        System.debug('Booking Rooms: ' + plan.bookingRooms);
        System.debug('Payments: ' + plan.payments);
        System.debug('Reviews: ' + plan.reviews);

        System.debug(
            'TOTAL PLANNED RECORDS: ' +
            plan.totalRecords()
        );

        System.debug(
            'DRY RUN COMPLETE - NO RECORDS INSERTED.'
        );
    }
}
