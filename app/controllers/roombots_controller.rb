class RoombotsController < ApplicationController
  # GET /roombots
  # GET /roombots.json
  def index
    @roombots = Roombot.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @roombots }
    end
  end

  # GET /roombots/1
  # GET /roombots/1.json
  def show
    @roombot = Roombot.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @roombot }
    end
  end

  # GET /roombots/new
  # GET /roombots/new.json
  def new
    @roombot = Roombot.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @roombot }
    end
  end

  # GET /roombots/1/edit
  def edit
    @roombot = Roombot.find(params[:id])
  end

  # POST /roombots
  # POST /roombots.json
  def create
    @roombot = Roombot.new(params[:roombot])

    respond_to do |format|
      if @roombot.save
        format.html { redirect_to @roombot, notice: 'Roombot was successfully created.' }
        format.json { render json: @roombot, status: :created, location: @roombot }
      else
        format.html { render action: "new" }
        format.json { render json: @roombot.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /roombots/1
  # PUT /roombots/1.json
  def update
    @roombot = Roombot.find(params[:id])

    respond_to do |format|
      if @roombot.update_attributes(params[:roombot])
        format.html { redirect_to @roombot, notice: 'Roombot was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @roombot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /roombots/1
  # DELETE /roombots/1.json
  def destroy
    @roombot = Roombot.find(params[:id])
    @roombot.destroy

    respond_to do |format|
      format.html { redirect_to roombots_url }
      format.json { head :no_content }
    end
  end

  def control
    @roombot = Roombot.find(params[:id])
    begin
      roomba_socket = TCPSocket.open("localhost",3001)
    rescue
      system "nohup ruby lib/roomba_socket_server.rb #{@roombot.location} &"
    end
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @roombot }
    end
  end

  def command
    begin
      roomba_socket = TCPSocket.open("localhost",3001)
      command_string = []
      @label = "label-success"
      @command = params[:command]
      case @command
      when "move"
        command_string = ["move",params[:distance],params[:angle],params[:velocity]]
      else
        command_string = [@command] if Roomba.method_defined? @command
      end

      if command_string.length > 0
        roomba_socket.puts command_string.join("$RoR$") + "$ROOMBA$"
      else
        @label = "label-warning"
      end
      roomba_socket.close
    rescue Exception => e
      @label = "label-important"
      @command = "Connection failed #{e}"
    end
  end

  def reply
    @replies = nil
    begin
      roomba_socket = TCPSocket.open("localhost",3001)
      roomba_socket.puts "messages$ROOMBA$"
      @replies = (roomba_socket.gets)
      @replies = (@replies == "nil") ? nil : eval( @replies.strip )
      roomba_socket.close
    rescue Exception => e
      @label = "label-important"
      @command = "Connection failed #{e}"
    end
  end
end
