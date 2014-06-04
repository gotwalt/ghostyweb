class Log < ActiveRecord::Base

  def speaker
    Ghosty::Application.system.speakers.find{|x| x.uid == speaker_uid } if speaker_uid
  end

end
