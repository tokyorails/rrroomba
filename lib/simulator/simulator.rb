##############################
#
#This class is the highest level entity, controls how
#the simulation behaves, contains the world and the robots
#
###############################
class Simulator < Ein::Simulator

end

#####
# Our logger, default level is info.
# Please use only .info and .debug levels
#####
LOGGER = Logger.new(STDOUT)
LOGGER.level = Logger::INFO
