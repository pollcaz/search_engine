# frozen_string_literal: true

RSpec.shared_examples 'search engine' do |klass_name|
	let(:file_name) { 'search_engines_settings.yml.example' }
  let(:example_file_name) { "spec/support/services/#{file_name}" }
  let(:file_name_not_exist) { 'spec/support/services/search_engines_settings1.yml.example' }
  let(:search_engine_name) { klass_name.to_s[15..-1].downcase }
  let(:mock_file_path) { "spec/support/services/#{search_engine_name}_search_mock_response.yml"}
  let(:mock_request_search_engine) { loaded_file(mock_file_path) }
  let(:http_ok) { double(Net::HTTPOK, body: mock_request_search_engine[search_engine_name])}
  let(:subject) { klass_name.new }

  def loaded_file(file)
    YAML.load(File.read(file))
  end

  def setting_attributes_errors(klass)
    errors = ['error: MISSING_SETTING_KEY_VALUE, message: Setting Key accessKey=> value empty']
    errors << if klass.eql?(SearchEngines::Google)
     'error: MISSING_SETTING_KEY_VALUE, message: Setting Key cx=> value empty'
    elsif klass.eql?(SearchEngines::Bing)
     'error: MISSING_SETTING_KEY_VALUE, message: Setting Key location=> value empty'
    end
  end

  before do
    allow_any_instance_of(SearchEngines::Setting).to receive(:read_settings_from).and_return(loaded_file(example_file_name))
  end
  describe '#initialize' do
    it 'has an errors attribute' do
      expect(subject.instance_variable_get('@errors')).to eq({ errors: [] })
    end

    context 'when missing values in search_engines_setting.yml file' do
      let(:file_name) { 'search_engines_missing_settings.yml' }

      it 'return the respective errors' do
        expect(subject.errors[:errors]).to be_present
        expect(subject.errors[:errors].size).to eq(2)
        expect(subject.errors[:errors]).to eq(setting_attributes_errors(klass_name))
      end
    end

    context 'when no missing values in search_engines_setting.yml file' do
      let(:file_name) { 'search_engines_settings.yml.example' }
      it 'sets its own attributes' do
        klass_name::CONEXION_KEYS.each do |key|
          expect(subject.instance_variable_get("@#{key}")).to be_present
        end
      end
    end

    it 'returns an instance of the class received as argument' do
      expect(subject).to be_a klass_name
    end
  end

  describe '#search' do
    context 'Google, Bing' do
      before do
        allow_any_instance_of(Net::HTTP).to receive(:request) { http_ok }
      end
      it 'returns search engine results' do
        expect(subject.search('Ruby')).to be_present
      end
    end
  end

  describe '#errors?' do
    context 'when there is any error' do
      context 'when setting file not found' do
        it 'returns true as response' do
          subject.instance_variable_set('@errors', { errors: ['SETTING_ERROR']})
          expect(subject.errors?).to be_truthy
        end
      end
    end
    context 'when there is not errors' do
      it 'returns false as response' do
        expect(subject.errors?).to be_falsy
      end
    end
  end
end
