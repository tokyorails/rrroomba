class SchedulesController < ApplicationController

  respond_to :json, :only => :update


  def update
    @schedule = Schedule.find(params[:id])
    @schedule.attributes = params[:schedule]

    if @schedule.valid?
      # send the command to the roomba here
      # roomba.schedule_cleaning(params[:schedule])
        roomba_socket = TCPSocket.open("localhost",3001)
        command_string = ["schedule_cleaning",params[:schedule].to_hash.delete_if {|key, value| value == "" }]
        roomba_socket.puts command_string.join("$RoR$") + "$ROOMBA$"
      @schedule.save!
      head 204
    else
      render json: @schedule.errors, status: 422
    end
  end

end
