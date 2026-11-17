// Creates 200 hotels and their related sample records (7,400 records total).
Id jobId = StayHubSampleDataGenerator.launch(200);
System.debug(LoggingLevel.INFO, 'Standard StayHub data job submitted: ' + jobId);
