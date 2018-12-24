class Validators::Account
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

    @errors.push('Your name must not be empty and starts with first upcase letter')
  end

  def validate_login
    @errors.push('Login must present') if @login.empty?
    @errors.push('Login must be longer then 4 symbols') if @login.length < 4
    @errors.push('Login must be shorter then 20 symbols') if @login.length > 20
    @errors.push('Such account is already exists') if @account.storage.load_accounts.map(&:login).include?(@login)
  end

  def validate_password
    @errors.push('Password must present') if @password.empty?
    @errors.push('Password must be longer then 6 symbols') if @password.length < 6
    @errors.push('Password must be shorter then 30 symbols') if @password.length > 30
  end

  def validate_age
    @errors.push('Your Age must be greeter then 23 and lower then 90') unless @age.between?(23, 89)
  end
end
