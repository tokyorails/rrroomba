class SchedulesController < ApplicationController

  respond_to :json, :only => :update


  def update
    @schedule = Schedule.find(params[:id])
    @schedule.attributes = params[:schedule]

    if @schedule.valid?
      # send the command to the roomba here
      # roomba.schedule_cleaning(params[:schedule])
      @schedule.save!
      head 204
    else
      render json: @schedule.errors, status: 422
    end
  end

end
