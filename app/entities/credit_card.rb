class CreditCard
 attr_reader :balance, :number, :type

  CARD_TYPES = {
    usual: 'usual',
    capitalist: 'capitalist',
    virtual: 'virtual'
  }

  def initialize
    @number = generate_card_number
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
    @balance - money_amount - withdraw_tax(money_amount)
  end

  def set_new_balance(money)
    @balance = money
  end

  def put_money(money_amount)
    @balance + money_amount - put_tax(money_amount)
  end

  def sender_balance(money_amount)
    @balance - money_amount - sender_tax
  end

  def recipient_balance(money_amount)
    @balance + money_amount - put_tax(money_amount)
  end

  private

  def generate_card_number
    16.times.map{ rand(10) }.join
  end
end
