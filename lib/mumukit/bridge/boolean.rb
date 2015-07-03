class TrueClass
  def to_mumuki_status
    :passed
  end
end

class FalseClass
  def to_mumuki_status
    :failed
  end
end
