module AggregationService
  module CommandBuilders
    def build_general_command(data)
      input = data['input']
      output = data['output']
      service = _or_else(data['service'], ENV['MU_SPARQL_ENDPOINT'])
      big_data = _or_else(data['big_data'], false)
      dataset = _or_else(data['dataset'], BSON::ObjectId.new.to_s)
      provenance = _or_else(data['provenance'], true)

      "-i #{input} -o #{output} -s #{service} -d #{dataset} --write-data-csv #{big_data} --write-provenance #{provenance}"
    end

    def build_kmeans_command(data)
      iterations = data['iterations'].to_s
      centroids = data['centroids'].to_s
      distance_metric = _or_else(data['metric'], 'EUCLIDEAN').upcase

      "kmeans -n #{iterations} -k #{centroids} -m #{distance_metric}"
    end

    def build_time_command(data)
      levels = data['levels'].to_i
      "time -d #{2 ** levels}"
    end

    def build_grid_command(data)
      grid_size = data['grid_size']
      "grid -g #{grid_size}"
    end

    def build_dynamic_parameters(data)
      dynamic_params = ["query", "latitude_key", "longitude_key", "timestamp_key", "id_key", "source_key"]
      unless data.nil?
        dynamic_params
            .map { |param| _get_dynamic_parameter(param, data) }
            .select { |param| not param.nil? }
            .join(' ')
      end
    end

    def setup_environment(data)
      unless data.nil?
        unless data['hdfs'].nil?
          ENV['HDFS_URL'] = data['hdfs']
        end
        unless data['spark_master'].nil?
          ENV['SPARK_MASTER_URL'] = data['spark_master']
        end
      end
    end

    def _get_dynamic_parameter(param_name, data, attr_name=nil)
      attr_name ||= param_name
      unless data[attr_name].nil?
        value = data[attr_name]
        "-D#{param_name}=#{value}"
      end
    end

    def _or_else(optional, default_val)
      if optional.nil?
        default_val
      else
        optional
      end
    end
  end
end