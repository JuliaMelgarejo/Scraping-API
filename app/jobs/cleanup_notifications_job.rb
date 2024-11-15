class CleanupNotificationsJob
  include Sidekiq::Job

  def perform
    Notification.delete_all
    Rails.logger.info "Tabla Notification limpiada a las #{Time.current}"
  end
end
