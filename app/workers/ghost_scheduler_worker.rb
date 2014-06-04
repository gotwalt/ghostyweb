require 'sucker_punch'

class GhostSchedulerWorker
  include SuckerPunch::Job
  MIN_FREQUENCY = 45

  def perform(*args)
    wait = (MIN_FREQUENCY + rand(120)) * 0.5
    cache.set 'ghosty.next', Time.now + wait

    # wait
    after(wait) do
      cache.set 'ghosty.previous', Time.now
      # do the work
      GhostWorker.new.perform(sound: 'scary')
      # restart the clock
      GhostSchedulerWorker.new.async.perform()
    end

  end

  def cache
    @cache ||= Dalli::Client.new
  end

end
