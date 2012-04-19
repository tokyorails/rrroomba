class Roombot < ActiveRecord::Base

  has_one :schedule

  attr_accessible :location, :name

end
