class ApplicationJob < ActiveJob::Base
  include SuckerPunch::Job

  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  discard_on(StandardError) do |job, error|
    p "Job #{job} failed with error #{error}"
  end
end
