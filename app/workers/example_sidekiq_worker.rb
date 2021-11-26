class ExampleSidekiqWorker
  include Sidekiq::Worker

  def perform(test_string)
    ExampleSidekiqWorker.execute!(test_string)
  end

  def self.execute!(test_string)
    Rails.logger.info "ExampleSidekiqWorker: #{test_string}"
  end
end
