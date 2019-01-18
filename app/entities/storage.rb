class Storage
  FILE_PATH = 'database/accounts.yml'.freeze

  def initialize(file_path = FILE_PATH)
    @file_path = file_path
  end

  def save(new_accounts)
    File.open(@file_path, 'w') { |file| file.write new_accounts.to_yaml }
  end

  def load_accounts
    return File.exist?(@file_path) ? YAML.load_file(@file_path)  : []
    
  end

  def select_current_account(login, password)
    load_accounts.find { |account| account.login == login && account.password == password }
  end

  def load_cards
    load_accounts.map(&:cards).flatten
  end
end
