@IsTest
private class StayHubSampleDataGeneratorTest {
  @IsTest
  static void standardCount() {
    System.assertEquals(
      7400,
      StayHubSampleDataGenerator.expectedRecordCount(200)
    );
  }

  @IsTest
  static void scaleCount() {
    System.assertEquals(
      1850000,
      StayHubSampleDataGenerator.expectedRecordCount(50000)
    );
  }

  @IsTest
  static void zeroCount() {
    System.assertEquals(0, StayHubSampleDataGenerator.expectedRecordCount(0));
  }

  @IsTest
  static void negativeCountRejected() {
    Boolean thrown = false;

    try {
      StayHubSampleDataGenerator.expectedRecordCount(-1);
    } catch (IllegalArgumentException e) {
      thrown = true;
    }

    System.assert(thrown, 'Negative hotel count should be rejected.');
  }

  @IsTest
  static void overLimitRejected() {
    Boolean thrown = false;

    try {
      new StayHubSampleDataGenerator(50001);
    } catch (IllegalArgumentException e) {
      thrown = true;
    }

    System.assert(thrown, 'More than 50,000 hotels should be rejected.');
  }

  @IsTest
  static void zeroHotelLaunchRejected() {
    Boolean thrown = false;

    try {
      new StayHubSampleDataGenerator(0);
    } catch (IllegalArgumentException e) {
      thrown = true;
    }

    System.assert(thrown, 'Zero hotels should be rejected by the constructor.');
  }
}
