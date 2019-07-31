# Combine Backpressure Research CSV

I wrapped a csv file reader (using CSV.swift) to slowly enumerate all the values in a CSV file using backpressure. 

Some breakpoints are shared to help demonstrate when certain functionas are called using backpressure.

Some comments are added on things the future reader may want to change to see different uses of backpressure.

Please checkout the test as the UI is rather trivial.

### Issues

The CSVReader seems to skip the first element in the CSV file when enumerated. I'd appreciate some help and feedback on that

### License

The MIT License (MIT)
Copyright (c) 2019 Paul Wood
