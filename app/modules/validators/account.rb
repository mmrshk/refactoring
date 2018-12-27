module Validators
  class Account < ConsoleHelpers
    attr_reader :errors

    def initialize
      @errors = []
    end

    def validate(account)
      initialize_account(account)

      validate_name
      validate_age
      validate_login
      validate_password
    end

    def valid?
      @errors.size.zero?
    end

    def puts_errors
      @errors.each { |error| puts error }
      @errors = []
    end

    def validate_input(answer, current_account)
      answer.to_i <= current_account.cards.length && answer.to_i.positive?
    end

    private

    def initialize_account(account)
      @account = account
      @name = @account.name
      @age = @account.age.to_i
      @login = @account.login
      @password = @account.password
    end

    def validate_name
      return unless @name.empty? || @name[0].upcase != @name[0]

      @errors.push(message_validate(:empty_name_error))
    end

    def validate_login
      @errors.push(message_validate(:login_present_error)) if @login.empty?
      @errors.push(message_validate(:length_name_error)) if @login.length < 4
      @errors.push(message_validate(:short_name_error)) if @login.length > 20
      @errors.push(message_validate(:account_exist_error)) if @account.storage.load_accounts.map(&:login).include?(@login)
    end

    def validate_password
      @errors.push(message_validate(:password_present_error)) if @password.empty?
      @errors.push(message_validate(:password_longer_error)) if @password.length < 6
      @errors.push(message_validate(:password_shorter_error)) if @password.length > 30
    end

    def validate_age
      @errors.push(message_validate(:age_error)) unless @age.between?(23, 89)
    end
  end
end
