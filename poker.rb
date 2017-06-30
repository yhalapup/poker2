class Poker
  CARDS_ORDER = %w(2 3 4 5 6 7 8 9 10 J Q K A).freeze


  attr_reader :hands



  def initialize(hands)
    @hands = hands.map { |hand| Hand.new(hand) }
  end

  def best_hand
    # return @hands if hands.count == 1

    result = [hands.sort.first]
    result.map(&:to_s)
  end


end

class Hand
  include Comparable

  STRAIGHT_FLUSH = 'STRAIGHT_FLUSH'.freeze
  FOUR_OF_A_KIND = 'FOUR_OF_A_KIND'.freeze
  FULL_HOUSE = 'FULL_HOUSE'.freeze
  FLUSH = 'FLUSH'.freeze
  STRAIGHT = 'STRAIGHT'.freeze
  THREE_OF_A_KIND = 'THREE_OF_A_KIND'.freeze
  TWO_PAIR = 'TWO_PAIR'.freeze
  ONE_PAIR = 'ONE_PAIR'.freeze
  HIGH_CARD = 'HIGH_CARD'.freeze
  COMBINATIONS_ORDER = [STRAIGHT_FLUSH, FOUR_OF_A_KIND, FULL_HOUSE, FLUSH, STRAIGHT, THREE_OF_A_KIND, TWO_PAIR, ONE_PAIR, HIGH_CARD]

  attr_reader :cards

  def initialize(cards)
    @cards = cards.map { |card| Card.new(card) }.sort
  end

  def to_s
    @cards.map(&:to_s)
  end

  def <=>(hand)
    result = COMBINATIONS_ORDER.index(combination) <=> COMBINATIONS_ORDER.index(hand.combination)

    puts " : result : #{result}"
    if result == 0
      combination_cards.each_with_index do |card, index|
        puts "card #{card.name} <=> hand.combination_cards[index] #{hand.combination_cards[index].name} : #{card <=> hand.combination_cards[index]}"
        next if (card <=> hand.combination_cards[index]) == 0

        return card <=> hand.combination_cards[index]
      end
    end
    result
  end

  def combination
    combination_data.keys.first
  end

  def combination_cards
    combination_data.values.first.reverse
  end

  def combination_data
    if flash?
      return { FLUSH => cards }
    end

    if straight?
      return { STRAIGHT => cards }
    end

    { HIGH_CARD => cards }
  end

  private

  def flash?
    cards.group_by(&:suite).size == 1
  end

  def straight?
    if ace_to_five_straight?
      change_card_order_for_ace_to_five_straight
      return true
    end

    straights = Card::ORDER.each_cons(5)
    straights.include?(to_s) && ace_to_five_straight?
  end

  def ace_to_five_straight?
    Card::ACE_TO_FIVE_ORDER.sort == to_s
  end

  def change_card_order_for_ace_to_five_straight
    @cards = card.unshift(card.pop)
  end
end


class Card
  include Comparable

  ORDER = %w(2 3 4 5 6 7 8 9 10 J Q K A).freeze
  ACE_TO_FIVE_ORDER = %w(A 2 3 4 5).freeze
  SUITES = %w(S H C D).freeze

  attr_reader :name, :suite

  def initialize(data)
    @name = data[0..-2]
    @suite = data[-1]
  end

  def to_s
    [name, suite].join
  end

  def position
    ORDER.index(name)
  end

  def <=>(card)
    position <=> card.position
  end
end

