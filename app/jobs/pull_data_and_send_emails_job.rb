class PullDataAndSendEmailsJob < ApplicationJob
  queue_as :default

  def perform
    LiftJob.perform_now
    FlysafairJob.perform_now
    SendEmailsJob.perform_now
  end
end
