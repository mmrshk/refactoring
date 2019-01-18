class CreditCard
  attr_reader :balance, :number, :type
  CARD_NUMBER_LENGTH = 16
  CARD_TYPES = {
    usual: 'usual',
    capitalist: 'capitalist',
    virtual: 'virtual'
  }.freeze

  BALANCE = {
    usual: 50.0,
    capitalist: 100.0,
    virtual: 150.0
  }.freeze

  def initialize
    @number = generate_card_number
    @balance = BALANCE[current_class.to_sym]
    @type = CARD_TYPES[current_class.to_sym]
  end

  def withdraw_tax
    raise NotImplementedError
  end

  def put_tax
    raise NotImplementedError
  end

  def sender_tax
    raise NotImplementedError
  end

  def withdraw_money(money_amount)
    @balance = @balance - money_amount - (1 - withdraw_tax / 100) * money_amount
  end

  def new_balance(money)
    @balance = money
  end

  def put_money(money_amount)
    @balance = @balance + money_amount - (put_tax * money_amount * TAXES[:static_put] + (1 - put_tax / 100) *
               money_amount * TAXES[:unstatic_put])
  end

  def sender_balance(money_amount)
    @balance = @balance - money_amount - (sender_tax * money_amount * TAXES[:static_sender] + (1 - sender_tax / 100) *
               money_amount * TAXES[:unstatic_sender])
  end

  def recipient_balance(money_amount)
    @balance = @balance + money_amount - put_tax(money_amount)
  end

  private

  def generate_card_number
    Array.new(CARD_NUMBER_LENGTH) { rand(10) }.join
  end

  def current_class
    self.class.to_s.downcase
  end
end
