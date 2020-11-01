module Api
  module V1
    class SearchController < ApplicationController
      SEARCH_VALID_PARAMETERS = %w[google bing both].freeze
      before_action :validate_params, only: :index

      def index
        results = do_search
        parse_results =
          SearchEngines::DataParser.build_json_response(results, search_params[:start_index] || 0)

        render json: parse_results, status: real_status(results)
      end

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
        results.map {|r| r[:failed]}.any?(true) ? 200 : 401
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

      def valid_start_index?
        if search_params[:start_index].present?
          /^\d+$/.match(search_params[:start_index]) ? true : false
        else
          true
        end
      end

      def validate_params
        unless params[:engine].present? &&
          SEARCH_VALID_PARAMETERS.include?(params[:engine]) &&
          params[:text].present? &&
          valid_start_index?

          v1_respond_with_payload
        end
      end

      def search_params
        params.permit(:engine, :text, :start_index)
      end

      def v1_respond_with_payload(args = {})
        render json: { error: 'Bad Request', code: 'MISSING_OR_INVALID_PARAMETERS' }, status: 401
      end
    end
  end
end

