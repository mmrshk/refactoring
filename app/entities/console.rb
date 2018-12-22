class Console
  attr_reader :login, :password, :card, :file_path, :account

  CONSOLE_COMMANDS = {
    yes: 'y',
    exit: 'exit'
  }

  def initialize(file_path = Storage::FILE_PATH)
    @file_path = file_path
    @renderer = Renderer.new
    @account = Account.new
    @storage = Storage.new
  end

  def console
    @renderer.message(:hello_message)

    case gets.chomp
    when 'create' then create
    when 'load' then load
    else exit
    end
  end

  def create
    loop do
      @account.create(name: user_input(:name_input),
                      age: user_input(:age_input),
                      login: user_input(:login_input),
                      password: user_input(:password_input))

      break if @account.validator.valid?

      @account.errors_list
    end

    @account.add_current_account
    @storage.save(@account.add_new_accounts)
    main_menu
  end

  def load
    loop do
      return create_the_first_account if !@account.accounts.any?

      login = user_input(:load_login)
      password = user_input(:load_password)

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

    return create if gets.chomp == CONSOLE_COMMANDS[:yes]

    console
  end

  def main_menu
    @renderer.message(:main_menu_message, name: @account.current_account.name)

    loop do
      case gets.chomp
      when 'SC'
        show_cards
      when 'CC'
        create_card
      when 'DC'
        destroy_card
      when 'PM'
        put_money
      when 'WM'
        withdraw_money
      when 'SM'
        send_money
      when 'DA'
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
      card_type = gets.chomp
      return @renderer.message(:wrong_card_type) if !CreditCard::CARD_TYPES.keys.include?(card_type.to_sym)

      @account.create_card(CreditCard::CARD_TYPES[card_type.to_sym])
      @storage.save(@account.add_new_accounts)
      break
    end
  end

  def list_of_cards
    @account.current_account.cards.each_with_index do |card, i|
      @renderer.message(:list_cards, number: card[:number], type: card[:type], index: i + 1)
    end

    @renderer.message(:exit_msg)
  end

  def show_cards
    return @renderer.message(:no_active_cards) if !@account.current_account.cards.any?

    @account.current_account.cards.each do |card|
      @renderer.message(:card_info, number: card[:number], type: card[:type])
    end
  end

  def destroy_card
    loop do
      return @renderer.message(:active_error_card) if @account.current_account.cards.none?

      @renderer.message(:want_to_delete)
      answer = list_of_cards
      break if answer == CONSOLE_COMMANDS[:exit]

      @renderer.message(:wrong_number_input) if !@account.valid_input?(answer)
      @renderer.message(:accept_delete_account, card_number: @account.current_account.cards[answer.to_i - 1][:number])
      return if gets.chomp != CONSOLE_COMMANDS[:yes]

      @account.delete_card(answer)
      @storage.save(@account.add_new_accounts)
      break
    end
  end

  def withdraw_money
    @renderer.message(:choose_card_withdraw)
    return @renderer.message(:no_cards_avaliable) if @account.current_account.cards.none?
    list_of_cards
    handle_withdraw_money
  end

  def handle_withdraw_money
    loop do
      answer = gets.chomp

      break if answer == CONSOLE_COMMANDS[:exit]

      return @renderer.message(:wrong_number_input) if !@account.valid_input?(answer)

      withdraw_money_amount(answer)
    end
  end

  def withdraw_money_amount(card_index)
    #current_card = @account.current_account.cards[card_index.to_i - 1]

    loop do
      money_amount = user_input(:withdraw_money_amount).to_i

      return @renderer.message(:uncorrect_input_amout) unless money_amount > 0

      #binding.pry
      @account.money_left(card_index, money_amount)
      #money_left = current_card[:balance] - money_amount - withdraw_tax('virtual', money_amount)

      return @renderer.message(:not_enough_money) unless money_left > 0

      current_card[:balance] = money_left
      #@account.current_account.cards[answer.to_i - 1] = current_card

      @storage.save(@account.add_new_accounts)
      @renderer.message(:withdraw_money_messsage,
                        money: money_amount,
                        current_card: current_card[:number],
                        balance: current_card[:balance],
                        tax: withdraw_tax(current_card[:type], current_card[:balance], current_card[:number], money_amount))
      #return
    end
  end

  def put_money
    puts 'Choose the card for putting:'

    if @account.current_account.card.any?
      @account.current_account.card.each_with_index do |c, i|
        puts "- #{c[:number]}, #{c[:type]}, press #{i + 1}"
      end
      puts "press `exit` to exit\n"
      loop do
        answer = gets.chomp
        break if answer == CONSOLE_COMMANDS[:exit]
        if answer&.to_i.to_i <= @account.current_account.card.length && answer&.to_i.to_i > 0
          current_card = @account.current_account.card[answer&.to_i.to_i - 1]
          loop do
            puts 'Input the amount of money you want to put on your card'
            a2 = gets.chomp
            if a2&.to_i.to_i > 0
              if put_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i) >= a2&.to_i.to_i
                puts 'Your tax is higher than input amount'
                return
              else
                new_money_amount = current_card[:balance] + a2&.to_i.to_i - put_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i)
                current_card[:balance] = new_money_amount
                @account.current_account.card[answer&.to_i.to_i - 1] = current_card
                new_accounts = []
                accounts.each do |ac|
                  if ac.login == @account.current_account.login
                    new_accounts.push(@account.current_account)
                  else
                    new_accounts.push(ac)
                  end
                end
                File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml } #Storing
                puts "Money #{a2&.to_i.to_i} was put on #{current_card[:number]}. Balance: #{current_card[:balance]}. Tax: #{put_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i)}"
                return
              end
            else
              puts 'You must input correct amount of money'
              return
            end
          end
        else
          puts "You entered wrong number!\n"
          return
        end
      end
    else
      puts "There is no active cards!\n"
    end
  end

  def send_money
    puts 'Choose the card for sending:'

    if @account.current_account.card.any?
      @account.current_account.card.each_with_index do |c, i|
        puts "- #{c[:number]}, #{c[:type]}, press #{i + 1}"
      end
      puts "press `exit` to exit\n"
      answer = gets.chomp
      exit if answer == CONSOLE_COMMANDS[:exit]
      if answer&.to_i.to_i <= @account.current_account.card.length && answer&.to_i.to_i > 0
        sender_card = @account.current_account.card[answer&.to_i.to_i - 1]
      else
        puts 'Choose correct card'
        return
      end
    else
      puts "There is no active cards!\n"
      return
    end

    puts 'Enter the recipient card:'
    a2 = gets.chomp
    if a2.length > 15 && a2.length < 17
      all_cards = accounts.map(&:card).flatten
      if all_cards.select { |card| card[:number] == a2 }.any?
        recipient_card = all_cards.select { |card| card[:number] == a2 }.first
      else
        puts "There is no card with number #{a2}\n"
        return
      end
    else
      puts 'Please, input correct number of card'
      return
    end

    loop do
      puts 'Input the amount of money you want to withdraw'
      a3 = gets.chomp
      if a3&.to_i.to_i > 0
        sender_balance = sender_card[:balance] - a3&.to_i.to_i - sender_tax(sender_card[:type], sender_card[:balance], sender_card[:number], a3&.to_i.to_i)
        recipient_balance = recipient_card[:balance] + a3&.to_i.to_i - put_tax(recipient_card[:type], recipient_card[:balance], recipient_card[:number], a3&.to_i.to_i)

        if sender_balance < 0
          puts "You don't have enough money on card for such operation"
        elsif put_tax(recipient_card[:type], recipient_card[:balance], recipient_card[:number], a3&.to_i.to_i) >= a3&.to_i.to_i
          puts 'There is no enough money on sender card'
        else
          sender_card[:balance] = sender_balance
          @account.current_account.card[answer&.to_i.to_i - 1] = sender_card
          new_accounts = []
          accounts.each do |ac|
            if ac.login == @account.current_account.login
              new_accounts.push(@account.current_account)
            elsif ac.card.map { |card| card[:number] }.include? a2
              recipient = ac
              new_recipient_cards = []
              recipient.card.each do |card|
                if card[:number] == a2
                  card[:balance] = recipient_balance
                end
                new_recipient_cards.push(card)
              end
              recipient.card = new_recipient_cards
              new_accounts.push(recipient)
            end
          end
          File.open('accounts.yml', 'w') { |f| f.write new_accounts.to_yaml } #Storing
          puts "Money #{a3&.to_i.to_i}$ was put on #{sender_card[:number]}. Balance: #{recipient_balance}. Tax: #{put_tax(sender_card[:type], sender_card[:balance], sender_card[:number], a3&.to_i.to_i)}$\n"
          puts "Money #{a3&.to_i.to_i}$ was put on #{a2}. Balance: #{sender_balance}. Tax: #{sender_tax(sender_card[:type], sender_card[:balance], sender_card[:number], a3&.to_i.to_i)}$\n"
          break
        end
      else
        puts 'You entered wrong number!\n'
      end
    end
  end

  private

  def destroy_account
    @renderer.message(:destroy_account)
    @storage.save(@account.destroy_account) if gets.chomp == CONSOLE_COMMANDS[:yes]
  end

  def user_input(input_msg)
    @renderer.message(input_msg)
    gets.chomp
  end

=begin
  def withdraw_tax(type, amount)
    return amount * 0.05 if type == 'usual'
    return amount * 0.04 if type == 'capitalist'
    return amount * 0.88 if type == 'virtual'

    0
  end

  def put_tax(type, balance, number, amount)
    return amount * 0.02 if type == 'usual'
    return 10 if type == 'capitalist'
    return 1 if type == 'virtual'

    0
  end

  def sender_tax(type, balance, number, amount)
    return 20 if type == 'usual'
    return amount * 0.1 if type == 'capitalist'
    return 1 if type == 'virtual'

    0
  end
=end
end
