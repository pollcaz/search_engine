# frozen_string_literal: true

require 'net/https'
require 'uri'
require 'json'

module SearchEngines
  # Service to use Bing search engine
  class Bing
    MAX_START_NUMBER = 999_999_999 # Max value supported by bing into an API with restrictions(free plan)
    CONEXION_KEYS = %w[accessKey uri path location].freeze

    attr_reader :errors
    attr_accessor :accessKey, :uri, :path, :location

    def initialize
      @errors = { errors: [] }
      @setting = SearchEngines::Setting.new

      if @setting.errors[:errors].blank?
        initialize_attributes(@setting.file['bing'])
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
        uri = start_index.blank? ? URI(str_uri(term)) : URI(str_uri_with_start(term, start_index))
        request = str_http_request(uri)

        response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
          http.request(request)
        end

        service_error?(response.body) ? errors : response.body
      else
        errors
      end
    end

    def errors?
      errors[:errors].present?
    end

    private

    def str_http_request(uri)
      request = Net::HTTP::Get.new(uri)
      request['Ocp-Apim-Subscription-Key'] = @accessKey
      request
    end

    def str_uri_with_start(term, start_index)
      "#{str_uri(term)}&offset=#{max_start_index(start_index)}"
    end

    def service_error?(results)
      recordset = JSON.parse(results)
      return false unless recordset.keys.any?('error')

      errors[:errors] = recordset['error']['message']
      errors[:code] = 'INVALID_ARGUMENT_IN_SETTINGS'
      true
    end

    def initialize_attributes(file)
      CONEXION_KEYS.each do |key|
        if file[key].present?
          instance_variable_set("@#{key}", file[key])
        else
          errors[:errors] << "error: MISSING_SETTING_KEY_VALUE, message: Setting Key #{key}=> value empty"
        end
      end
    end

    def str_uri(term)
      "#{@uri}#{@path}?q=#{URI.escape(term)}&location=#{@location}"
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
