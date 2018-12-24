class Storage
  FILE_PATH = 'database/accounts.yml'.freeze

  def initialize(file_path = FILE_PATH)
    @file_path = file_path
  end

  def save(new_accounts)
    File.open(@file_path, 'w') { |file| file.write new_accounts.to_yaml }
  end

  def load_accounts
    return YAML.load_file(@file_path) if File.exist?(@file_path)

    []
  end

  def load_cards
    load_accounts.map(&:cards).flatten
  end
end
