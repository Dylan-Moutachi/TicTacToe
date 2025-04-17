# spec/factories/games.rb
FactoryBot.define do
  factory :game do
    user
    board { " " * 9 }
    current_player { "X" }
    status { "in_progress" }
    difficulty { "easy" }

    trait :with_winner do
      status { "won_by_X" }
    end

    trait :finished do
      status { "draw" }
    end
  end
end
