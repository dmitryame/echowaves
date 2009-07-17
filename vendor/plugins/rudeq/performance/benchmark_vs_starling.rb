<<-BENCHMARK
  A quick benchmark vs Starling
  doesn't deal with contention
  running in Production mode
  
  # empty queue
                       user     system      total        real
  rudequeue       30.630000   1.050000  31.680000 ( 44.472249)
  starling - one   1.450000   0.550000   2.000000 ( 11.144641)
  starling - many  1.160000   0.420000   1.580000 ( 18.012299)
  
  # after 1st run -> 10,000 :processed items
                       user     system      total        real
  rudequeue       30.910000   1.090000  32.000000 ( 45.863217)
  starling - one   1.380000   0.530000   1.910000 ( 12.189596)
  starling - many  1.110000   0.390000   1.500000 ( 17.231946)
  
  # after 5th run -> 50,000 :processed items
                       user     system      total        real
  rudequeue       33.670000   1.090000  34.760000 ( 47.945849)
  starling - one   1.340000   0.510000   1.850000 ( 12.792256)
  starling - many  1.140000   0.410000   1.550000 ( 18.573452)  >> @starlings.length => 148

  # with the deprecated TokenLock
                     user     system      total        real
  rudequeue       49.060000   2.970000  52.030000 ( 77.439360)
  starling - one   1.710000   0.890000   2.600000 ( 11.684323)
  starling - many  1.170000   0.610000   1.780000 ( 16.830219)  >> @starlings.length => 128

  running on a 2.8 ghz iMac
  MySQL 5
  ruby 1.8.6

  key points:
    If you don't need items to persist, should destroy on processed!
    (need to implement this!)
    
  To run this benchmark;
  
  :~ $ sudo gem install starling
  :~ $ starling -d
  :~ ruby script/console production
  * paste in the below code
 
BENCHMARK

def random_queue_name 
  queues = ["a", "b", "c", "d"] # Starling doesnt accept symbol queue names
  queues[rand(queues.length)]
end

def random_value
  values = ["some stuff", {:which => "needs"}, 2, :b, {"de" => :serialized}]
  values[rand(values.length)]
end

def random_queueing(queue)
  # because Starling waits forever on an empty queue, we need to ensure there is something in the queue
  queue_name = random_queue_name
  queue.set(queue_name, random_value)
  queue.get(queue_name)
end

require 'starling'

# need to reproduce multiple starlings and their startup times
def get_a_starling(max_count=nil)
  starling = @starlings[rand(@starlings.length)]
  if max_count.nil? || @starlings.length < max_count # throw in some randomness to make new connections
    if rand(@starlings.length + 1) == 0
      starling = get_a_new_starling
      @starlings << starling
    end
  end
  return starling
end

def reset_starlings
  @starlings = []
end

def get_a_new_starling
  Starling.new("127.0.0.1:22122")
end

require 'benchmark'
include Benchmark

bm(15) do |x|
  x.report("rudequeue") do
    10_000.times do
      random_queueing(RudeQueue)
    end
  end
  x.report("starling - one") do
    reset_starlings
    10_000.times do
      random_queueing(get_a_starling(1))
    end
  end
  x.report("starling - many") do
    reset_starlings
    10_000.times do
      random_queueing(get_a_starling)
    end
  end
end
