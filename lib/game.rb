class Game

  attr_reader :answer, :guesses

  def initialize
    @answer = Random.new.rand(101)
    @guesses = []
  end

  def get_info
    return "No guesses have been made." if guesses.empty?

    last_guess = guesses.last.to_i
    response = format_response(guesses.size, last_guess)
    return response + "too high." if last_guess > answer
    return response + "too low." if last_guess < answer
    return response + "correct." if last_guess == answer
  end

  def format_response num_of_guesses, last_guess
    "So far " +
    (num_of_guesses == 1 ? "1 guess has " : "#{num_of_guesses} guesses have ") +
    "been made. <br>" +
    "The last guess was #{last_guess} and it was "
  end

  def guess num
    guesses << num
  end

  def handle_game guess, verb, server
    guess(guess) if verb == "POST"
    return server.redirect("http://127.0.0.1:9292/game", "Redirecting...") if verb == "POST"
    return server.response_handler.write_response(get_info) if verb == "GET"
    return server.response_handler.write_response("I only take POST and GET")
  end
end