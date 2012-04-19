class Schedule < ActiveRecord::Base

  belongs_to :roombot

  DAYS = [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]

  attr_accessible *DAYS, :roombot_id

  validate :hour_and_minute_in_range


  def hour_and_minute_in_range
    DAYS.each do |day|
      time = send(day)
      next if time.blank?
      unless time =~ /\A\d{2}:\d{2}\Z/
        errors.add(day, :invalid)
        next
      end
      t = time.split(':').map(&:to_i)
      errors.add(day, :invalid) unless (0..23).include?(t.first) && (0..59).include?(t.second)
    end
  end

end
