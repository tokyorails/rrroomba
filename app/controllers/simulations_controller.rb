class SimulationsController < ApplicationController
  # GET /simulations
  # GET /simulations.json
  def index
    @simulations = Simulation.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @simulations }
    end
  end

  # GET /simulations/1
  # GET /simulations/1.json
  def show
    @simulation = Simulation.find(params[:id])

    #this is super crap, just for debugging ATM, moving out soon
    @world = RoombaSimulation.new.serial.world

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @simulation }
    end
  end

  # GET /simulations/new
  # GET /simulations/new.json
  def new
    @simulation = Simulation.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @simulation }
    end
  end

  # GET /simulations/1/edit
  def edit
    @simulation = Simulation.find(params[:id])
  end

  # POST /simulations
  # POST /simulations.json
  def create
    @simulation = Simulation.new(params[:simulation])

    respond_to do |format|
      if @simulation.save
        format.html { redirect_to @simulation, notice: 'Simulation was successfully created.' }
        format.json { render json: @simulation, status: :created, location: @simulation }
      else
        format.html { render action: "new" }
        format.json { render json: @simulation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /simulations/1
  # PUT /simulations/1.json
  def update
    @simulation = Simulation.find(params[:id])

    respond_to do |format|
      if @simulation.update_attributes(params[:simulation])
        format.html { redirect_to @simulation, notice: 'Simulation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @simulation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /simulations/1
  # DELETE /simulations/1.json
  def destroy
    @simulation = Simulation.find(params[:id])
    @simulation.destroy

    respond_to do |format|
      format.html { redirect_to simulations_url }
      format.json { head :no_content }
    end
  end
end
