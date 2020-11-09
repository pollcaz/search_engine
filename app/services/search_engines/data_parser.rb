require 'json'

module SearchEngines
  class DataParser
    RECORD_KEYS = {
      google: { title: 'title', link: 'link', snippet: 'snippet'},
      bing:   { title: 'name', link: 'url', snippet: 'snippet'}
    }.freeze
    
    class << self

      def build_json_response(recordsets, offset = 0)
        {}.tap do |results|
          recordsets.each do |record|
            results[record[:engine]] = if !record[:failed]
              recordset = JSON.parse(record[:recordset])
              build_json_object(recordset, record[:engine], offset)
            else
              record[:recordset]
            end
          end
        end
      end

      private

      def build_json_object(recordset, engine, offset = 0)
        { engine:        engine,
          recordmatches: recordmatches(recordset, engine).to_i,
          offset:        offset,
          total:         build_json_items(recordset, engine).size,
          items:         build_json_items(recordset, engine)
        }
      end

      def recordmatches(recordset, engine)
        if engine.to_s.eql?('google')
          recordset['queries']['request'].first['totalResults']
        elsif engine.to_s.eql?('bing')
          recordset['webPages']['totalEstimatedMatches']
        else
          nil
        end
      end

      def build_json_items(recordset, engine)
        [].tap do |json_items|
          items(recordset, engine).each_with_index do |item, index_order|
            json_items << build_json_item(item, engine, index_order)
          end
        end
      end

      def build_json_item(item, engine, index_order)
        {
          index_order: index_order,
          title:       item[RECORD_KEYS[engine.to_sym][:title]],
          link:        item[RECORD_KEYS[engine.to_sym][:link]],
          snippet:     item[RECORD_KEYS[engine.to_sym][:snippet]]
        }
      end

      def items(recordset, engine)
        if engine.to_s.eql?('google')
          recordset.dig('items') || []
        elsif engine.to_s.eql?('bing')
          recordset.dig('webPages', 'value') || []
        else
          []
        end
      end
    end
  end
end