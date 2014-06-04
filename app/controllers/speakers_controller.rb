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
    @sounds = Dir.glob(File.join(Rails.root, 'app', 'assets', 'audio', '**')).map{|t| File.basename(t) }
  end

  def play
    speaker = system.speakers.find{|speaker| speaker.uid == params[:id] }
    sound = params[:sound] || 'scary'

    GhostWorker.perform_async(speaker: speaker.uid, sound: sound)

    redirect_to speaker_path(speaker.uid)
  end

  private

  def system
    Ghosty::Application.system
  end

end
