require 'swagger_helper'

RSpec.describe 'api/v1/search_controller', type: :request do
  describe 'Search using Google & Bing Engines' do
    path '/api/v1/search?engine={engine}&text={text}&start_index={start_index}' do
      get 'Returns Google, Bing or Both results from search' do
        tags 'Search Engines'
        consumes 'application/json'
        parameter name: :engine, in: :path, type: :string, required: true, description: 'name of the search engine to use', example: 'google'
        parameter name: :text, in: :path, type: :string, required: true, description: 'what are you looking in your the search'
        parameter name: :start_index, in: :path, type: :integer, required: false, description: 'index to start to return the results from the current search', example: 31
        # security [ basic_auth: [] ]
        # let(:Authorization) { "Basic #{::Base64.strict_encode64('jsmith:jspass')}" }


        response '200', 'Google Search' do
          # schema type: :object,
          #       properties: {
          #         engine:        { type: :string },
          #         recordmatches: { type: :integer },
          #         offset:        { type: :integer },
          #         total:         { type: :integer },
          #         items:         { type: :object,
          #                            properties: {
          #                               index_order: { type: :integer },
          #                               title:       { type: :string },
          #                               link:        { type: :string },
          #                               snippet:     { type: :string }
          #                            }
          #         }
          #       },
          #       required: [ 'engine', 'recordmatches', 'offset', 'total', 'items' ]
          let(:engine) { 'google' }
          let(:text) { 'Ruby on Rails' }
          let(:start_index) { 21 }
          run_test!
        end

        response '401', 'Bad Request' do
          schema type: :object,
            properties: {
              error:        { type: :string },
              code:         { type: :string }
            },
            required: [ 'error', 'code']

          let(:engine) { 'google' }
          let(:text) { 'Ruby' }
          let(:start_index) { -10 }
          run_test!
        end

        response '401', 'Unauthorized' do
          schema type: :object,
            properties: {
              error:        { type: :string },
              code:         { type: :string }
            },
            required: [ 'error', 'code']

          let(:engine) { 'google1' }
          let(:text) { 'ruby' }
          let(:start_index) { 21 }
          run_test!
        end
      end
    end
  end
end
