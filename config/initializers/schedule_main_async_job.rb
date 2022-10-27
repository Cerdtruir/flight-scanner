Rails.application.configure do
  config.after_initialize do
    PullDataAndSendEmailsJob.perform_async
  end
end
