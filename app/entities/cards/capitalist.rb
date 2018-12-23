class Capitalist < CreditCard
  attr_accessor :balance

  TAXES = {
    withdraw: 0.04,
    put: 10,
    sender: 0.1
  }.freeze

  BALANCE = 100.0

  def initialize
    @balance = BALANCE
    @type = CARD_TYPES[:capitalist]
    super()
  end

  def withdraw_tax(amount)
    amount * TAXES[:withdraw]
  end

  def put_tax(amount)
    amount * TAXES[:put]
  end

  def sender_tax
    TAXES[:sender]
  end
end
