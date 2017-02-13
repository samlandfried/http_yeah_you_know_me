class Game

  attr_reader :answer, :guesses

  def initialize
    @answer = Random.new.rand(101)
    @guesses = []
  end

  def get_info
    unless guesses.empty?
      num_of_guesses = guesses.size
      last_guess = guesses.last.to_i
      response =%{
          So far #{num_of_guesses == 1 ? 
            "1 guess has" :  
            "#{num_of_guesses} guesses have"} been made.
          The last guess was #{last_guess} and it was
        }
      return response + "too high." if last_guess > answer
      return response + "too low." if last_guess < answer
      return response + "correct." if last_guess == answer
    else
      return "No guesses have been made."
    end
  end

  def guess num
    guesses << num
  end

end


# GET to /game

# A request to this verb/path combo tells us:

# a) how many guesses have been taken.
# b) if a guess has been made, it tells what the guess was and whether it was too high, too low, or correct
# POST to /game

# This is how we make a guess. The request includes a parameter named guess. The server stores the guess and sends the user a redirect response, causing the client to make a GET to /game.
