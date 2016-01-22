require "pstore"
class ComputerFunctions
	@@finalword = ""
	@@guessword = ""
	@@guesses = 6
	
	attr_accessor :finalword, :guessword, :guesses

	def choose_word
		words = File.readlines("5desk.txt")
		until @@finalword.length >= 5 && @@finalword.length <= 12 
			@@finalword = words[rand(0...61405)].downcase.strip
		end
		make_guessword
		return @@finalword, @@guessword
	end

	def make_guessword
		@@finalword.each_char {|i| @@guessword << "_"}
	end

	def check(guess)
		if @@finalword.include? guess
			updateguesses(guess)
			return @@guessword, @@guesses
		else
			@@guesses -= 1
			puts "Sorry #{guess} is not in the word. You have #{@@guesses} guesses left"
			return @@guessword, @@guesses
		end
	end

	def updateguesses(guess)
		counter = 0
		@@finalword.each_char do |i|
			if i == guess
				@@guessword[counter] = i
				counter += 1
			else
				counter += 1
			end
		end
	end

end

class Guesser
	@@guessed_letters = []
	def guess
		puts "guess any letter"
		letter = gets.chomp.downcase
			if letter == "save"
				return "save"
			end
		letter = checkguess(letter)
		@@guessed_letters << letter
		return letter
	end

	def checkguess(letter)
		if letter.length != 1
			puts "Sorry, only guess one letter at a time"
			puts "Try Again"
			guess
		elsif @@guessed_letters.include? letter
			puts "You already guessed that letter"
			puts "Try Again"
			guess
		else
			return letter
		end
	end

	def load(guessword)
		guessword.each_char do |i|
			@@guessed_letters << i
		end
	end
end


class NewGame < ComputerFunctions
	@@computer = ComputerFunctions.new
	@@person = Guesser.new
	
	def start_game
		puts "type 'load' to open a saved game, push anything else to continue with a new game"
		input = gets.chomp.downcase
		if input == "load"
			loadgame
			@@person.load(@@guessword)
			

		else
			@@computer.choose_word
			@@computer.finalword

		end
	end
	def run_game
		start_game
		guessing
		
		
	end

	def guessing
		puts "save at any time by typing save instead of a guess"
		#puts "guesses #{@@guesses} guessword #{@@guessword} finalword #{@@finalword}"
		#puts "guessed letters #{@@guessed_letters}"
		until @@guesses == 0 || @@guessword == @@finalword
			guess = @@person.guess
				if guess == "save"
					savegame
					puts "saving game"
					break
				end
			@@guessword, @@guesses = @@computer.check(guess)
			puts @@guessword
		end
		if @@guesses == 0
			puts "Sorry you lose. The word was #{@@finalword}"
		elsif @@guessword == @@finalword
			puts "Hooray! You win!"
		end
	end

	def savegame
		data = PStore.new("savefile")
		data.transaction do 
			data[:finalword] = @@finalword
			data[:guessword] = @@guessword
			data[:guesses] = @@guesses
		end
	end

	def loadgame
		data = PStore.new("savefile")
		data.transaction do
			@@finalword = data[:finalword]
			@@guessword = data[:guessword]
			@@guesses = data[:guesses]

		end
	end

end

game = NewGame.new
game.run_game

