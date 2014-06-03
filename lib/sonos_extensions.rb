require 'sonos'

module Sonos::Endpoint::AVTransport

  def voiceover!(uri, vol = nil)
    group_master.with_isolated_state do
      self.volume = vol if vol
      group_master.play_blocking(uri)
    end
  end

  protected

  def playing?
    state = get_player_state[:state]
    !['PAUSED_PLAYBACK', 'STOPPED'].include?(state)
  end

  def with_isolated_state
    pause if was_playing = playing?
    unmute if was_muted = muted?
    previous_volume = volume
    previous = now_playing

    yield

    # the sonos app does this. I think it tells the player to think of the master queue as active again
    play uid.gsub('uuid', 'x-rincon-queue') + '#0'

    if previous
      select_track previous[:queue_position]
      seek Time.parse("1/1/1970 #{previous[:current_position]} -0000" ).to_i

      self.volume = previous_volume
      mute if was_muted
    end

    play if was_playing
  end

  def play_blocking(uri)
    puts "Playing track #{uri} on speaker #{name}"

    # queue up the track
    play uri

    # play it
    play

    # pause the thread until the track is done
    sleep(0.1) while playing?
  end
end

module Sonos::Endpoint::AVTransport
  def select_track(index)
    parse_response send_transport_message('Seek', "<Unit>TRACK_NR</Unit><Target>#{index}</Target>")
  end
end
