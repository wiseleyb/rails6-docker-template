# config/initializers/pusher.rb

require 'pusher'

Pusher.app_id = 'SNZOd57pK4jG9zcVrcCoCCxqVlATywz_B0sf0RqWbcI'
Pusher.key = 'somekey'
Pusher.secret = 'somesecret'
Pusher.cluster = 'us'
Pusher.logger = Rails.logger
Pusher.encrypted = true
