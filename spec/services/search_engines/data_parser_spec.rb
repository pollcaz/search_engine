require 'rails_helper'

RSpec.describe SearchEngines::DataParser do
  def loaded_file(file)
    YAML.load(File.read(file))
  end

  let(:mock_file_path) { "spec/support/services/#{search_engine_name}_search_mock_response.yml" }
  let(:mock_file2_path) { "spec/support/services/#{search_engine_name2}_search_mock_response.yml" }
  let(:results) { loaded_file(mock_file_path)[search_engine_name] }
  let(:results_bing) { loaded_file(mock_file2_path)[search_engine_name2] }
  let(:failed) { false }
  let(:failed2) { false }
  let(:recordset) { [{ engine: search_engine_name, recordset: results, failed: failed }] }
  let(:json_object) { described_class.build_json_response(recordset) }
  let(:json_object2) { described_class.build_json_response(recordset_with_both_results) }
  let(:json_object_keys) { %i[engine recordmatches offset total items] }
  let(:json_object_items_keys) { described_class::RECORD_KEYS[search_engine_name.to_sym].keys}
  let(:json_object2_items_keys) { described_class::RECORD_KEYS[:bing].keys}
  let(:json_object_items_complete) { ([:index_order] << json_object_items_keys).flatten }
  let(:json_object2_items_complete) { ([:index_order] << json_object2_items_keys).flatten }
  let(:recordset_with_both_results) do
    [{engine: 'google', recordset: results, failed: failed },
     {engine: 'bing', recordset: results_bing, failed: failed2 }]
  end


  describe '.build_json_response' do
    context 'when google' do
      let(:search_engine_name) { 'google' }
      it 'returns a JSON Object for Google Search Engine Results' do
        expect(json_object.keys).to eq([search_engine_name])
        expect(json_object[search_engine_name].keys).to eq(json_object_keys)
        expect(json_object[search_engine_name][:items].first.keys).to eq(json_object_items_complete)
        expect(json_object[search_engine_name][:items].size).to eq(10)
      end
    end
    context 'when bing' do
      let(:search_engine_name) { 'bing' }
      it 'returns a JSON Object for Bing Search Engine Results' do
        expect(json_object.keys).to eq([search_engine_name])
        expect(json_object[search_engine_name].keys).to eq(json_object_keys)
        expect(json_object[search_engine_name][:items].first.keys).to eq(json_object_items_complete)
        expect(json_object[search_engine_name][:items].size).to eq(10)
      end
    end

    context 'when require to parse both search engines(google, bing)' do
      let(:search_engine_name) { 'google' }
      let(:search_engine_name2) { 'bing' }
      it 'returns a JSON Object for Google & Bing Search Engine Results' do
        expect(json_object2.size).to eq(2)
        expect(json_object2.keys).to eq(%w[google bing])
      end
      context 'when one of the recordsets has an error' do
        let(:failed) { true }
        let(:results) do {
          error: 'Bad Request',
          code: 'MISSING_OR_INVALID_ARGUMENTS'
        }
        end
        it 'returns the error for that specific search engine' do
          expect(json_object2.size).to eq(2)
          expect(json_object2.keys).to eq(%w[google bing])
          expect(json_object2['google'].keys).to eq(%i[error code])
        end
      end
    end
  end
end
