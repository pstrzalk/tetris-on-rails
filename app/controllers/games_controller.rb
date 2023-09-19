class GamesController < ApplicationController
  def index
    @game = current_game
    @top_score_games = Game.where.not(email: [nil, '']).order(score: :desc).limit(5)
  end

  def create
    if current_game
      redirect_to play_games_path

      return
    end

    if Flag.too_much_traffic?
      flash[:error] = 'Too many players, please try in a while'
      redirect_to games_path

      return
    end

    game = Game.build_for_player(@player_id)
    game.save!

    redirect_to play_games_path(@game)
  end

  def play
    @game = current_game

    return if @game

    flash[:error] = "You don't have any active games at the moment"
    redirect_to games_path
  end

  def register
    @game = Game.find_by(player_id: @player_id, running: false, id: params[:id])

    if @game
      email_param = params.dig(:game, :email)
      nickname_param = params.dig(:game, :nickname)

      if email_param.present?
        @game.update(email: email_param, nickname: nickname_param)
        flash[:notice] = 'Thank you for registering your score. We will contact you if you win!'

        redirect_to games_path
      else
        flash[:error] = 'Email address missing. We cannot contact you if we do not have your email!'

        redirect_to game_path(@game)
      end
    else
      flash[:error] = 'Game not found'

      redirect_to games_path
    end
  end

  def move_left
    @game = current_game

    if @game
      @game.register_action(Action::MOVE_LEFT)
      @game.save
    end

    render json: {}
  end

  def move_right
    @game = current_game

    if @game
      @game.register_action(Action::MOVE_RIGHT)
      @game.save
    end

    render json: {}
  end

  def rotate
    @game = current_game

    if @game
      @game.register_action(Action::ROTATE)
      @game.save
    end

    render json: {}
  end

  def answer
    @game = current_game

    if @game
      answer = params.dig(:game, :answer)

      @game.answer(answer)
      @game.save
    end

    render json: {}
  end

  private

  def current_game
    @current_game ||= Game.find_by(player_id: @player_id, running: true)
  end
end
