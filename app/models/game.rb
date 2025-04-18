class Game < ApplicationRecord
  belongs_to :user

  after_initialize :set_defaults
  before_create :set_game_number

  def set_defaults
    self.board ||= " " * 9
    self.current_player ||= "X"
    self.status ||= "in_progress"
    self.difficulty ||= "easy"
  end

  def set_game_number
    max_game_number = Game.where(user_id: user_id).maximum(:game_number) || 0
    self.game_number = max_game_number + 1
  end

  def play_move(index, user)
    return false unless user == self.user
    return false unless board[index] == " " && status == "in_progress"
    return false unless current_player == "X"

    board[index] = "X"
    finish_or_continue("O")
    save
  end

  def finish_or_continue(next_player)
    if winner
      self.status = "won_by_#{current_player}"
    elsif board_full?
      self.status = "draw"
    else
      self.current_player = next_player
      bot_play if next_player == "O"
    end
  end

  def bot_play
    if difficulty == "hard"
      move = find_best_move
    elsif difficulty == "medium"
      move = medium_strategy
    else
      move = find_random_move
    end

    board[move] = "O"

    if winner
      self.status = "won_by_O"
    elsif board_full?
      self.status = "draw"
    else
      self.current_player = "X"
    end

    save
  end

  def medium_strategy
    if rand < 0.5
      find_best_move
    else
      find_random_move
    end
  end


  def find_best_move
    winning_move = find_winning_move("O")
    return winning_move if winning_move

    blocking_move = find_winning_move("X")
    return blocking_move if blocking_move

    return 4 if board[4] == " "

    [0, 2, 6, 8].each do |i|
      return i if board[i] == " "
    end

    find_random_move
  end

  def find_winning_move(player)
    wins = [
      [0,1,2], [3,4,5], [6,7,8],
      [0,3,6], [1,4,7], [2,5,8],
      [0,4,8], [2,4,6]
    ]

    wins.each do |a, b, c|
      line = [board[a], board[b], board[c]]
      indices = [a, b, c]

      if line.count(player) == 2 && line.count(" ") == 1
        return indices[line.index(" ")]
      end
    end

    nil
  end

  def find_random_move
    move_list = board.chars.each_with_index.select { |val, _| val == " " }

    move_list[rand(0...move_list.count)]&.last
  end

  def winner
    wins = [
      [0,1,2], [3,4,5], [6,7,8],
      [0,3,6], [1,4,7], [2,5,8],
      [0,4,8], [2,4,6]
    ]
    wins.each do |a, b, c|
      if board[a] != " " && board[a] == board[b] && board[a] == board[c]
        return board[a]
      end
    end
    nil
  end

  def board_full?
    !board.include?(" ")
  end
end
