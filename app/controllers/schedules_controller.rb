class SchedulesController < ApplicationController

  respond_to :json, :only => [:create, :update]


  def create
    head 422 and return if Schedule.count > 0

    if @schedule.save
      head 204
    else
      render json: @schedule.errors, status: 422
    end
  end


  def update
    #  render json: 'no existing schedule to update', status: :unprocessable_entity
    head 422 and return if Schedule.count == 0

    if @schedule.save
      head 204
    else
      render json: @schedule.errors, status: 422
    end
  end

end
