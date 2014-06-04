class Status
  attr_reader :previous
  attr_reader :next
  attr_reader :previous_speaker

  def initialize
    @previous = cache.get 'ghosty.previous'
    @next = cache.get 'ghosty.next'
    @previous_uid = cache.get 'ghosty.previous_uid'
  end

  def cache
    @cache ||= Dalli::Client.new
  end

end
