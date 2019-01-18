class Capitalist < CreditCard
  attr_accessor :balance

  TAXES = {
    static_put: 1,
    unstatic_put: 0,
    static_sender: 0,
    unstatic_sender: 1
  }.freeze

  def withdraw_tax
    96
  end

  def put_tax
    10
  end

  def sender_tax
    90
  end
end
