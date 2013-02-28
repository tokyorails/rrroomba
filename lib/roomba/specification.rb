module Roomba::Specification
  # Packets requested are sent every 15 ms (0.015), which is the rate Roomba uses to update data. page 17 ROI (2012)
  DATA_REFRESH_RATE = 0.15 #may need to modify this value for hardware that has any latency issues, increase for more certainty
  WHEELBASE = 248
  RADIUS = 176

  # Sensors according to the ROI (2012)
  SENSORS = {
    :bumps_and_drops => { :packet => 7, :bytes => 1, :signed => false, :bits => true },
    :wall => { :packet => 8, :bytes => 1, :signed => false, :bits => true },
    :cliff_left => { :packet => 9, :bytes => 1, :signed => false, :bits => true },
    :cliff_front_left => { :packet => 10, :bytes => 1, :signed => false, :bits => true },
    :cliff_right => { :packet => 12, :bytes => 1, :signed => false, :bits => true },
    :cliff_front_right => { :packet => 11, :bytes => 1, :signed => false, :bits => true },
    :virtual_wall => { :packet => 13, :bytes => 1, :signed => false, :bits => true },
    :wheel_overcurrents => { :packet => 14, :bytes => 1, :signed => false, :bits => true },
    :dirt_detect => { :packet => 15, :bytes => 1, :signed => false },
    :infrared_omni => { :packet => 17, :bytes => 1, :signed => false },
    :infrared_left => { :packet => 52, :bytes => 1, :signed => false },
    :infrared_right => { :packet => 53, :bytes => 1, :signed => false },
    :buttons => { :packet => 18, :bytes => 1, :signed => false, :bits => true },
    :distance => { :packet => 19, :bytes => 2, :signed => true },
    :angle => { :packet => 20, :bytes => 2, :signed => true },
    :charging_state => { :packet => 21, :bytes => 1, :signed => false },
    :voltage => { :packet => 22, :bytes => 2, :signed => false },
    :current => { :packet => 23, :bytes => 2, :signed => true },
    :temperature => { :packet => 24, :bytes => 1, :signed => true },
    :battery_charge => { :packet => 25, :bytes => 2, :signed => false },
    :battery_capacity => { :packet => 26, :bytes => 2, :signed => false },
    :wall_signal => { :packet => 27, :bytes => 2, :signed => false },
    :cliff_left_signal => { :packet => 28, :bytes => 2, :signed => false },
    :cliff_front_left_signal => { :packet => 29, :bytes => 2, :signed => false },
    :cliff_front_right_signal => { :packet => 30, :bytes => 2, :signed => false },
    :cliff_right_signal => { :packet => 31, :bytes => 2, :signed => false },
    :charging_source => { :packet => 34, :bytes => 1, :signed => false, :bits => true },
    :oi_mode => { :packet => 35, :bytes => 1, :signed => false },
    :song_number => { :packet => 36, :bytes => 1, :signed => false },
    :song_playing => { :packet => 37, :bytes => 1, :signed => false, :bits => true },
    :number_of_stream_packets => { :packet => 38, :bytes => 1, :signed => false },
    :requested_velocity => { :packet => 39, :bytes => 2, :signed => true },
    :requested_radius => { :packet => 40, :bytes => 2, :signed => true },
    :requested_right_velocity => { :packet => 41, :bytes => 2, :signed => true },
    :requested_left_velocity => { :packet => 42, :bytes => 2, :signed => true },
    :right_encoder_counts => { :packet => 43, :bytes => 2, :signed => false },
    :left_encoder_counts => { :packet => 44, :bytes => 2, :signed => false },
    :light_bumper => { :packet => 45, :bytes => 1, :signed => false, :bits => true },
    :light_bump_left_signal => { :packet => 46, :bytes => 2, :signed => false },
    :light_bump_front_left_signal => { :packet => 47, :bytes => 2, :signed => false },
    :light_bump_center_left_signal => { :packet => 48, :bytes => 2, :signed => false },
    :light_bump_center_right_signal => { :packet => 49, :bytes => 2, :signed => false },
    :light_bump_front_right_signal => { :packet => 50, :bytes => 2, :signed => false },
    :light_bump_right_signal => { :packet => 51, :bytes => 2, :signed => false },
    :left_motor_current => { :packet => 54, :bytes => 2, :signed => true },
    :right_motor_current => { :packet => 55, :bytes => 2, :signed => true },
    :main_brush_motor_current => { :packet => 56, :bytes => 2, :signed => true },
    :side_brush_motor_current => { :packet => 57, :bytes => 2, :signed => true },
    :statis => { :packet => 58, :bytes => 1, :signed => false, :bits => true },
  }
end