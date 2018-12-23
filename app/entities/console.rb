class Console
  attr_reader :login, :password, :card, :file_path, :account

  CONSOLE_COMMANDS = {
    yes: 'y',
    exit: 'exit',
    show_cards: 'SC',
    create_card: 'CC',
    destroy_card: 'DC',
    put_money: 'PM',
    withdraw_money: 'WM',
    send_money: 'SM',
    destroy_account: 'DA',
    create: 'create',
    load: 'load'
  }

  def initialize(file_path = Storage::FILE_PATH)
    @file_path = file_path
    @renderer = Renderer.new
    @account = Account.new
    @storage = Storage.new
    @validator = Validators::Console.new
  end

  def console
    @renderer.message(:hello_message)

    case ask
    when CONSOLE_COMMANDS[:create] then create
    when CONSOLE_COMMANDS[:load] then load
    else exit
    end
  end

  def create
    loop do
      @account.create(name: ask(:name_input),
                      age: ask(:age_input),
                      login: ask(:login_input),
                      password: ask(:password_input))

      break if @account.validator.valid?

      @account.errors_list
    end

    @storage.save(@account.add_current_account)
    main_menu
  end

  def load
    loop do
      return create_the_first_account if !@account.accounts.any?

      login = ask(:load_login)
      password = ask(:load_password)

      if @account.match?(login, password)
        @account.set_current_account(login)
        break
      else
        @renderer.message(:load_error)
        next
      end
    end
    main_menu
  end

  def create_the_first_account
    @renderer.message(:create_the_first_account)

    return create if ask == CONSOLE_COMMANDS[:yes]

    console
  end

  def main_menu
    loop do
      @renderer.message(:main_menu_message, name: @account.current_account.name)

      case ask
      when CONSOLE_COMMANDS[:show_cards]
        show_cards
      when CONSOLE_COMMANDS[:create_card]
        create_card
      when CONSOLE_COMMANDS[:destroy_card]
        destroy_card
      when CONSOLE_COMMANDS[:put_money]
        put_money
      when CONSOLE_COMMANDS[:withdraw_money]
        withdraw_money
      when CONSOLE_COMMANDS[:send_money]
        send_money
      when CONSOLE_COMMANDS[:destroy_account]
        destroy_account
        exit
      when CONSOLE_COMMANDS[:exit]
        exit
      else
        @renderer.message(:wrong_command)
        exit
      end
    end
  end

  def create_card
    @renderer.message(:create_card_message)
    loop do
      card_type = ask
      return @renderer.message(:wrong_card_type) if !CreditCard::CARD_TYPES.keys.include?(card_type.to_sym)

      @account.create_card(CreditCard::CARD_TYPES[card_type.to_sym])
      @storage.save(@account.add_new_accounts)
      break
    end
  end

  def list_of_cards
    @account.current_account.cards.each_with_index do |card, i|
      @renderer.message(:list_cards, number: card.number, type: card.type, index: i + 1)
    end

    @renderer.message(:exit_msg)
  end

  def show_cards
    return @renderer.message(:active_card_error ) if !@account.current_account.cards.any?

    @account.current_account.cards.each do |card|
      @renderer.message(:card_info, number: card.number, type: card.type)
    end
  end

  def destroy_card
    loop do
      return @renderer.message(:active_card_error ) if @account.current_account.cards.none?

      @renderer.message(:want_to_delete)
      answer = list_of_cards
      break if exit?(answer)

      @renderer.message(:wrong_number_input) if !@account.valid_input?(answer)
      @renderer.message(:accept_delete_account, card_number: @account.current_card(answer).number)

      return if ask != CONSOLE_COMMANDS[:yes]

      @account.delete_card(answer)
      @storage.save(@account.add_new_accounts)
      break
    end
  end

  def withdraw_money
    @renderer.message(:choose_card_withdraw)
    return @renderer.message(:active_card_error ) if @account.current_account.cards.none?
    list_of_cards
    handle_withdraw_money
  end

  def handle_withdraw_money
    loop do
      answer = ask

      break if exit?(answer)

      return @renderer.message(:wrong_number_input) if !@account.valid_input?(answer)

      withdraw_money_amount(answer)
    end
  end

  def set_card_balance_after_withdraw(money_left, current_card)
    return @renderer.message(:not_enough_money) if !@validator.positive?(money_left)

    current_card.set_new_balance(money_left)
  end


  def withdraw_money_amount(card_index)
    current_card = @account.current_card(card_index)

    loop do
      money_amount = ask(:withdraw_money_amount).to_i

      return @renderer.message(:uncorrect_input_amount) if !@validator.positive?(money_amount)

      set_card_balance_after_withdraw(current_card.withdraw_money(money_amount), current_card)
      @storage.save(@account.add_new_accounts)
      @renderer.message(:withdraw_money_messsage,
                        money: money_amount,
                        current_card: current_card.number,
                        balance: current_card.balance,
                        tax: current_card.withdraw_tax(money_amount))
      return
    end
  end

  def put_money
    @renderer.message(:choose_card_putting)
    return puts if @account.current_account.cards.none?

    list_of_cards
    handle_puts_money
  end

  def handle_puts_money
    loop do
      answer = ask

      break if exit?(answer)

      return @renderer.message(:wrong_number_input) if !@account.valid_input?(answer)

      puts_money_amount(answer)
    end
  end

  def puts_money_amount(card_index)
    current_card = @account.current_card(card_index)

    loop do
      money_amount = ask(:puts_money_amount).to_i
      return @renderer.message(:uncorrect_puts_input_amount) if !@validator.positive?(money_amount)

      return @renderer.message(:high_tax_error) if current_card.put_tax(money_amount) >= money_amount

      current_card.put_money(money_amount)
      @storage.save(@account.add_new_accounts)
      @renderer.message(:put_money_messsage,
                        money: money_amount,
                        current_card: current_card.number,
                        balance: current_card.balance,
                        tax: current_card.put_tax(money_amount))
      return
    end
  end

  def choose_send_card
    @renderer.message(:choose_send_card)
    return @renderer.message(:active_card_error ) if @account.current_account.cards.none?

    list_of_cards
    answer = ask
    exit if exit?(answer)
    return @renderer.message(:choose_correct_card) if !@account.valid_input?(answer)

    @account.current_card(answer)
  end

  def exit?(command)
    command == CONSOLE_COMMANDS[:exit]
  end

  def choose_recipient_card
    @renderer.message(:enter_recipient_card)

    card_number = ask
    return @renderer.message(:correct_number_card_error) unless @validator.card_valid?(card_number)

    all_cards = @account.accounts.map(&:cards).flatten

    return @renderer.message(:card_not_exist, number: card_number) if !@validator.card_exist?(all_cards, card_number)

    all_cards.select { |card| card.number == card_number }.first
  end

  def send_money
    sender_card = choose_send_card
    recipient_card = choose_recipient_card
    binding.pry
    return if [sender_card, recipient_card].nil?

    money_transfer_transaction(sender_card, recipient_card)
  end

  def money_transfer_transaction(sender_card, recipient_card)
    loop do
      @renderer.message(:money_amount_to_withdraw)
      money_amount = ask.to_i
      return @renderer.message(:wrong_number_input) if !@validator.positive?(money_amount)

      sender_balance = sender_card.sender_balance(money_amount)
      recipient_balance = recipient_card.recipient_balance(money_amount)

      return @renderer.message(:money_amount_error) if !@validator.positive?(sender_balance)
      return @renderer.message(:sender_card_money_amount_error) if recipient_card.put_tax(money_amount) >= money_amount

      @storage.save(@account.save_after_money_transfer_transaction(recipient_card))
      @renderer.message(:money_amount_on_sender_card,
                        money_amount: money_amount,
                        card_number: sender_card.number,
                        recipient_balance: recipient_balance,
                        tax: sender_card.put_tax(money_amount))

      @renderer.message(:money_amount_on_recipient_card,
                        money_amount: money_amount,
                        recipient_card: recipient_card.number,
                        sender_balance: sender_balance,
                        tax: sender_card.sender_tax)
      break
    end
  end

  private

  def destroy_account
    @renderer.message(:destroy_account)
    @storage.save(@account.destroy_account) if ask == CONSOLE_COMMANDS[:yes]
  end

  def ask(phrase_key = nil, options = {})
    @renderer.message(phrase_key) if phrase_key
    gets.chomp
  end
end
