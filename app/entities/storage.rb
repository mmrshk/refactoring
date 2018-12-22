class Storage
  FILE_PATH = 'database/accounts.yml'.freeze

  def save(new_accounts)
    File.open(FILE_PATH, 'w') { |file| file.write new_accounts.to_yaml }
  end
end
