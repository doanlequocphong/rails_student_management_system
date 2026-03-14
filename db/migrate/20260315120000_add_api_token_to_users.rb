class AddApiTokenToUsers < ActiveRecord::Migration[7.1]
  def change
    # api_token: chuỗi ngẫu nhiên — dùng để xác thực API requests
    # index unique: mỗi token là duy nhất, tra cứu nhanh
    add_column :users, :api_token, :string
    add_index  :users, :api_token, unique: true
  end
end
