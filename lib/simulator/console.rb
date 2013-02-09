###############
# One of the possible formatters of our information.
# It outputs to the console. By default only info messages will be output
# create it with new(:debug) to make it much more verbose
###############
class Console

  def initialize(level=:info)
    if available?(level)
      @level = level
    else
      @level = :info
    end
  end

  def info(text)
    puts(text) if should_print(:info)
  end

  def debug(text)
    puts(text) if should_print(:debug)
  end

  private
  def available_levels
    [:debug, :info, :quiet]
  end

  def available?(level)
    available_levels.include?(level)
  end

  def priority(level)
    available_levels.index(level)
  end

  def should_print(level)
    priority(level) >= priority(@level)
  end

  def puts(text)
    return if defined?(Rails) && Rails.env == :test
    Kernel.puts text
  end

end
