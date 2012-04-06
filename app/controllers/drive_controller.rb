class DriveController < ApplicationController
  def index
  end

  def command
    roomba = RoombaSimulation.new("/dev/tty.usbserial-A800K6ZF")
    @sensors = roomba.move(params[:distance].to_i, params[:angle].to_i)
  end
end
