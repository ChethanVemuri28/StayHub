/**
 * @description Batch entry point for generating repeatable StayHub sample data.
 */
public with sharing class StayHubSampleDataGenerator implements Database.Batchable<Integer> {
  private Integer hotelCount;

  private static final Integer SCOPE_SIZE = 10;

  /**
   * @description Creates a generator for the requested hotel count.
   * @param count Number of hotels to generate; maximum is 50,000.
   */
  public StayHubSampleDataGenerator(Integer count) {
    if (count == null || count < 1 || count > 50000) {
      throw new IllegalArgumentException(
        'Hotel count must be between 1 and 50000.'
      );
    }
    hotelCount = count;
  }

  /**
   * @description Launches the batch using the standard scope size.
   * @param count Number of hotels to generate.
   * @return Salesforce batch job ID.
   */
  public static Id launch(Integer count) {
    return Database.executeBatch(
      new StayHubSampleDataGenerator(count),
      SCOPE_SIZE
    );
  }

  /**
   * @description Calculates the expected number of generated records.
   * @param count Number of hotels.
   * @return Expected number of records, 37 per hotel.
   */
  public static Integer expectedRecordCount(Integer count) {
    if (count == null || count < 0) {
      throw new IllegalArgumentException('Hotel count cannot be negative.');
    }
    return count * 37;
  }
  // This is a sample push and Deployment Test also removed prettier and I am testing the deployment of the code to see if it works or not. I will also be testing the deployment of the code to see if it works or not. I will also be testing the deployment of the code to see if it works or not. I will also be testing the deployment of the code to see if it works or not. I will also be testing the deployment of the code to see if it works or not. I will also be testing the deployment of the code to see if it works or not. I will also be testing the deployment of the code to see if it works or not. I will also be testing the deployment of the code to see if it works or not. I will also be testing the deployment of the code to see if it works or not. I will also be testing the deployment of the code to see if it works or not. I will also be testing the deployment of the code to see if it works or not. I will also be testing the deployment of the code to see if it works or not. I will also be testing the deployment of the code to see if it works or not. I will also be testing the deployment of the code to see if it works or not. I will also be testing the deployment of the code to see if it works or not. I will also be testing the deployment of the code to see if it works or not. I will also be testing the deployment of the code to see if it works or not. I will also be testing the deployment of the code to see if it works or not.

  /**
   * @description Creates one batch item for each requested hotel.
   * @param bc Batch execution context.
   * @return Hotel indexes to process.
   */
  public Iterable<Integer> start(Database.BatchableContext bc) {
    List<Integer> indexes = new List<Integer>();
    for (Integer indexValue = 0; indexValue < hotelCount; indexValue++) {
      indexes.add(indexValue);
    }
    return indexes;
  }

  /**
   * @description Delegates each scope to the sample-data processor.
   * @param bc Batch execution context.
   * @param scope Hotel indexes in this batch scope.
   */
  public void execute(Database.BatchableContext bc, List<Integer> scope) {
    StayHubSampleDataBatchProcessor.process(scope);
  }

  /**
   * @description Writes a completion trace for the batch job.
   * @param bc Batch execution context.
   */
  public void finish(Database.BatchableContext bc) {
    if (bc != null) {
      System.debug(
        LoggingLevel.INFO,
        'StayHub sample-data batch finished. Job ID: ' + bc.getJobId()
      );
    }
  }
}