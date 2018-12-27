class Console < ConsoleHelpers
  attr_reader :login, :password, :card, :account, :renderer, :storage, :current_account

  def initialize
    @account = Account.new
    @validator = Validators::Console.new
    @storage = Storage.new
  end

  def load
    return create_the_first_account if @storage.load_accounts.none?

    loop do
      login = ask(:load_login)
      password = ask(:load_password)
      @account = @storage.select_current_account(login, password)

      break unless @account.nil?

      message(:load_error)
    end
    main_menu
  end

  def create_card
    message(:create_card_message)
    card_type = ask
    return message(:wrong_card_type) unless CreditCard::CARD_TYPES.key?(card_type.to_sym)

    @account.create_card(CreditCard::CARD_TYPES[card_type.to_sym])
  end

  def destroy_card
    return message(:active_card_error) if @account.cards.none?

    answer = select_card_to_delete
    return if answer.nil?

    accept_delete_card(answer)
  end

  def withdraw_money
    message(:choose_card_withdraw)
    return message(:active_card_error) if @account.cards.none?

    list_of_cards
    handle_withdraw_money
  end

  def put_money
    message(:choose_card_putting)
    return message(:active_card_error) if @account.cards.none?

    list_of_cards
    handle_puts_money
  end

  def send_money
    sender_card = choose_send_card
    recipient_card = choose_recipient_card

    return if [sender_card, recipient_card].nil?

    money_transfer_transaction(sender_card, recipient_card)
  end

  def create_account
    loop do
      @account.create(name: ask(:name_input),
                      age: ask(:age_input),
                      login: ask(:login_input),
                      password: ask(:password_input))
      break if @account.validator.valid?

      @account.errors_list
    end

    @account.add_account
    main_menu
  end

  def destroy_account
    message(:destroy_account)
    @account.destroy_account if ask == CHOOSE_COMMANDS[:yes]
  end

  def create_the_first_account
    message(:create_the_first_account)
    return create_account if ask == CHOOSE_COMMANDS[:yes]

    console
  end

  def show_cards
    return message(:active_card_error) if @account.cards.none?

    @account.cards.each { |card| message(:card_info, number: card.number, type: card.type) }
  end

  private

  def list_of_cards
    @account.cards.each_with_index { |card, i| message(:list_cards, card: card.number, type: card.type, index: i + 1) }

    message(:exit_msg)
  end

  def accept_delete_card(answer)
    message(:accept_delete_account, card_number: @account.current_card(answer).number)
    return if ask != CHOOSE_COMMANDS[:yes]

    @account.destroy_card(answer)
  end

  def select_card_to_delete
    message(:want_to_delete)
    list_of_cards
    answer = ask
    return if exit?(answer)

    return message(:wrong_number_input) unless @account.valid_input?(answer)

    answer
  end

  def handle_withdraw_money
    answer = ask
    return if exit?(answer)

    return message(:wrong_number_input) unless @account.valid_input?(answer)

    withdraw_money_amount(answer)
  end

  def withdraw_money_amount(card_index)
    current_card = @account.current_card(card_index)
    money_amount = ask(:withdraw_money_amount).to_i

    return message(:uncorrect_input_amount) unless @validator.positive?(money_amount)

    set_card_balance_after_withdraw(current_card.withdraw_money(money_amount), current_card)
    @account.save_changed_accounts
    message_withdraw(money_amount, current_card)
  end

  def set_card_balance_after_withdraw(money_left, current_card)
    return message(:not_enough_money) unless @validator.positive?(money_left)

    current_card.new_balance(money_left)
  end

  def handle_puts_money
    answer = ask
    return if exit?(answer)

    return message(:wrong_number_input) unless @account.valid_input?(answer)

    puts_money_amount(@account.current_card(answer))
  end

  def puts_money_amount(current_card)
    money_amount = ask(:puts_money_amount).to_i
    return message(:uncorrect_puts_input_amount) unless @validator.positive?(money_amount)

    return message(:high_tax_error) if @validator.tax_high?(current_card, money_amount)

    current_card.put_money(money_amount)
    message_put(money_amount, current_card)
    @account.save_changed_accounts
  end

  def choose_send_card
    message(:choose_send_card)
    return message(:active_card_error) if @account.cards.none?

    answer = handle_send_card
    return if answer.nil?

    @account.current_card(answer)
  end

  def handle_send_card
    list_of_cards
    answer = ask
    exit if exit?(answer)
    return message(:choose_correct_card) unless @account.valid_input?(answer)

    answer
  end

  def choose_recipient_card
    message(:enter_recipient_card)
    card_number = ask
    return message(:correct_number_card_error) unless @validator.card_valid?(card_number)

    all_cards = @storage.load_cards
    return message(:card_not_exist, number: card_number) unless @validator.card_exist?(all_cards, card_number)

    all_cards.select { |card| card.number == card_number }.first
  end

  def money_transfer_transaction(sender_card, recipient_card)
    message(:money_amount_to_withdraw)
    money_amount = ask.to_i
    return message(:wrong_number_input) unless @validator.positive?(money_amount)

    sender_balance = sender_card.sender_balance(money_amount)
    recipient_balance = recipient_card.recipient_balance(money_amount)

    return message(:money_amount_error) unless @validator.positive?(sender_balance)

    return message(:sender_card_money_amount_error) if recipient_card.put_tax(money_amount) >= money_amount

    @account.save_after_money_transfer_transaction(recipient_card)
    message_sender_card(money_amount, sender_card, recipient_balance)
    message_recepient_card(money_amount, recipient_card, sender_balance, sender_card)
  end
end
