require 'sucker_punch'
require 'sonos_extensions.rb'

class GhostWorker
  include SuckerPunch::Job

  attr_reader :system

  def perform(speaker_uid, sound, uri, assets)
    @system = Sonos::System.new
    @assets = assets
    @base_uri = uri

    speaker = if speaker_uid
      system.speakers.find{|speaker| speaker.uid == speaker_uid }
    else
      random_speaker
    end

    isolated_from_group(speaker) do |speaker|
      speaker.voiceover! random_track(sound) if speaker
    end
  end

  def isolated_from_group(speaker)
    old_group = @system.groups.find{|group| group.slave_speakers.map(&:uid).include?(speaker.uid) }

    if old_group
      old_master = speaker.group_master
      old_group.disband
    end

    yield speaker

    if old_group
      old_group.slave_speakers.each do |speaker|
        speaker.join old_master
      end
    end
  end

  def random_speaker
    speaker = @system.speakers.select do |speaker|
      !speaker.playing? && speaker.uid != @previous_uid
    end.compact.sample

    @previous_uid = speaker.uid if speaker

    speaker
  end

  # Finds a file to play and returns it as a URI
  def random_track(sound)
    file = Dir.glob(File.join(@assets, sound, '*.mp3')).sample

    if file
      uri = URI.parse(@base_uri)
      uri.path += "/#{sound}/" + File.basename(file)

      uri.to_s
    end
  end

end
