require 'rufus-scheduler'

Rufus::Scheduler.singleton.every '30m' do
  LiftJob.perform_now
  FlysafairJob.perform_now
  SendEmailsJob.perform_now
end
