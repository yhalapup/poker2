class Poker
  attr_reader :hands
  def initialize(hands)
    @hands = hands
  end

  def best_hand
    return @hands if hands.count == 1


  end
end
