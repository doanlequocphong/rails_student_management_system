module Api
  module V1
    class BaseController < ActionController::API
      # ActionController::API không có ActionView theo mặc định.
      # Hai modules này cho phép render Jbuilder templates (.json.jbuilder).
      include ActionView::Layouts
      include ActionController::ImplicitRender

      include ActionController::HttpAuthentication::Token::ControllerMethods

      # Xác thực token trước tất cả actions
      before_action :authenticate_api_user!

      private

      # Kiểm tra header: Authorization: Bearer <token>
      def authenticate_api_user!
        authenticate_with_http_token do |token, _options|
          @current_api_user = User.find_by(api_token: token)
        end

        # Nếu không tìm được user → trả về 401 JSON
        unless @current_api_user
          render json: { error: "Unauthorized. Vui lòng cung cấp api_token hợp lệ." },
                 status: :unauthorized
        end
      end

      def current_api_user
        @current_api_user
      end

      # Tìm record, trả về 404 JSON nếu không có
      def not_found
        render json: { error: "Không tìm thấy bản ghi." }, status: :not_found
      end
    end
  end
end
