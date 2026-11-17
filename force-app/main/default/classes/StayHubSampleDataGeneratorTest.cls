@IsTest
private class StayHubSampleDataGeneratorTest {
    @IsTest static void standardCount() {
        System.assertEquals(7400, StayHubSampleDataGenerator.expectedRecordCount(200));
    }
    @IsTest static void scaleCount() {
        System.assertEquals(1850000, StayHubSampleDataGenerator.expectedRecordCount(50000));
    }
    @IsTest static void zeroCount() {
        System.assertEquals(0, StayHubSampleDataGenerator.expectedRecordCount(0));
    }
    @IsTest static void negativeCountRejected() {
        Boolean thrown = false;
        try { StayHubSampleDataGenerator.expectedRecordCount(-1); }
        catch (IllegalArgumentException e) { thrown = true; }
        System.assert(thrown);
    }
    @IsTest static void overLimitRejected() {
        Boolean thrown = false;
        try { new StayHubSampleDataGenerator(50001); }
        catch (IllegalArgumentException e) { thrown = true; }
        System.assert(thrown);
    }
}
