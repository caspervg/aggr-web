require 'bcrypt'
require 'open4'
require_relative 'login_service/sparql_queries.rb'
require_relative 'aggregation_service/command_builders'
require_relative 'aggregation_service/request_validations'

configure do
  set :salt, ENV['MU_APPLICATION_SALT']
end

###
# Vocabularies
###

MU_ACCOUNT = RDF::Vocabulary.new(MU.to_uri.to_s + 'account/')
MU_SESSION = RDF::Vocabulary.new(MU.to_uri.to_s + 'session/')

###
# POST /aggregations/kmeans
#
# Body    {"data":{"type":"sessions","attributes":{"nickname":"john_doe","password":"secret"}}}
# Returns 201 on successful login
#         400 if session header is missing
#         400 on login failure (incorrect user/password or inactive account)
###
post '/aggregations/kmeans/?' do
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

  validate_resource_type('kmeans_aggregations', data)
  error('Id parameter is not allowed', 403) unless data['id'].nil?

  validate_general(attributes)
  validate_kmeans(attributes['parameters'])

  ###
  # Set up environment variables if required
  ###

  setup_environment(attributes['environment'])

  ###
  # Build commandline based on request
  ###

  cmdline = [build_general_command(attributes),
             build_kmeans_command(attributes['parameters']),
             build_dynamic_parameters(attributes['dynamic'])].compact.join(' ')

  ###
  # Execute the command and wait for a result
  ###

  exec_status =
    Open4::popen4(cmdline) do |pid, _, stdout, stderr|
      log.info "Starting the requested aggregation"
      log.info "Commandline      : #{cmdline}"
      log.info "Pid              : #{pid}"
      log.info "Stdout           : #{stdout}"
      log.info "Stderr           : #{stderr}"
    end
      log.info "Status           : #{exec_status.inspect}"
      log.info "Exit status      : #{exec_status.exitstatus}"

  status 201
  {
    links: {
      self: cmdline, # rewrite_url.chomp('/') + '/current'
    },
    data: {
      type: 'kmeans_aggregation_result',
      id: "identifier" #session_id
    }
  }.to_json
end

post '/aggregations/time/?' do
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

  validate_resource_type('time_aggregations', data)
  error('Id parameter is not allowed', 403) unless data['id'].nil?

  validate_general(attributes)
  validate_time(attributes['parameters'])

  ###
  # Set up environment variables if required
  ###

  setup_environment(attributes['environment'])

  ###
  # Build commandline based on request
  ###

  cmdline = [build_general_command(attributes),
             build_time_command(attributes['parameters']),
             build_dynamic_parameters(attributes['dynamic'])].compact.join(' ')

  ###
  # Execute the command and wait for a result
  ###

  exec_status =
      Open4::popen4(cmdline) do |pid, _, stdout, stderr|
        log.info "Starting the requested aggregation"
        log.info "Commandline      : #{cmdline}"
        log.info "Pid              : #{pid}"
        log.info "Stdout           : #{stdout}"
        log.info "Stderr           : #{stderr}"
      end
  log.info "Status           : #{exec_status.inspect}"
  log.info "Exit status      : #{exec_status.exitstatus}"

  status 201
  {
      links: {
          self: cmdline, # rewrite_url.chomp('/') + '/current'
      },
      data: {
          type: 'time_aggregation_result',
          id: "identifier" #session_id
      }
  }.to_json
end


post '/aggregations/grid/?' do
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

  validate_resource_type('grid_aggregations', data)
  error('Id parameter is not allowed', 403) unless data['id'].nil?

  validate_general(attributes)
  validate_grid(attributes['parameters'])

  ###
  # Set up environment variables if required
  ###

  setup_environment(attributes['environment'])

  ###
  # Build commandline based on request
  ###

  cmdline = [build_general_command(attributes),
             build_grid_command(attributes['parameters']),
             build_dynamic_parameters(attributes['dynamic'])].compact.join(' ')

  ###
  # Execute the command and wait for a result
  ###

  exec_status =
      Open4::popen4(cmdline) do |pid, _, stdout, stderr|
        log.info "Starting the requested aggregation"
        log.info "Commandline      : #{cmdline}"
        log.info "Pid              : #{pid}"
        log.info "Stdout           : #{stdout}"
        log.info "Stderr           : #{stderr}"
      end
  log.info "Status           : #{exec_status.inspect}"
  log.info "Exit status      : #{exec_status.exitstatus}"

  status 201
  {
      links: {
          self: cmdline, # rewrite_url.chomp('/') + '/current'
      },
      data: {
          type: 'time_aggregation_result',
          id: "identifier" #session_id
      }
  }.to_json
end

###
# Helpers
###

helpers LoginService::SparqlQueries
helpers AggregationService::RequestValidations
helpers AggregationService::CommandBuilders
