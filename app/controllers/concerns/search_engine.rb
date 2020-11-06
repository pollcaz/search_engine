module Concerns
  module SearchEngine
    extend ActiveSupport::Concern
    SUCCESS = 200
    BAD_REQUEST = 400

    private

    def do_search
      if searching_on_google?
        searching_on_google
      elsif searching_on_bing?
        searching_on_bing
      elsif searching_on_both?
        searching_on_google_and_bing
      end
    end

    def real_status(results)
      results.map {|r| r[:failed]}.any?(true) ? BAD_REQUEST : SUCCESS
    end

    def searching_on_google_and_bing
      [searching_on_google, searching_on_bing].flatten
    end

    def searching_on_google
      [{
        engine:    'google',
        recordset: search_engine_google.search(search_params[:text], search_params[:start_index]),
        failed:    search_engine_google.errors?
      }]
    end

    def searching_on_bing
      [{
        engine:    'bing',
        recordset: search_engine_bing.search(search_params[:text], search_params[:start_index]),
        failed:    search_engine_bing.errors?
      }]
    end

    def search_engine_google
      @search_engine_google ||= ::SearchEngines::Google.new
    end

    def search_engine_bing
      @search_engine_bing ||= ::SearchEngines::Bing.new
    end

    def searching_on_bing?
      search_params[:engine].downcase.eql?('bing')
    end

    def searching_on_google?
      search_params[:engine].downcase.eql?('google')
    end

    def searching_on_both?
      search_params[:engine].downcase.eql?('both')
    end
  end
end

