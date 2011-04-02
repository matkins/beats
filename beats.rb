require 'rubygems'
require 'midiator'
require 'lib/stats'

puts "Loading beats..."




@midi = MIDIator::Interface.new
@midi.autodetect_driver

@midi.control_change 32, 10, 1 # TR-808 is Program 26 in LSB bank 1
@midi.program_change 10, 26

include MIDIator::Drums



def get_time_signature
  print "Enter a time signature, (e.g. 3/4): "
  tss = gets
  num, den = tss.split('/').collect{|n| n.to_i}
  if num && den && num > 0 && den > 0
    [num,den]
  else
    get_time_signature
  end
end

def get_tempo
  puts "Tap out two bars with the Enter key"
  prev = nil
  beats = []
  (bpb * 2).times do |counter|
    gets
    beat(0.1, counter)
    now = Time.now
    if prev
      beats << now - prev 
      counter += 1
    end
    prev = now
  end
  average = beats.average
  if beats.variation_coefficient > 5
    puts "That beat was a bit irregular, please try again!"
    get_tempo
  else
    (60/average).to_i
  end
end


def beat(length, beat_num)
  if beat_num % @time_signature[0] == 0
    @midi.play BassDrum2, length, 10
  else
    @midi.play LowTom1, length, 10
  end
end

def bpb
  @time_signature[0]
end

# Begin here....

@time_signature = get_time_signature
@tempo = get_tempo


puts "You tapped at #{@tempo} beats per minute."
sleep(0.5)
puts "Here goes..."
(bpb * 4).times do |i|
  beat(60/@tempo.to_f, i)
end
puts ""