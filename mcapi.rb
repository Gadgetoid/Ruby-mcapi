require 'socket'

class Minecraft

  @world  = nil
  @player = nil
  @chat   = nil
  @camera = nil

  @ip     = nil
  @port   = nil
  @socket = nil

  attr_accessor :world, :player, :chat, :camera

  def initialize( ip = '10.0.1.22', port = 4711 )
    @ip   = ip
    @port = port

    @socket = TCPSocket.new @ip, @port

    @player = Minecraft::Player.new( @socket )
    @world = Minecraft::World.new( @socket )
  end

  class Location
    @x = 0
    @y = 0
    @z = 0

    attr_reader :x, :y, :z

    def self.from_string( s )
      loc = s.split(',')
      if loc.length == 3
        Minecraft::Location.new loc[0], loc[1], loc[2]
      else
        raise ArgumentError, 'Invalid location string'
      end
    end

    def initialize( x, y, z )
      self.x = x
      self.y = y
      self.z = z
    end

    def xyz
      @x.to_s + ',' + @y.to_s + ',' + @z.to_s
    end

    def x=(new_x)
      @x = new_x
    end

    def y=(new_y) # Vertical axis, ground to sky
      @y = new_y
    end

    def z=(new_z)
      @z = new_z
    end
  end

  class Block < Location

    @block_type_id = nil

    @@block_names = {

        0 => 'Air',
        1 => 'Stone',
        2 => 'Grass',
        3 => 'Dirt',
        4 => 'Cobblestone',
        5 => 'Wooden Plank',
        6 => 'Sapling',
        7 => 'Bedrock',
        8 => 'Water',
        9 => 'Stationary Water',
        10 => 'Lava',
        11 => 'Stationary Lava',
        12 => 'Sand',
        13 => 'Gravel',
        14 => 'Gold Ore',
        15 => 'Iron Ore',
        16 => 'Coal Ore',
        17 => 'Wood',
        18 => 'Leaves',
        20 => 'Glass',
        21 => 'Lapis Lazuli Ore',
        22 => 'Lapis Lazuli Block',
        24 => 'Sandstone',
        26 => 'Bed',
        30 => 'Cobweb',
        31 => 'Tall Grass',
        35 => 'Wool',
        37 => 'Yellow Flower',
        38 => 'Cyan Flower',
        39 => 'Brown Mushroom',
        40 => 'Red Mushroom',
        41 => 'Gold Block',
        42 => 'Iron Block',
        43 => 'Double Stone Slab',
        44 => 'Stone Slap',
        45 => 'Brick Block',
        46 => 'TNT',
        47 => 'Bookshelf',
        48 => 'Moss Stone',
        49 => 'Obsidian',
        50 => 'Torch',
        51 => 'Fire',
        53 => 'Wooden Stairs',
        54 => 'Chest',
        56 => 'Diamond Ore',
        57 => 'Diamond Block',
        58 => 'Crafting Table',
        59 => 'Wheat Seeds',
        60 => 'Farmland',
        61 => 'Furnace',
        62 => 'Burning Furnace',
        63 => 'Sign Post',
        64 => 'Wooden Door',
        65 => 'Ladder',
        67 => 'Cobblestone Stairs',
        68 => 'Wall Sign',
        71 => 'Iron Door',
        73 => 'Redstone Ore',
        74 => 'Glowing Redstone Ore',
        78 => 'Snow',
        79 => 'Ice',
        80 => 'Snow Block',
        81 => 'Cactus',
        82 => 'Clay',
        83 => 'Sugar Cane',
        85 => 'Fence',
        87 => 'Netherrack',
        89 => 'Glowstone Block',
        95 => 'Invisible Bedrock',
        98 => 'Stone Brick',
        102 => 'Glass Pane',
        103 => 'Melon',
        105 => 'Melon Stem',
        107 => 'Fence Gate',
        109 => 'Stone Brick Stairs',
        108 => 'Brick Stairs'

    }

    attr_accessor :block_type_id

    def initialize( x, y, z, block_type_id )

      super( x, y, z )
      self.block_type_id = block_type_id

    end

    def self.from_string( s )

      block = s.chomp!.split( ',' )
      if block.length == 4
        Minecraft::Block.new( block[0], block[1], block[2], block[3] )
      else
        raise ArgumentError, 'Invalid block string'
      end

    end

    def self.get_block_id_from_name( block_name )

      @@block_names.find{ |key,hash| hash == block_name }[0].to_i

    end

    def get_block_name

      @@block_names[ @block_type_id.to_i ]

    end

    def block_type_id=(new_block_type_id)

      @block_type_id = new_block_type_id

    end

  end

  class Player < Location

    @socket = nil

    def initialize( socket )

      @socket = socket
      super 0,0,0
      self.get_location

    end

    def get_location()

      @socket.puts 'player.getPos()'
      location = Minecraft::Location.from_string @socket.gets.chomp!

      @x = location.x
      @y = location.y
      @z = location.z

    end

  end

  class World

    @socket = nil

    def initialize( socket )

      @socket = socket

    end

    def get_block( location )

      if location.respond_to?( :xyz )

        @socket.puts 'world.getBlock(' + location.xyz + ')'
        block_string = @socket.gets
        Minecraft::Block.from_string location.xyz + ',' + block_string.to_s

      end

    end

    def set_block( location, block_type )

      if location.respond_to?( :xyz )

        block_type = Minecraft::Block.get_block_id_from_name block_type unless block_type.class == Fixnum
        @socket.puts 'world.setBlock(' + location.xyz.to_s + ',' + block_type.to_s + ')'

      end

    end

    def set_blocks( x1, y1, z1, x2, y2, z2 )

    end

  end

end

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