class MainChannel < Channel
  def run
    loop do
      process
    end
  end
end
