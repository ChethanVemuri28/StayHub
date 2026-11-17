
@IsTest
private class StayHubSampleDataGeneratorTest {

    @TestSetup
    static void setupData() {
        Account account = new Account(
            Name = 'StayHub Generator Test Partner'
        );
        insert account;

        Contact guest = new Contact(
            FirstName = 'Generator',
            LastName = 'Test Guest',
            AccountId = account.Id
        );
        insert guest;
    }

    private static Account getTestAccount() {
        return [
            SELECT Id, Name
            FROM Account
            WHERE Name = 'StayHub Generator Test Partner'
            LIMIT 1
        ];
    }

    private static Contact getTestContact() {
        return [
            SELECT Id, Name, AccountId
            FROM Contact
            WHERE LastName = 'Test Guest'
            LIMIT 1
        ];
    }

    private static Map<String, Rate_Plan__mdt> getTestRatePlans() {
        return new Map<String, Rate_Plan__mdt>{
            'Low_Season' => new Rate_Plan__mdt(
                DeveloperName = 'Low_Season'
            ),
            'Shoulder_Season' => new Rate_Plan__mdt(
                DeveloperName = 'Shoulder_Season'
            ),
            'Peak_Season' => new Rate_Plan__mdt(
                DeveloperName = 'Peak_Season'
            )
        };
    }

    @IsTest
    static void testReferenceDataValidation() {
        Account account = getTestAccount();
        Contact guest = getTestContact();

        StayHubSampleDataFactory.ReferenceData references =
            StayHubSampleDataFactory.validateReferenceData(
                account.Id,
                guest.Id,
                getTestRatePlans()
            );

        System.assertEquals(
            account.Id,
            references.partnerAccount.Id
        );

        System.assertEquals(
            guest.Id,
            references.guestContact.Id
        );

        System.assertEquals(
            3,
            references.ratePlans.size()
        );
    }

    @IsTest
    static void testMissingPartnerAccount() {
        Contact guest = getTestContact();

        try {
            StayHubSampleDataFactory.validateReferenceData(
                null,
                guest.Id,
                getTestRatePlans()
            );

            System.assert(false, 'Expected missing Account error.');
        } catch (IllegalArgumentException ex) {
            System.assert(
                ex.getMessage().contains(
                    'Partner Account ID is required'
                )
            );
        }
    }

    @IsTest
    static void testMissingGuestContact() {
        Account account = getTestAccount();

        try {
            StayHubSampleDataFactory.validateReferenceData(
                account.Id,
                null,
                getTestRatePlans()
            );

            System.assert(false, 'Expected missing Contact error.');
        } catch (IllegalArgumentException ex) {
            System.assert(
                ex.getMessage().contains(
                    'Guest Contact ID is required'
                )
            );
        }
    }

    @IsTest
    static void testMissingRatePlan() {
        Account account = getTestAccount();
        Contact guest = getTestContact();

        try {
            StayHubSampleDataFactory.validateReferenceData(
                account.Id,
                guest.Id,
                new Map<String, Rate_Plan__mdt>()
            );

            System.assert(false, 'Expected missing Rate Plan error.');
        } catch (IllegalArgumentException ex) {
            System.assert(
                ex.getMessage().contains(
                    'Rate Plan records are missing'
                )
            );
        }
    }

    @IsTest
    static void testDryRunDoesNotInsertRecords() {
        Account account = getTestAccount();
        Contact guest = getTestContact();

        Integer dmlRowsBefore = Limits.getDmlRows();

        Test.startTest();

        StayHubSampleDataGenerator.runDryRun(
            account.Id,
            guest.Id,
            getTestRatePlans()
        );

        Test.stopTest();

        System.assertEquals(
            dmlRowsBefore,
            Limits.getDmlRows(),
            'Dry-run must not perform DML.'
        );
    }

    @IsTest
    static void testGenerationPlanTotal() {
        StayHubSampleDataGenerator.GenerationPlan plan =
            new StayHubSampleDataGenerator.GenerationPlan();

        System.assertEquals(200, plan.hotels);
        System.assertEquals(600, plan.roomTypes);
        System.assertEquals(3000, plan.rooms);
        System.assertEquals(1000, plan.bookings);
        System.assertEquals(1000, plan.bookingRooms);
        System.assertEquals(1000, plan.payments);
        System.assertEquals(600, plan.reviews);

        System.assertEquals(7400, plan.totalRecords());
    }

    @IsTest
    static void testRequirement16Plan() {
        StayHubSampleDataGenerator.GenerationPlan plan =
            StayHubSampleDataGenerator.GenerationPlan.requirement16();

        System.assertEquals(200, plan.hotels);
        System.assertEquals(600, plan.roomTypes);
        System.assertEquals(3000, plan.rooms);
        System.assertEquals(1000, plan.bookings);
        System.assertEquals(1000, plan.bookingRooms);
        System.assertEquals(1000, plan.payments);
        System.assertEquals(600, plan.reviews);

        System.assertEquals(7400, plan.totalRecords());
    }

    @IsTest
    static void testRequirement17Plan() {
        StayHubSampleDataGenerator.GenerationPlan plan =
            StayHubSampleDataGenerator.GenerationPlan.requirement17();

        System.assertEquals(50000, plan.hotels);
        System.assertEquals(150000, plan.roomTypes);
        System.assertEquals(750000, plan.rooms);
        System.assertEquals(250000, plan.bookings);
        System.assertEquals(250000, plan.bookingRooms);
        System.assertEquals(250000, plan.payments);
        System.assertEquals(150000, plan.reviews);

        System.assertEquals(1850000, plan.totalRecords());
    }

    @IsTest
    static void testCustomHotelCountPlan() {
        StayHubSampleDataGenerator.GenerationPlan plan =
            StayHubSampleDataGenerator.GenerationPlan.forHotelCount(100);

        System.assertEquals(100, plan.hotels);
        System.assertEquals(300, plan.roomTypes);
        System.assertEquals(1500, plan.rooms);
        System.assertEquals(500, plan.bookings);
        System.assertEquals(500, plan.bookingRooms);
        System.assertEquals(500, plan.payments);
        System.assertEquals(300, plan.reviews);

        System.assertEquals(3700, plan.totalRecords());
    }

    @IsTest
    static void testInvalidHotelCount() {
        try {
            StayHubSampleDataGenerator.GenerationPlan.forHotelCount(0);

            System.assert(
                false,
                'Expected invalid hotel count error.'
            );
        } catch (IllegalArgumentException ex) {
            System.assert(
                ex.getMessage().contains(
                    'Hotel count must be greater than zero'
                )
            );
        }
    }
}
