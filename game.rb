class Game

  attr_reader :answer, :guesses

  def initialize
    @answer = Random.new.rand(10) + 1
    @guesses = []
  end

  def display_game_info
  end

  def check guess
  end
  
end


# GET to /game

# A request to this verb/path combo tells us:

# a) how many guesses have been taken.
# b) if a guess has been made, it tells what the guess was and whether it was too high, too low, or correct
# POST to /game

# This is how we make a guess. The request includes a parameter named guess. The server stores the guess and sends the user a redirect response, causing the client to make a GET to /game.
