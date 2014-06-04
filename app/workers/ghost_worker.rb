require 'sucker_punch'
require 'sonos_extensions.rb'

class GhostWorker
  include SuckerPunch::Job

  attr_reader :system

  def perform(options = {})

    speaker = if options[:speaker]
      system.speakers.find{|speaker| speaker.uid == options[:speaker] }
    else
      random_speaker
    end

    volume = options[:volume] || (10 + rand(15))

    isolated_from_group(speaker) do |speaker|
      if speaker
        track = random_track(options[:sound])
        results = speaker.voiceover!(track, volume)
        Log.create(speaker_uid: speaker.uid, speaker_name: speaker.name, audio_uri: track, volume: volume, original_volume: results[:original_volume], duration: results[:duration], original_state: results[:original_state])
      end
    end

  end

  def isolated_from_group(speaker)
    old_group = system.groups.find{|group| group.slave_speakers.map(&:uid).include?(speaker.uid) }

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
    speaker = system.speakers.select do |speaker|
      !speaker.playing? && speaker.uid != previous_uid
    end.compact.sample

    previous_uid = speaker.uid if speaker

    speaker
  end

  # Finds a file to play and returns it as a URI
  def random_track(sound)
    assets_folder = File.join(Rails.root, 'app', 'assets', 'audio')
    file = Dir.glob(File.join(assets_folder, sound, '*.mp3')).sample

    if file
      ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address
      "http://#{ip}:#{Rails.application.secrets.port}/assets/#{sound}/" + File.basename(file)
    end
  end

  def previous_uid
    cache.get 'ghosty.previous_uid'
  end

  def previous_uid=(val)
    cache.set 'ghosty.previous_uid', val
  end

  def system
    Ghosty::Application.system
  end

  def cache
    @cache ||= Dalli::Client.new
  end

end
