module Api
  module V1
    class SearchController < ApplicationController
      SEARCH_VALID_PARAMETERS = %w[google bing both].freeze
      before_action :validate_params, only: :index

      def index
        res =  { response: 'Ok', engine: search_params[:engine] }
        render json: res, status: 200
      end

      private

      def validate_params
        v1_respond_with_payload unless params[:engine] && SEARCH_VALID_PARAMETERS.include?(params[:engine])
      end

      def search_params
        params.permit(:engine)
      end

      def v1_respond_with_payload(args = {})
        render json: { error: 'Bad Request', code: 'BAD_PARAMETERS' }, status: 401
      end
    end
  end
end

