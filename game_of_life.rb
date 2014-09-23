require 'pp'
require 'colorize'

class World
    attr_accessor :width, :height, :qty_dead, :qty_alive

    def initialize(width,height, initial_fields=[])
        @width= width
        @height= height

        @qty_dead= 0
        @qty_alive= 0

        # init field
        @field= []
        @height.times do |x|
            temp_line = []
            @width.times do |y|
                temp_line << 0
            end
            @field << temp_line
        end

        if initial_fields
            initial_fields.each do |ar|
                # pp ar
                @field[ar[1]][ar[0]]= ar[2];
            end
        end

        self.calculate_alive_and_dead

    end

    def calculate_alive_and_dead
        a = 0
        d = 0
        @field.each_with_index do |yy,k2|
            yy.each_with_index do |xx,k1|
                if xx == 1
                    a += 1
                elsif xx == 0
                    d += 1
                end
            end
        end
        @qty_alive = a
        @qty_dead = d
        # pp @qty_alive
        # pp @qty_dead

    end

    def out(x=nil,y=nil)
        @field.each_with_index do |yy,k2|
            yy.each_with_index do |xx,k1|
                if xx == 0
                    print (" "+xx.to_s+" ").colorize(:blue).on_red
                end
                if xx == 1
                    print (" "+xx.to_s+" ").colorize(:red).on_blue
                end
            end
            print "\n"
        end
    end

    def live_or_die(state,live_ones_near_me)
        if ( state==1 && live_ones_near_me < 2 )
            rett= 0
        elsif ( state==1 && live_ones_near_me.between?(2,3) )
            rett= 1
        elsif ( state==1 && live_ones_near_me > 3 )
            rett= 0
        elsif ( state==0 && live_ones_near_me == 3 )
            rett= 1
        else
            rett = state
        end
    end

    def play_iterate!

        next_field= @field.clone

        @field.each_with_index do |line,y|
            line.each_with_index do |column,x|
                # puts "--- [#{x},#{y}]:"+ @field[y][x].to_s
                live_ones_near_me = 0

                places_to_check = [  [x-1,y-1], [x-1,y], [x-1,y+1], [x,y+1], [x+1,y+1], [x+1,y], [x+1,y-1], [x,y-1]  ]

                j = 0
                places_to_check.each do |place|
                    j += 1
                    xx, yy = place[0], place[1]
                    if ( ( !@field[yy].nil? && !@field[yy][xx].nil?) && yy >= 0 && xx >= 0 &&   @field[yy][xx] && @field[yy][xx] == 1 )
                        live_ones_near_me += 1
                        # pp "(#{j}) [x:#{x}, y:#{y}, "+@field[y][x].to_s+" - xx:#{xx}, yy:#{yy}, "+@field[yy][xx].to_s+"] "+live_ones_near_me.to_s
                        # puts "(#{j}) [#{xx}, #{yy}] yes!"
                    else
                        # puts "(#{j}) [#{xx},#{yy}] nope "
                    end
                end

                live_or_die= self.live_or_die( @field[y][x] , live_ones_near_me)
                # puts "   ------- [state:"+(@field[y][x].to_s)+"] [live_ones_near_me: "+live_ones_near_me.to_s + "] [live_or_die: "+live_or_die.to_s+"]"
                # pp live_or_die
                next_field[y][x]= live_or_die


            end
        end
        @field = next_field.clone

        self.calculate_alive_and_dead

    end


end



initial_fields= [ [0,1,1], [1,1,1], [2,1,1], [3,1,1], [4,1,1], [5,1,1],        [2,2,1], [1,0,1], [3,3,1], [2,4,1], [4,5,1], [5,0,1] ]

world= World.new(35,35, initial_fields)



print "\n\n\nWelcome, n00b!\n\n\n"
world.out
print "-------------------------------------------------\n"

iterations = 0
begin
    alive_percentage= (100 / (world.qty_alive.to_f + world.qty_dead.to_f) ) * world.qty_alive
    print "[iterations:#{iterations}] [#{alive_percentage.round(2).to_s}% occupied (#{world.qty_alive.to_s} alive / #{world.qty_dead.to_s} dead) ] "
    # print "'enter' to play, 'q' to quit: "
    iterations += 1

    print "\n\n"
    sleep(0.2)

    # STDOUT.flush
    # key_pressed = gets.chomp
    # if (key_pressed=='q')
    #   break
    # end
    world.play_iterate!()
    world.out


end while true

