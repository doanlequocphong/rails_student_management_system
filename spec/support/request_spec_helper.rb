module RequestSpecHelper
  # Đặt host thành "localhost" cho tất cả request specs
  # Tránh lỗi ActionDispatch::HostAuthorization với www.example.com (default của RSpec)
  def self.included(base)
    base.before { host! "localhost" }
  end
end

RSpec.configure do |config|
  config.include RequestSpecHelper, type: :request
end
