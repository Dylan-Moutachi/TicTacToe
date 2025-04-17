require 'rails_helper'

RSpec.describe Game, type: :model do
  let(:user) { create(:user) }
  let(:game) { create(:game, user: user) }

  describe 'initialization' do
    it 'should initialize board with 9 empty spaces' do
      expect(game.board).to eq("         ")
    end

    it 'should set current player to X' do
      expect(game.current_player).to eq("X")
    end

    it 'should set status to in_progress' do
      expect(game.status).to eq("in_progress")
    end

    it 'should set difficulty to easy' do
      expect(game.difficulty).to eq("easy")
    end
  end

  describe '#play_move' do
    it 'allows player to make a move' do
      game.play_move(0, user)
      expect(game.board[0]).to eq("X")
    end

    it 'does not allow move if spot is taken' do
      game.play_move(0, user)
      game.play_move(0, user)
      expect(game.board[0]).to eq("X")
    end

    it 'does not allow move if game is over' do
      game.status = "draw"
      game.play_move(1, user)
      expect(game.board[1]).to eq(" ")
    end

    it 'does not allow move if not player X' do
      game.current_player = "O"
      game.play_move(0, user)
      expect(game.board[0]).to eq(" ")
    end
  end

  describe '#finish_or_continue' do
    it 'sets the status to "won_by_X" if X wins' do
      game.board = "XXX      "
      game.finish_or_continue("O")
      expect(game.status).to eq("won_by_X")
    end

    it 'sets the status to "draw" if board is full and no winner' do
      game.board = "XOXOXOOXO"
      game.finish_or_continue("O")
      expect(game.status).to eq("draw")
    end

    it 'switches the current player if game continues' do
      game.board = "XOXOXXO  "
      game.finish_or_continue("O")
      expect(game.board.chars.map {|letter| letter == "O"}.count(true)).to eq(4)
    end
  end

  describe '#bot_play' do
    context 'when difficulty is hard' do
      it 'chooses the best move' do
        game.difficulty = "hard"
        game.board = "XOXOXOX  "
        game.bot_play
        expect(game.board[8]).to eq("O")
      end
    end

    context 'when difficulty is medium' do
      it 'alternates between optimal and random moves' do
        game.difficulty = "medium"
        game.board = "XOXOXOX  "

        first_move = game.board.dup
        game.bot_play
        second_move = game.board

        expect(first_move).not_to eq(second_move)
      end
    end

    context 'when difficulty is easy' do
      it 'chooses a random move' do
        game.difficulty = "easy"
        game.board = "XOXOXOX  "
        game.bot_play
        expect(game.board).to match(/O/)
      end
    end
  end

  describe '#find_best_move' do
    it 'returns the blocking move for X' do
      game.board = "XOXOX  O "
      move = game.find_best_move
      expect(move).to eq(8)
    end

    it 'returns the winning move for O' do
      game.board = "OXXO X   "
      move = game.find_best_move
      expect(move).to eq(6)
    end

    it 'returns 4 if the center is available' do
      game.board = "XOXO     "
      move = game.find_best_move
      expect(move).to eq(4)
    end

    it 'returns a corner move if center is not available' do
      game.board = "XOXOX    "
      move = game.find_best_move
      expect([0, 2, 6, 8]).to include(move)
    end
  end

  describe '#winner' do
    it 'returns X if X wins' do
      game.board = "XXX      "
      expect(game.winner).to eq("X")
    end

    it 'returns O if O wins' do
      game.board = "OOO      "
      expect(game.winner).to eq("O")
    end

    it 'returns nil if no winner' do
      game.board = "XOXOXOOXO"
      expect(game.winner).to be_nil
    end
  end

  describe '#board_full?' do
    it 'returns true when board is full' do
      game.board = "XOXOXOXOX"
      expect(game.board_full?).to be true
    end

    it 'returns false when board is not full' do
      game.board = "XOXOXOX  "
      expect(game.board_full?).to be false
    end
  end
end
