class Poker
  CARDS_ORDER = %w(2 3 4 5 6 7 8 9 10 J Q K A).freeze


  attr_reader :hands



  def initialize(hands)
    @hands = hands.map { |hand| Hand.new(hand) }
  end

  def best_hand
    # return @hands if hands.count == 1

    # a = hands.map(&:to_s)
    # puts "hands: -- #{a} --"
    # a = hands.sort.map(&:to_s)
    # puts "hands.sort: -- #{a} --"
    result = hands.sort!.slice hands.index(hands[-1]) || 0..-1
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
  COMBINATIONS_ORDER = [
    HIGH_CARD,
    ONE_PAIR,
    TWO_PAIR,
    THREE_OF_A_KIND,
    STRAIGHT,
    FLUSH,
    FULL_HOUSE,
    FOUR_OF_A_KIND,
    STRAIGHT_FLUSH
  ]

  attr_reader :cards, :original_cards

  def initialize(cards)
    @original_cards = cards
    @cards = cards.map { |card| Card.new(card) }.sort
  end

  def to_s
    original_cards
  end

  def <=>(hand)
    result = COMBINATIONS_ORDER.index(combination) <=> COMBINATIONS_ORDER.index(hand.combination)

    # puts " : result : #{result}"
    if result == 0
      # puts combination
      # puts (hand.combination)
      # puts "combination_cards : #{combination_cards}"
      # puts "hand.combination_cards : #{hand.combination_cards}"
      combination_cards.each_with_index do |card, index|
        # puts "card #{card.name} <=> hand.combination_cards[index] #{hand.combination_cards[index].name} : #{card <=> hand.combination_cards[index]}"
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
    if flash? && straight?
      return { STRAIGHT_FLUSH => cards }
    end

    if flash?
      return { FLUSH => cards }
    end

    if straight?
      return { STRAIGHT => cards }
    end

    if one_pair?
      return { ONE_PAIR => one_pair_cards }
    end

    if two_pair?
      return { TWO_PAIR => two_pair_cards }
    end

    if three_of_a_kind?
      return { THREE_OF_A_KIND => three_of_a_kind_cards }
    end

    if full_house?
      return { FULL_HOUSE => full_house_cards }
    end

    if four_of_a_kind?
      return { FOUR_OF_A_KIND => four_of_a_kind_cards }
    end

    { HIGH_CARD => cards }
  end

  private

  def one_pair?
    cards.group_by(&:name).size == 4
  end

  def one_pair_cards
    grouped_cards = cards.group_by(&:name).sort_by{ |_, v| v.length }
    grouped_cards.first(3).map(&:last).flatten.sort + grouped_cards.last.last
  end

  def two_pair?
    cards.group_by(&:name).values.map(&:count).sort == [1, 2, 2]
  end

  def two_pair_cards
    grouped_cards = cards.group_by(&:name).sort_by{ |_, v| v.length }
    grouped_cards.first.last + grouped_cards.last(2).map(&:last).flatten.sort
  end

  def three_of_a_kind?
    cards.group_by(&:name).values.map(&:count).sort == [1, 1, 3]
  end

  def three_of_a_kind_cards
    grouped_cards = cards.group_by(&:name).sort_by{ |_, v| v.length }
    grouped_cards.first(2).map(&:last).flatten.sort + grouped_cards.last.last
  end

  def full_house?
    cards.group_by(&:name).values.map(&:count).sort == [2, 3]
  end

  def full_house_cards
    grouped_cards = cards.group_by(&:name).sort_by{ |_, v| v.length }
    grouped_cards.first.last + grouped_cards.last.last
  end

  def four_of_a_kind?
    cards.group_by(&:name).values.map(&:count).sort == [1, 4]
  end

  def four_of_a_kind_cards
    grouped_cards = cards.group_by(&:name).sort_by{ |_, v| v.length }
    grouped_cards.first.last + grouped_cards.last.last
  end

  def flash?
    cards.group_by(&:suite).size == 1
  end

  def straight?
    if ace_to_five_straight?
      change_card_order_for_ace_to_five_straight
      return true
    end

    straights = Card::ORDER.each_cons(5)
    straights.include?(cards.map(&:name))
  end

  def ace_to_five_straight?
    Card::ACE_TO_FIVE_ORDER.sort == cards.map(&:name)
  end

  def change_card_order_for_ace_to_five_straight
    @cards = cards.unshift(cards.pop)
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

