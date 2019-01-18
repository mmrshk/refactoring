class Usual < CreditCard
  attr_accessor :balance

  TAXES = {
    static_put: 0,
    unstatic_put: 1,
    static_sender: 1,
    unstatic_sender: 0
  }.freeze

  def withdraw_tax
    95
  end

  def put_tax
    80
  end

  def sender_tax
    20
  end
end
