# Combine Backpressure Research CSV

![](Documentation/BackpressureIllustrated.png)

I wrapped a csv file reader (using CSV.swift) to slowly enumerate all the values in a CSV file using backpressure.  Please start with the unit test as the UI is rather trivial and doesn't "do" much more than display a List.

Some breakpoints have been shared to help demonstrate when certain functions are called using backpressure. And some comments suggest where the reader may want to change something to see different use cases of backpressure. 

### Try out

What would happen if the Buffer's size was larger in NameImporter.swift line 37? How would that affect the calls to readRow in CSVReader line 223?

Consider accumulating the names received and applying an algorithm that works on all previous names.

- If given a Data set where the count was not in decending order Femals then Decending order Males, group the names and keep a list of Names in order based on count
- Use the Names recived to create a Try

Things moving to fast in the `NameListTests.testBackpressure()` ? just increase the UInt in `usleep(#)`

### Issues

The CSVReader seems to skip the first element in the CSV file when enumerated so I wrote an empty line of data to get what I expected. I'd appreciate some help and feedback on that

### License

The MIT License (MIT)
Copyright (c) 2019 Paul Wood
