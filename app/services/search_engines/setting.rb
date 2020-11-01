module SearchEngines
  class Setting
    DEFAULT_SETTINGS_PATH = "#{Rails.root.join('config', 'search_engines_settings.yml')}".freeze

    attr_accessor :file, :errors

    def initialize(file_name = nil)
      @errors = { errors: [] }
      @file ||= read_settings_from(file_name || DEFAULT_SETTINGS_PATH)
    rescue StandardError => e
      @errors[:errors] << "error: SETTING_FILE_NOT_FOUND, message: #{e.message}"
      self
    end

    def errors?
      @errors[:errors].present?
    end

    private

    def read_settings_from(file_name)
      YAML.load(File.read(file_name))
    end
  end
end