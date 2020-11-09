require 'rails_helper'

RSpec.describe SearchEngines::Setting do
  let(:klass) { SearchEngines::Setting }
  let(:example_file_name) { 'spec/support/services/search_engines_settings.yml.example' }
  let(:file_name_not_exist) { 'spec/support/services/search_engines_settings1.yml.example' }

  describe '#initialize' do
    let(:subject) { klass.new }
    let(:loaded_file) do
      YAML.load(File.read(example_file_name))
    end

    it 'has an errors attribute' do
      expect(subject.instance_variable_get('@errors')).to eq({ errors: [] })
    end

    it 'has a file attribute' do
      expect(klass.new(example_file_name).instance_variable_get('@file')).to eq(loaded_file)
    end

    context 'when send the path file as argument' do
      context 'when the setting file exist' do
        it 'contains the settings to set Google and Bing search engines' do
          file = klass.new(example_file_name).file
          expect(file.keys).to eq(%w[google bing])
          expect(file['google'].keys).to eq(%w[accessKey uri path cx])
          expect(file['bing'].keys).to eq(%w[accessKey uri path location])
        end
      end

      context 'when setting file does not exist' do
        let(:subject) { klass.new('support/services/search_engines_settings.yml') }
        it 'return an error message into errors attribute' do
          errors = {errors: ["error: SETTING_FILE_NOT_FOUND, message: No such file or directory \
@ rb_sysopen - support/services/search_engines_settings.yml"]}
          expect(subject.errors).to eq(errors)
        end
      end
    end

    context 'when don\'t send the path file as argument' do
      let(:subject) { klass.new }
      it 'uses the default setting path' do
        default_setting_path = Rails.root.join('config', 'search_engines_settings.yml').to_s
        expect_any_instance_of(klass).to receive(:read_settings_from).with(default_setting_path)
        subject
      end
    end
  end

  describe '#errors?' do
    context 'when there is any error' do
      it 'returns true as response' do
        subject = klass.new(file_name_not_exist)
        expect(subject.errors?).to be_truthy
      end
    end
    context 'when there is not errors' do
      it 'returns false as response' do
        subject = klass.new(example_file_name)
        expect(subject.errors?).to be_falsy
      end
    end
  end
end
