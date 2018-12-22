class CreditCard
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

  def to_h
    raise NotImplementedError
  end

  private

  def generate_card_number
    16.times.map{ rand(10) }.join
  end
end
