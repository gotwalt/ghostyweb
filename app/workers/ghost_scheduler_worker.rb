require 'sucker_punch'

class GhostSchedulerWorker
  include SuckerPunch::Job

  def perform
    wait_time = (MIN_FREQUENCY + rand(120)) * 60
    after(wait_time) do
      GhostWorker.new.perform()
    end
  end

end
