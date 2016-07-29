module AggregationService
  module RequestValidations

    def validate_general(data)
      error('Input (`input`) is required') if data['input'].nil?
      error('Output (`output`) is required') if data['output'].nil?
      error('Aggregation type (`aggregation_type`) is required') if data['aggregation_type'].nil?
      error('Parameters (`parameters`) is required') if data['parameters'].nil?
    end

    def validate_aggregation(data, type)
      case type
        when 'kmeans' then _validate_kmeans(data)
        when 'time' then _validate_time(data)
        when 'grid' then _validate_grid(data)
        else
          true
      end
    end

    def _validate_kmeans(data)
      error('Number of iterations (`parameters.iterations`) is required') if data['iterations'].nil?
      error('Number of centroids/means (`parameters.centroids`) is required') if data['centroids'].nil?
    end

    def _validate_time(data)
      error('Number of time levels (`parameters.levels`) is required') if data['levels'].nil?
    end

    def _validate_grid(data)
      error('Grid size (`parameters.grid_size`) is required') if data['grid_size'].nil?
    end
  end
end