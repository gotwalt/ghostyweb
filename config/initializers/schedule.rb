next_at = GhostSchedulerWorker.next_at
# Don't reschedule if there's a valid one
unless next_at && next_at > 1.minute.from_now
  GhostSchedulerWorker.schedule!
  Rails.logger.warn "Scheduled first ghost for #{GhostSchedulerWorker.next_at}"
end
