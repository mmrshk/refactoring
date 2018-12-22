class Virtual < CreditCard
  attr_accessor :balance

  TAXES = {
    withdraw: 0.88,
    put: 1,
    sender: 1
  }.freeze

  BALANCE = 150.0

  def initialize
    @balance = BALANCE
    @type = CARD_TYPES[:virtual]
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
