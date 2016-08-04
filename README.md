# Aggr-Web

## Description
This repository contains the Ruby components of the Aggr project. It provides functionality to translate incoming JSON API aggregation requests to a semantic entity and place it in a triple-store, where it will be read and interpreted by the `Aggr-Master` and finally executed by a `Aggr-Worker`.

Implemented by Casper Van Gheluwe (UGent) during the summer of 2016, as part of an internship at TenForce.

## Components
* **web.rb**
    * HTTP request handling
* **lib/additional_escape_helpers.rb**
    * Includes some additional SPARQL escape methods for classes that were not yet supported by the []mu-ruby-template](https://github.com/mu-semtech/mu-ruby-template/blob/master/lib/escape_helpers.rb). `Time`, `Array` (crudely), `FalseClass` and `TrueClass` are now supported.
* **aggregation_service/request_validations.rb**
    * Performs some validations on incoming HTTP requests to ensure that the required attributes in general, and for the request aggregation in particular, are included.
* **aggregation_service/sparql_queries.rb**
    * Builds an executes a SPARQL query to insert a new aggregation request entity into the triple-store.

## HTTP
### POST /aggregations
Inserts a new Aggregation Request entity into the triple-store with given properties.

#### Headers
* `Content-Type: application/vnd.api+json`

#### Payload
```json
{
    "data": {
        "type": "aggregations",
        "attributes": {
            "dataset": "example_dataset_identifier",
            "input": "/user/example/example_input.csv",
            "output": "/user/example/output/",
            "aggregation_type": "kmeans",
            "provenance": true,
            "big_data": false,
            "input_class": "net.caspervg.aggr.ext.TimedGeoMeasurement",
            "output_class": "net.caspervg.aggr.ext.WeightedGeoMeasurement",
            "parameters": {
                "grid_size": 0.005,
                "levels": 3,
                "centroids": 25,
                "iterations": 50,
                "metric": "EUCLIDEAN",
                "others": [
                  "/user/test/test1.csv",
                  "/user/test/test2.csv"
                ],
                "key": "weight",
                "amount": 4,
                "dynamic": {
                  "query": "special sparql query to retrieve data from the triple store",
                  "source_key": "special_key_of_the_source_for_data"
                }
            },
            "environment": {
                "spark": "local[4]spark://spark-master:7077",
                "hdfs": "hdfs://namenode:8020"
            }
        }
    }
}
```

* `type`: MUST be `aggregations`
* `attributes`:
    * `dataset`: REQUIRED, unique identifier of the dataset to create
    * `input`: REQUIRED, location of a CSV file (or SPARQL HTTP endpoint) to read data from (ignored for `average` aggregation)
    * `output`: REQUIRED, location of a directory to store data in (in case `attributes.big_data` is set to `true`)
    * `aggregation_type`: REQUIRED, type of the aggregation to execute (MUST be one of `grid`, `time`, `diff`, `combination`, `average` or `kmeans`)
    * `provenance`: REQUIRED, determines if provenance (parents) of the aggregated measurements should be stored
    * `big_data`: REQUIRED, determines if the result will be stored as CSV (if `true`) or in the triple-store (if `false`)
    * `input_class`: REQUIRED, package and name of the class to use to read measurements (this class MUST be in the classpath of the `Aggr-Master` and `Aggr-Worker` and MUST implement the `Measurement` interface)
    * `output_class`: REQUIRED, package and name of the class to use to write measurements (this class MUST be in the classpath of the `Aggr-Master` and `Aggr-Worker` and MUST implement the `Measurement` interface)
    * `parameters`:
        * `grid_size`: sensitivity of the grid (for `grid` aggregations only)
        * `levels`: number of detail levels to generate (for `time` aggregations only)
        * `centroids`: number of centroids to generate (for `kmeans` aggregations only)
        * `iterations`: maximum number of iterations of the k-Means algorithm (for `kmeans` aggregations only)
        * `metric`: metric to use to calculate distances between centroids & measurements (for `kmeans` aggregations only, MUST be one of `EUCLIDEAN`, `MANHATTAN`, `CHEBYSHEV`, `CANBERRA` or `KARLSRUHE`
        * `others` if `diff` aggregation: array with one String element, the location of the subtrahend dataset (as CSV)
        * `others` if `average` aggregation: array of Strings, the locations of datasets to calculate average of (as CSVs)
        * `key`: key to extract value to subtract or average (for `average` or `diff` aggregations)
        * `amount`:  expected number of values per combination (for `average` aggregations)
        * `dynamic`: extra dynamic properties for reading measurements, executing the aggregation or writing results. Keys supported: `query`, `latitude_key`, `longitude_key`, `source_key`,  `time_key`
    * `environment`:
        * `spark`: REQUIRED, location of the Spark master. If empty, plain Java aggregations will be executed instead
        * `hdfs`: REQUIRED, location of the HDFS server. If empty, will assume the files are available locally.


## Development
The Aggr-Web application can be ran in development mode (with automatic reloading) using the following command:
```
docker run -p 80:80 --name aggr-web --volume /home/casper/IdeaProjects/aggr-web:/app -e RACK_ENV=development semtech/mu-ruby-template:2.0.0-ruby2.3
```
## Docker
A **Docker configuration** (`Dockerfile`) is provided, based on [semtech/mu-ruby-template](https://github.com/mu-semtech/mu-ruby-template). When ran, it will automatically start a Ruby/Sinatra HTTP server that will accept aggregation requests.
