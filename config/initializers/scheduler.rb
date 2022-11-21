require 'rufus-scheduler'

Rufus::Scheduler.singleton.every '30s' do
  LiftJob.perform_now
  FlysafairJob.perform_now
  SendEmailsJob.perform_now
end
