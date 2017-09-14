#Basic Player Class

class Player
  attr_accessor :name

  def initialize(name='Player')
    @name=name
  end

protected

#user_input : Gets user input for a pin
  def user_input(x)
  loop do
    puts "Position: #{x+1} What Color? 1 : Red -- 2 : Blue -- 3 : Orange -- 4 : Green"
      code_color = gets.chomp.to_i
        if code_color.between?(1,4)
          return code_color
        else 
          puts "Invalid Input"
        end
  end
  end

#enter_code: Allows a user to create a 4 color code, for guessing or creating codes. 
  def enter_code(positions,colors)
  	code_colors = []
  	code = Hash.new
  	  4.times do |x|
  	  	code_color = user_input(x)
          code_colors[x] = case code_color
          when 1 then 'red'
          when 2 then 'blue'
          when 3 then 'orange'
          when 4 then 'green'
          else 
        	  puts "Selection Invalid"
          end
  	    code[positions[x]] = code_colors[x]
  	  end
  	  return code
  end

end #Player class end

class CodeMaker < Player
	attr_accessor :code
  
#generate_code: Computer generates a random code 
  def generate_code(positions,colors)
    @code = Hash.new
  	code_colors = Array.new(4) {colors.sample}
  	4.times do |x|
  	  @code[positions[x]] = code_colors[x]
  	end
  	code = @code.clone
  	return code
  end

#set_code: Player can set a code
  def set_code(positions,colors)

  		@code = enter_code(positions,colors)

  end

#give_feedback: Gives feedback after a guess
  def give_feedback(current_guess)
  	temp_code = @code.clone
  	temp_guess = current_guess.clone                     
    pegs = []
  
    
    4.times do |x|
    	if temp_code[x]==temp_guess[x]
    		pegs<<2
    		temp_code.delete(x)
    		temp_guess.delete(x)
    	end
    end	

    code_colors = temp_code.values
    guess_colors = temp_guess.values

    guess_colors.each do |x|
      if code_colors.include? x
        pegs<<1
    	code_colors.delete_at(code_colors.index(x))
      end
    end
    return pegs
  end

#show_pegs: Shows Pegs Generated
  def show_pegs(pegs)
    pegs.each do |x|
      case x
      when 2 then puts "Black Peg"
      when 1 then puts "White Peg"
      else
      	puts "Invalid Peg"
      end
    end
  end

#win? : Checks to see if the player has cracked the code
  def win?(pegs)
    if pegs.size == 4
	  if pegs.all? {|e| e==2}
		  return true
      else
        return false
      end
    else
      return false
    end
  end

end #Codemaker class end


class CodeBreaker < Player
  attr_accessor :guess, :matches

  def initialize
  	@matches = Hash.new
  	@guess = Hash.new
  end

#break_code: Code breaker player makes up to 12 guesses at the code and receives feedback for each one.
  def break_code(positions,colors,codemaker)
    turn_count = 1
    12.times do |x|            
    	guess = enter_code(positions,colors)
    	pegs = codemaker.give_feedback(guess)
    	if codemaker.win?(pegs)
    		puts "You Win!!"
    		break
    	end
    	codemaker.show_pegs(pegs)
    	turn_count+=1
    	puts ''
    	puts ''	
    end

    if turn_count == 12
      unless codemaker.win?(pegs)
        puts "You failed to crack the code."
      else
    	puts "You Win!!"
      end
    end

  end

#find_matches: Identifies matches when the computer attempts to break the code.
  def find_matches(current_guess,code,colors)  
    4.times do |x|
      if current_guess[x] == code[x]
      	match = current_guess.values[x]
      	guess_builder(x,match) 
      elsif !code.values.include?(current_guess[x]) && (colors.include? current_guess[x])
      	puts "no color"
      	colors.delete_at(colors.index(current_guess[x]))     	         
      end
    end
    puts colors
  end

  def guess_builder(position,match)
  	@guess.store(position,match)
  end
#comp_guesser: Computer generates code for any positions that aren't already matched
  def comp_guesser(positions,colors)

  	code_colors = Array.new(4) {colors.sample}
  	current_guess = Hash.new
  	overall_guess = @guess.clone
    
  	4.times do |x|
  		unless @guess[x]
          current_guess[x] = code_colors[x]
        else
          current_guess[x] = overall_guess[x]
  		end 
  	end
  	return current_guess
  end


end #Codebreaker class end

class GameBoard
  attr_reader :positions, :colors, :type


  def initialize
  	@positions = [0,1,2,3]
  	@colors =  ['red','blue','orange','green']
  	@type = game_type
  end

#computer_maker: Play process when computer generates the code
  def computer_maker
  	computer = CodeMaker.new
  	computer.code = computer.generate_code(@positions,@colors)
    breaker = CodeBreaker.new
  	breaker.name = get_player
  	breaker.break_code(@positions,@colors,computer)
  end

#computer_breaker: Play process when computer tries to break the code
  def computer_breaker
  	player=CodeMaker.new
  	player.code= player.set_code(@positions,@colors)

  	computer = CodeBreaker.new

  	12.times do |x|
  	  current_guess = computer.comp_guesser(@positions,@colors) #computer generates code and we get matches
  	  computer.find_matches(current_guess,player.code,@colors)
  	  feedback = player.give_feedback(computer.guess)
  	  if player.win?(feedback)
  		return puts "Computer Wins in #{x+1} turns!"
      end
    end
    puts "Computer Was Unable to Crack the Code!"
  end

protected

#game_type : Asks the user whether it is a 1 person or 2 person game
  def game_type
  	
  	loop do
  	puts "1: Be the CodeBreaker 2: Be the CodeMaker (Enter '1' or '2')"
  	  type=gets.chomp.to_i
  	  if type == 1 || type == 2
        return type
      else
        puts "Invalid Input"
      end
    end
  end

#get_player : Gets the players name.
  def get_player
    puts "What is your name?"
    name = gets.chomp.to_s
  end

end #GameBoard class end



#Plays the game
def play()
  game = GameBoard.new  
  if game.type == 1 
  	game.computer_maker
  elsif game.type == 2
  	game.computer_breaker
  end
end

play




