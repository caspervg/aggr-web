### Run in development mode
```
docker run -p 80:80 --name aggr-web --volume /home/casper/IdeaProjects/aggr-web:/app -e RACK_ENV=development semtech/mu-ruby-template:2.0.0-ruby2.3
```

### Example request
* POST /aggregations with following payload

```json
{
    "data": {
        "type": "aggregations",
        "attributes": {
            "input": "hello.csv",
            "output": "output.csv",
            "aggregation_type": "kmeans",
            "provenance": true,
            "big_data": true,
            "parameters": {
                "iterations": 30,
                "centroids": 5,
                "dynamic": {
                    "query": "example_sparql_query",
                    "latitude_key": "special_latitude_key"
                }
            },
            "environment": {
                "hdfs": "hdfs://namenode:8020",
                "spark": "local[4]"
            }
        }
    }
}
```

will insert an AggregationRequest with the following SPARQL query:

```sparql
 PREFIX  xsd:  <http://www.w3.org/2001/XMLSchema#>
 
 INSERT DATA {
   GRAPH <http://mu.semte.ch/application> {
     <http://www.caspervg.net/test/aggregation-request/environment/57961ff7a1ec8001ea000023> <http://www.caspervg.net/test/property#hdfs> "hdfs://namenode:8020" .
     <http://www.caspervg.net/test/aggregation-request/environment/57961ff7a1ec8001ea000023> <http://www.caspervg.net/test/property#spark> "local[4]" .
     <http://www.caspervg.net/test/aggregation-request/parameters/57961ff7a1ec8001ea000021> <http://www.caspervg.net/test/property#iterations> 30 .
     <http://www.caspervg.net/test/aggregation-request/parameters/57961ff7a1ec8001ea000021> <http://www.caspervg.net/test/property#centroids> 5 .
     <http://www.caspervg.net/test/aggregation-request/parameters/57961ff7a1ec8001ea000021> <http://www.caspervg.net/test/property#dynamic> <http://www.caspervg.net/test/aggregation-request/parameters/dynamic/57961ff7a1ec8001ea000022> .
     <http://www.caspervg.net/test/aggregation-request/57961ff7a1ec8001ea000020> <http://mu.semte.ch/vocabularies/uuid> <http://example/base/57961ff7a1ec8001ea000020> .
     <http://www.caspervg.net/test/aggregation-request/57961ff7a1ec8001ea000020> <http://www.caspervg.net/test/property#input> "hello.csv" .
     <http://www.caspervg.net/test/aggregation-request/57961ff7a1ec8001ea000020> <http://www.caspervg.net/test/property#output> "output.csv" .
     <http://www.caspervg.net/test/aggregation-request/57961ff7a1ec8001ea000020> <http://www.caspervg.net/test/property#provenance> true .
     <http://www.caspervg.net/test/aggregation-request/57961ff7a1ec8001ea000020> <http://www.caspervg.net/test/property#bigData> true .
     <http://www.caspervg.net/test/aggregation-request/57961ff7a1ec8001ea000020> <http://www.caspervg.net/test/property#status> "not started " .
     <http://www.caspervg.net/test/aggregation-request/57961ff7a1ec8001ea000020> <http://purl.org/dc/terms/date> "2016-07-25T14:19:35+00:00"^^xsd:dateTime .
     <http://www.caspervg.net/test/aggregation-request/57961ff7a1ec8001ea000020> <http://www.caspervg.net/test/property#parameters> <http://www.caspervg.net/test/aggregation-request/parameters/57961ff7a1ec8001ea000021> .
     <http://www.caspervg.net/test/aggregation-request/57961ff7a1ec8001ea000020> <http://www.caspervg.net/test/property#environment> <http://www.caspervg.net/test/aggregation-request/environment/57961ff7a1ec8001ea000023> .
   }
 }
 ```