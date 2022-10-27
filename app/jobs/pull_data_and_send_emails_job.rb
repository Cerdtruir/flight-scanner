class PullDataAndSendEmailsJob < ApplicationJob
  include SuckerPunch::Job

  def perform
    loop do
      ActiveRecord::Base.connection_pool.with_connection do
        LiftJob.perform_now
        FlysafairJob.perform_now
        SendEmailsJob.perform_now
      end
      sleep 15.minutes
    end
  end
end
