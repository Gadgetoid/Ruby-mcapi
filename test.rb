require './mcapi.rb'

mcapi = Minecraft.new()

puts mcapi.player.x
puts mcapi.player.y
puts mcapi.player.z

myblock = mcapi.world.get_block( Minecraft::Location.new(9,9,9) )

puts myblock.xyz
puts myblock.block_type_id
block_name = myblock.get_block_name
puts block_name
puts Minecraft::Block.get_block_id_from_name( block_name )

puts 'Block Setting Test'

test_location = Minecraft::Location.new(11,11,11)
test_block_id = Minecraft::Block.get_block_id_from_name( 'Melon' )

mcapi.world.set_block( test_location, test_block_id )

myblock = mcapi.world.get_block( test_location )

puts myblock.get_block_name

10.times do |time|
  test_location = Minecraft::Location.new(11,11 + time,11)
  test_block_id = Minecraft::Block.get_block_id_from_name( 'Melon' )
  mcapi.world.set_block( test_location, test_block_id )
  myblock = mcapi.world.get_block( test_location )
  puts time.to_s + ':' + myblock.get_block_name
end