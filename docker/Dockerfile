# Base image: Ruby 3.2 chạy trên Alpine Linux (nhẹ hơn)
FROM ruby:3.2.10-alpine

# Cài các package hệ thống cần thiết
RUN apk add --no-cache \
  build-base \
  postgresql-dev \
  nodejs \
  yarn \
  tzdata \
  git \
  yaml-dev \
  libxml2-dev \
  libxslt-dev

# Đặt thư mục làm việc bên trong container
WORKDIR /app

# Copy Gemfile trước để tận dụng Docker cache
COPY Gemfile* ./

# Cài gems
RUN bundle install && bundle binstubs bundler --force

# Copy toàn bộ source code vào container
COPY . .

# Expose port 3000 (Rails mặc định)
EXPOSE 3000

# Lệnh mặc định khi container khởi động
CMD ["rails", "server", "-b", "0.0.0.0"]
