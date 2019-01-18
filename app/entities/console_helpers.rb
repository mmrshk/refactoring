class ConsoleHelpers
  CONSOLE_COMMANDS = {
    create: 'create',
    load: 'load'
  }.freeze
  MENU_COMMANDS = {
    show_cards: 'SC',
    create_card: 'CC',
    destroy_card: 'DC',
    put_money: 'PM',
    withdraw_money: 'WM',
    send_money: 'SM',
    destroy_account: 'DA',
    exit_from_game: 'exit'
  }.freeze
  CHOOSE_COMMANDS = {
    yes: 'y'
  }.freeze

  def console
    message(:hello_message)

    case ask
    when CONSOLE_COMMANDS[:create] then create_account
    when CONSOLE_COMMANDS[:load] then load
    else exit
    end
  end

  def main_menu
    loop do
      message(:main_menu_message, name: @account.name)
      choice = ask
      if MENU_COMMANDS.value? choice
        choose_menu_command(choice)
      else
        message(:wrong_command)
        exit
      end
    end
  end

  def exit?(command)
    command == MENU_COMMANDS[:exit]
  end

  def ask(phrase_key = nil, options = {})
    message(phrase_key, options) if phrase_key
    gets.chomp
  end

  def message(msg_name, hashee = {})
    puts I18n.t(msg_name, hashee)
  end

  def message_withdraw(money_amount, current_card)
    message(:withdraw_money_messsage,
            money: money_amount,
            current_card: current_card.number,
            balance: current_card.balance,
            tax: current_card.withdraw_tax(money_amount))
  end

  def message_put(money_amount, current_card)
    message(:put_money_messsage,
            money: money_amount,
            card: current_card.number,
            balance: current_card.balance,
            tax: current_card.put_tax(money_amount))
  end

  def message_sender_card(money_amount, sender_card, recipient_balance)
    message(:money_amount_on_sender_card,
            money_amount: money_amount,
            card_number: sender_card.number,
            recipient_balance: recipient_balance,
            tax: sender_card.put_tax(money_amount))
  end

  def message_recepient_card(money_amount, recipient_card, sender_balance, sender_card)
    message(:money_amount_on_recipient_card,
            money_amount: money_amount,
            recipient_card: recipient_card.number,
            sender_balance: sender_balance,
            tax: sender_card.sender_tax)
  end

  def exit_from_game
    exit
  end

  private

  def choose_menu_command(command)
    MENU_COMMANDS.each_value do |value|
      public_send(command_value(value)) if command == value
    end
  end

  def command_value(value)
    MENU_COMMANDS.key(value).to_s
  end

  def destroy_account
    @account.destroy_account
    exit
  end
end
