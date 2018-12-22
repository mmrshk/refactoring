class Account
  attr_reader :age, :login, :password, :name, :validator, :current_account, :cards

  def initialize
    @validator = Validators::Account.new
  end

  def create(name:, age:, login:, password:)
    @name = name
    @age = age
    @login = login
    @password = password
    @validator.validate(self)

    @cards = []
  end

  def errors_list
    @validator.puts_errors
  end

  def accounts
    return YAML.load_file(Storage::FILE_PATH) if File.exists?(Storage::FILE_PATH)

    []
  end

  def match?(login, password)
    accounts.map { |a| { login: a.login, password: a.password } }.include?({ login: login, password: password })
  end

  def set_current_account(login)
    @current_account = accounts.select { |a| login == a.login }.first
  end

  def add_current_account
    new_accounts = accounts << self
    @current_account = self
  end

  def destroy_account
    new_accounts = []
    accounts.each do |ac|
      new_accounts.push(ac) if ac.login != @current_account.login
    end

    new_accounts
  end

  def add_new_accounts
    new_accounts = []
    accounts.each do |ac|
      if ac.login == @current_account.login
        new_accounts.push(@current_account)
      else
        new_accounts.push(ac)
      end
    end

    new_accounts
  end

  def valid_input?(answer)
    @validator.validate_input(answer, @current_account)
  end

  def create_card(type)
    case type
    when CreditCard::CARD_TYPES[:usual] then @current_account.cards << Usual.new
    when CreditCard::CARD_TYPES[:capitalist] then @current_account.cards << Capitalist.new
    when CreditCard::CARD_TYPES[:virtual] then @current_account.cards << Virtual.new
    end
  end

  def delete_card(answer)
    @current_account.cards.delete_at(answer.to_i - 1)
  end

  def money_left(card_index, money_amount)
    current_card = @current_account.cards[card_index.to_i - 1]
    binding.pry
    current_card[:balance] - money_amount - @current_account.cards.withdraw_tax('virtual', money_amount)


  end
end
