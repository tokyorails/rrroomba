class DriveController < ApplicationController
  def index
  end

  def command
    roomba = Roomba.new(params[:roomba])
    sleep 0.5
    if params[:demo]
      roomba.demo1
    else
      @sensors = roomba.move(params[:distance].to_i, params[:angle].to_i, params[:velocity].to_i)
    end
  end
end
