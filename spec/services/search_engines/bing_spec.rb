require 'rails_helper'

RSpec.describe SearchEngines::Bing do
  it_behaves_like 'search engine', described_class
end
