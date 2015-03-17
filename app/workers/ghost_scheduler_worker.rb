require 'sidekiq/api'

class GhostSchedulerWorker
  include Sidekiq::Worker
  FREQUENCY = 45

  def perform(scheduled_at)
    scheduled_at = Time.parse(scheduled_at)
    GhostWorker.new.perform('sound' => Rails.application.secrets.sound) unless scheduled_at < 5.minutes.ago # don't run old scheduled ones
    GhostSchedulerWorker.schedule!
  end

  def self.schedule!
    clear_existing_jobs

     wait = (FREQUENCY + rand(FREQUENCY * 2))
     GhostSchedulerWorker.perform_in wait.minutes, Time.now + wait.minutes
  end

  def self.next_at
    existing_jobs.first.try(:at)
  end


  def self.clear_existing_jobs
    existing_jobs.map(&:delete)
  end

  def self.existing_jobs
    delayed = Sidekiq::ScheduledSet.new
    delayed.map do |job|
      job if job.klass == 'GhostSchedulerWorker'
    end.compact
  end

end
