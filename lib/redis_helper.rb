class RedisHelper
  def self.url(path: nil)
    "redis://redis:6379/#{path}"
  end
end
