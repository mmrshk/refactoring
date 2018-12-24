class Account
  attr_reader :age, :login, :password, :name, :validator, :current_account, :cards, :storage

  def initialize
    @validator = Validators::Account.new
    @storage = Storage.new
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

  def match?(login, password)
    @storage.load_accounts.map { |account| { login: account.login, password: account.password } }.include?(login: login, password: password)
  end

  def select_current_account(login)
    @current_account = @storage.load_accounts.select { |account| login == account.login }.first
  end

  def add_current_account
    @current_account = self
    @storage.save(@storage.load_accounts << self)
  end

  def destroy_account
    accounts = @storage.load_accounts
    accounts.reject! { |account| account.login == @current_account.login }
    save(accounts)
  end

  def save_changed_accounts
    accounts = []

    @storage.load_accounts.each do |account|
      account.login == @current_account.login ? accounts.push(@current_account) : accounts.push(account)
    end

    @storage.save(accounts)
  end

  def save_recepient(recipient, recipient_card)
    new_recipient_cards = []

    recipient.cards.each do |card|
      card.balance = recipient_balance if card.number == recipient_card

      new_recipient_cards.push(card)
    end

    recipient
  end

  def save_after_money_transfer_transaction(recipient_card)
    new_accounts = []
    @storage.load_accounts.each do |account|
      if account.login == @current_account.login
        new_accounts.push(@current_account)
      elsif account.cards.map(&:number).include? recipient_card
        recipient = save_recepient(account, recipient_card)
        recipient.cards = new_recipient_cards
        new_accounts.push(recipient)
      end
    end

    @storage.save(new_accounts)
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

    save_changed_accounts
  end

  def delete_card(answer)
    @current_account.cards.delete_at(answer.to_i - 1)
    save_changed_accounts
  end

  def current_card(card_index)
    @current_account.cards[card_index.to_i - 1]
  end
end
