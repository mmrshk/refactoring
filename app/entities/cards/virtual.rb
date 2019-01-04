class Virtual < CreditCard
  attr_accessor :balance

  TAXES = {
    static_put: 1,
    unstatic_put: 0,
    static_sender: 1,
    unstatic_sender: 0
  }.freeze

  BALANCE = 150.0

  def initialize
    @balance = BALANCE
    @type = CARD_TYPES[:virtual]
    super()
  end

  def withdraw_tax
    12
  end

  def put_tax
    1
  end

  def sender_tax
    1
  end
end
