module Calculations
  def calculate_spin_time(velocity, degree)
    # time = wheelbase * PI / 360degrees * degrees / velocity ABS
    # wheelbase might be different for different roombas, consider refactoring
    ((((Roomba::ROOMBA_WHEELBASE * Math::PI) / 360) * degree.abs).to_f / velocity.to_f).abs
  end

  #spinning needs some work
  def calculate_spin_degree(velocity, time)
    ((time.to_f * velocity.to_f) / ((Roomba::ROOMBA_WHEELBASE * Math::PI) / 360)) #/ 10**10
  end
end
