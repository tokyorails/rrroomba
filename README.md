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
:001 > earth = World.new
:002 > roo = RoombaSimulation.new
:003 > earth.spawn(roo)
:004 > roo.move(100)
:005 > roo.move(0,120)
:006 > roo.move(1000)
````
You should end up with a bump reading at N:90, X:126 Y:89

X:126 is the center point of Simulated Roomba. Add the radius of Roomba + the radius of the obstacle and it should be the same as the distance between X:126 and the default simulated obstacle.

Or jump into the rails app and play around.

````
rails s
````
