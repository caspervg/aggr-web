module AggregationService
  module SparqlQueries
    def insert_new_aggregation_request(request, request_id)
      request_uri = RDF::URI.new(OWN_REQ.to_s + request_id)
      param_id = generate_uuid()
      param_uri = RDF::URI.new(OWN_REQP.to_s + param_id)
      dyn_id = generate_uuid()
      dyn_uri = RDF::URI.new(OWN_REQD.to_s + dyn_id)
      env_id = generate_uuid()
      env_uri = RDF::URI.new(OWN_REQE.to_s + env_id)

      query =  " INSERT DATA {"
      query += "   GRAPH <#{settings.graph}> {"

      unless request['parameters']['dynamic'].nil?
        dynamic_params = ['query', 'latitude_key', 'longitude_key', 'time_key', 'source_key']
        dynamic_params.each do |param|
          unless request['parameters']['dynamic'][param].nil?
            log.info("Adding parameter #{param} with value #{request['parameters']['dynamic'][param]}")
            query += "<#{dyn_uri}> <#{OWN_P[param]}> #{request['parameters']['dynamic'][param].sparql_escape} ."
          end
        end
      end

      environment_params = ['hdfs', 'spark']
      environment_params.each do |param|
        unless request['environment'][param].nil?
          log.info("Adding environment variable #{param} with value #{request['environment'][param]}")
          query += "<#{env_uri}> <#{OWN_P[param]}> #{request['environment'][param].sparql_escape} ."
        end
      end

      aggregation_params = ['iterations', 'centroids', 'metric', 'levels', 'grid_size']
      aggregation_params.each do |param|
        unless request['parameters'][param].nil?
          log.info("Adding parameter #{param} with value #{request['parameters'][param]}")
          query += "<#{param_uri}> <#{OWN_P[param]}> #{request['parameters'][param].sparql_escape} ."
        end
      end
      query += "<#{param_uri}> <#{OWN_P.dynamic}> <#{dyn_uri}> ."

      query += "     <#{request_uri}> <#{MU_CORE.uuid}> <#{request_id}> ;"
      query += "                      <#{OWN_P.input}> #{request['input'].sparql_escape} ;"
      query += "                      <#{OWN_P.output}> #{request['output'].sparql_escape} ;"
      query += "                      <#{OWN_P['aggregation_type']}> #{request['aggregation_type'].sparql_escape} ;"
      query += "                      <#{OWN_P.provenance}> #{request['provenance'].sparql_escape} ;"
      query += "                      <#{OWN_P['big_data']}> #{request['big_data'].sparql_escape} ;"
      query += "                      <#{OWN_P.status}> \"not_started\" ;"
      query += "                      <#{DCT.date}> #{Time.new.sparql_escape} ;"
      query += "                      <#{OWN_P.parameters}> <#{param_uri}> ;"
      query += "                      <#{OWN_P.environment}> <#{env_uri}> ."
      query += "   }"
      query += " }"

      update(query)
    end
  end
end