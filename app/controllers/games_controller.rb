class GamesController < ApplicationController
  before_action :authenticate_user!

  def index
    @games = current_user.games
  end

  def new
    @game = current_user.games.build
  end

  def create
    @game = current_user.games.create(game_params)
    if @game.save
      redirect_to @game
    else
      render :new
    end
  end

  def show
    @game = current_user.games.find(params[:id])
  end

  def play
    @game = current_user.games.find(params[:id])

    if @game.current_player == "X"
      @game.play_move(params[:index].to_i, current_user)
    end

    if @game.current_player == "O"
      @game.finish_or_continue("X")
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(@game, partial: "games/board", locals: { game: @game })
      end
      format.html { redirect_to @game }
    end
  end

  private

  def game_params
    params.require(:game).permit(:difficulty)
  end
end
