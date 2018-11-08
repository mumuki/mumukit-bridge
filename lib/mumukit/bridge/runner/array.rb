class Array
  def fetch_mumuki_status(key)
    all? { |it| it[key].passed? }.to_mumuki_status
  end
end
