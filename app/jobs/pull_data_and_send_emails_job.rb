class PullDataAndSendEmailsJob < ApplicationJob
  def perform
    loop do
      LiftJob.perform_async
      FlysafairJob.perform_async
      sleep 30.minutes
      SendEmailsJob.perform_now
    end
  end
end
