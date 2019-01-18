class Account
  attr_reader :age, :login, :password, :name, :validator, :account, :cards, :storage

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

  def add_account
    @storage.save(@storage.load_accounts << self)
  end

  def destroy_account
    accounts = @storage.load_accounts
    accounts.reject! { |account| account.login == login }
    @storage.save(accounts)
  end

  def save_changed_accounts
    accounts = @storage.load_accounts.map do |account|
      account.login == login ? self : account
    end

    @storage.save(accounts)
  end

  def save_recepient(recipient, recipient_card)
    recipient.cards.each do |card|
      card.balance = recipient_balance if card.number == recipient_card
    end

    recipient
  end

  def save_after_money_transfer_transaction(recipient_card)
    new_accounts = @storage.load_accounts.map do |account|
      if account.login == login
        self
      elsif card_contains(recipient_card)
        recipient = save_recepient(account, recipient_card)
        recipient.cards = new_recipient_cards
        recipient
      end
    end

    @storage.save(new_accounts)
  end

  def valid_input?(answer)
    @validator.validate_input(answer, self)
  end

  def card_contains(recipient_card)
    account.cards.map(&:number).include? recipient_card
  end

  def create_card(type)
    case type
    when CreditCard::CARD_TYPES[:usual] then cards << Usual.new
    when CreditCard::CARD_TYPES[:capitalist] then cards << Capitalist.new
    when CreditCard::CARD_TYPES[:virtual] then cards << Virtual.new
    end

    save_changed_accounts
  end

  def destroy_card(answer)
    cards.delete_at(answer.to_i - 1)
    save_changed_accounts
  end

  def current_card(card_index)
    cards[card_index.to_i - 1]
  end
end
