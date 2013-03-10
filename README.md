![Rrroomba!](http://www.forthecode.org/custom/images/rrroomba.png)
=======


Main files
-------
````
/lib/roomba.rb
/lib/roomba_simulation.rb
/lib/roomba_serial_simulation.rb
````

Quickstart
-------
Migrate the db

````
$ rake db:migrate
````

Make sure that the tests pass

````
$ rake test
````


Jump in console and give the basic simulation a shot.

````ruby
$ rails c
:001 > simulator = Simulator.new
:002 > roo = RoombaSimulation.new(simulator)
:004 > simulator.start
:005 > roo.move(100)
:006 > roo.move(0,90)
:007 > roo.move(1000)
````
You should end up with a bump reading at N:90, X:126 Y:89

X:126 is the center point of Simulated Roomba. Add the radius of Roomba + the radius of the obstacle and it should be the same as the distance between X:126 and the default simulated obstacle.

If you want to get information of each step of the simulation do:

```Ruby
LOGGER.level = Logger::DEBUG
```

Or jump into the rails app and play around.

````
rails s
````
