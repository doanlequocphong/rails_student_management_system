require "spec_helper"
ENV["RAILS_ENV"] ||= "test"

require_relative "../config/environment"
require "rspec/rails"

# Load tất cả files trong spec/support/
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  # FactoryBot — dùng create/build trực tiếp mà không cần FactoryBot.create
  config.include FactoryBot::Syntax::Methods

  # Database Cleaner — reset DB trước mỗi test (nếu dùng DatabaseCleaner)
  # Không cần gem thêm — Rails test DB được wrap trong transaction tự động
  config.use_transactional_fixtures = true

  # Tự detect loại spec từ thư mục
  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!
end
