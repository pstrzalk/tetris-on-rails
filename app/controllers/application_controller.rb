class ApplicationController < ActionController::Base
  before_action :identify_player

  def identify_player
    @player_id = cookies.permanent[:player_id]
    @player_id ||= SecureRandom.uuid

    cookies.permanent[:player_id] = @player_id
  end
end
