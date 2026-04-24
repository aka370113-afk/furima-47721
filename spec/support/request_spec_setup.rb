# frozen_string_literal: true

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request

  config.before(:each, type: :request) do
    allow_any_instance_of(ApplicationController).to receive(:basic_auth)
  end
end
