class Usual < CreditCard
  attr_accessor :balance

  TAXES = {
    withdraw: 0.05,
    put: 0.2,
    sender: 20
  }.freeze

  BALANCE = 50.0

  def initialize
    @balance = BALANCE
    @type = CARD_TYPES[:usual]
    super()
  end

  def to_h
    {
      type: @type,
      balance: @balance,
      number: @number
    }
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
