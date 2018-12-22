class Renderer
  def message(msg_name, hashee = {})
    puts I18n.t(msg_name, hashee)
  end
end
