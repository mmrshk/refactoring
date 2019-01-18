module Validators
  class Console
    MIN_LENGTH = 15
    MAX_LENGTH = 17

    def card_valid?(card_number)
      card_number.length > MIN_LENGTH && card_number.length < MAX_LENGTH
    end

    def card_exist?(all_cards, card_number)
      all_cards.select { |card| card.number == card_number }.any?
    end

    def check_tax_highness(current_card, money_amount)
      current_card.put_tax * money_amount >= money_amount
    end

    def cards_invalid?(sender_card, recipient_card)
      sender_card.empty? || recipient_card.empty?
    end
  end
end
