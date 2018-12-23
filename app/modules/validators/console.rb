class Validators::Console
  MIN_LENGTH = 15
  MAX_LENGTH = 17

  def positive?(value)
    value.positive?
  end

  def card_valid?(card_number)
    card_number.length > MIN_LENGTH && card_number.length < MAX_LENGTH
  end

  def card_exist?(all_cards, card_number)
    all_cards.select { |card| card.number == card_number }.any?
  end
end
