class SpeakersController < ApplicationController

  def index
    @speakers = system.speakers
  end

  def rescan
    system.rescan
    redirect_to speakers_path
  end

  def show
    @speaker = system.speakers.find{|speaker| speaker.uid == params[:id] }
    @sounds = Dir.glob(assets_directory + '/**').map{|t| File.basename(t) }
  end

  def play
    speaker = system.speakers.find{|speaker| speaker.uid == params[:id] }
    sound = params[:sound] || 'scary'

    ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address
    uri = "http://#{ip}:3000/assets"

    GhostWorker.new.async.perform(speaker.uid, sound, uri, assets_directory)

    redirect_to speaker_path(speaker.uid)
  end

  private

  def system
    Ghosty::Application.system
  end

  def assets_directory
    @assets_directory ||= File.join(Rails.root, 'app', 'assets', 'audio')
  end

end
