require 'bcrypt'
require 'open4'
require_relative 'lib/additional_escape_helpers.rb'
require_relative 'aggregation_service/sparql_queries'
require_relative 'aggregation_service/request_validations'

configure do
end

###
# Vocabularies
###
DCT = RDF::Vocabulary.new("http://purl.org/dc/terms/")
OWN = RDF::Vocabulary.new("http://www.caspervg.net/test/")
OWN_P = RDF::Vocabulary.new(OWN.to_uri.to_s + 'property#')
OWN_REQ = RDF::Vocabulary.new(OWN.to_uri.to_s + 'aggregation-request/')
OWN_REQE = RDF::Vocabulary.new(OWN_REQ.to_uri.to_s + 'environment/')
OWN_REQP = RDF::Vocabulary.new(OWN_REQ.to_uri.to_s + 'parameters/')
OWN_REQD = RDF::Vocabulary.new(OWN_REQP.to_uri.to_s + 'dynamic/')
OWN_REP = RDF::Vocabulary.new(OWN.to_uri.to_s + 'aggregation-report/')

###
# POST /aggregations/kmeans
#
# Body    {"data":{"type":"sessions","attributes":{"nickname":"john_doe","password":"secret"}}}
# Returns 201 on successful login
#         400 if session header is missing
#         400 on login failure (incorrect user/password or inactive account)
###
post '/aggregations/?' do
  content_type 'application/vnd.api+json'

  ###
  # Validate headers
  ###
  validate_json_api_content_type(request)

  ###
  # Validate request
  ###

  request.body.rewind
  body = JSON.parse request.body.read
  data = body['data']
  attributes = data['attributes']

  validate_resource_type('aggregations', data)
  error('Id parameter is not allowed', 403) unless data['id'].nil?

  validate_general(attributes)
  validate_aggregation(attributes['parameters'], attributes['aggregation_type'])

  request_id = generate_uuid()
  insert_new_aggregation_request(attributes, request_id)

  status 201
  {
    data: {
      type: 'aggregation_request',
      id: request_id
    }
  }.to_json
end


###
# Helpers
###

helpers AggregationService::SparqlQueries
helpers AggregationService::RequestValidations