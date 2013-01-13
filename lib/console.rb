###############
# One of the possible formatters of our information.
# It outputs to the console. By default only info messages will be output
# create it with new(:debug) to make it much more verbose
###############
class Console

  def initilize(level=:info)
    @level = level
  end

  def info(text)
    puts(text)
  end

  def debug(text)
    return if @level != :debug
    puts(text)
  end

  private

  def puts(text)
    return if defined?(Rails) && Rails.env == :test
    Kernel.puts text
  end

end
