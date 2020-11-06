module Api
  module V1
    class SearchController < ApplicationController
      include ::Concerns::SearchEngine

      SEARCH_VALID_PARAMETERS = %w[google bing both].freeze
      before_action :validate_params, only: :index

      def index
        results = do_search
        parse_results =
          SearchEngines::DataParser.build_json_response(results, search_params[:start_index] || 0)
  
        render json: parse_results, status: real_status(results)
      end

      private

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
        render json: { error: 'Bad Request', code: 'MISSING_OR_INVALID_ARGUMENTS' }, status: 401
      end
    end
  end
end

