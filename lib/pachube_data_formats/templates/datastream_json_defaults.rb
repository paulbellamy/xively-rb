module PachubeDataFormats
  module Templates
    module DatastreamJSONDefaults
      def generate_json(version)
        case version
        when "1.0.0"
          json_1_0_0
        when "0.6-alpha"
          json_0_6_alpha
        end
      end

      private
      
      # As used by http://www.pachube.com/api/v2/FEED_ID/datastreams/DATASTREAM_ID.json
      def json_1_0_0
        template = Template.new(self, :json)
        template.id
        template.version {"1.0.0"}
        template.at {updated.iso8601(6)}
        template.current_value
        template.max_value
        template.min_value
        template.tags {tags.split(',').map(&:strip).sort{|a,b| a.downcase <=> b.downcase}}
        template.unit {{:label => unit_label, :symbol => unit_symbol, :type => unit_type}} if unit_type || unit_symbol || unit_label
        template.datapoints do
          datapoints.collect do |datapoint|
            {
              :at => datapoint.at.iso8601(6),
              :value => datapoint.value
            }
          end
        end if datapoints.any?
        template.output!
      end

      # As used by http://www.pachube.com/api/v1/FEED_ID/datastreams/DATASTREAM_ID.json
      def json_0_6_alpha
        template = Template.new(self, :json)
        template.id
        template.version {"0.6-alpha"}
        template.values {
          [{ :recorded_at => updated.iso8601,
            :value => current_value,
            :max_value => max_value,
            :min_value => min_value }]
        }
        template.tags {tags.split(',').map(&:strip).sort{|a,b| a.downcase <=> b.downcase}}
        template.unit {{:label => unit_label, :symbol => unit_symbol, :type => unit_type}} if unit_type || unit_symbol || unit_label
        template.output!
      end
    end
  end
end

