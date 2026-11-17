// Creates 50,000 hotels and their related sample records (1,850,000 records total).
Id jobId = StayHubSampleDataGenerator.launch(50000);
System.debug(LoggingLevel.INFO, 'Scale StayHub data job submitted: ' + jobId);
