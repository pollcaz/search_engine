require 'net/https'
require 'uri'
require 'json'

module SearchEngines
  class Bing
    MAX_START_NUMBER = 73100000 # Max value supported by google into an API with restrictions(free plan)
    ATTRIBUTES_KEYS = %w[accessKey uri path location].freeze

    attr_reader :errors, :str_uri
    attr_accessor :accessKey, :uri, :path, :location

    def initialize()
      @errors = { errors: [] }
      @setting = SearchEngines::Setting.new

      if @setting.errors[:errors].blank?
        set_attributes(@setting.file['bing'])
      else
        @errors = @setting.errors
      end

      self
    end

    # term = string what are you looking for
    # start_index = integer from begins the search, it is used to handle the results pagination,
    # into the queries key we can find request & nextPage keys with the data related to handle this.
    def search(term, start_index = nil)
      if errors[:errors].blank?
        uri = start_index.blank? ? URI(str_uri(term)) : URI(str_uri(term) + "&offset=" + max_start_index(start_index).to_s)

        request = Net::HTTP::Get.new(uri)
        request['Ocp-Apim-Subscription-Key'] = @accessKey

        response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
            http.request(request)
        end

        response.body
      else
        errors
      end
    end

    def errors?
      errors[:errors].present?
    end

    private

    def set_attributes(file)
      ATTRIBUTES_KEYS.each do |key|
        if file[key].present?
          instance_variable_set("@#{key}", file[key])
        else
          errors[:errors] << "error: MISSING_SETTING_KEY_VALUE, message: Setting Key #{key}=> value empty"
        end
      end
    end

    def str_uri(term)
      @uri + @path + "?q=" + URI.escape(term) + "&location=" + @location
    end

    def max_start_index(start_index)
      if start_index.to_i > MAX_START_NUMBER
        MAX_START_NUMBER
      else
        start_index
      end
    end
  end
end