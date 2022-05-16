require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = []
    10.times { @letters.push(('a'..'z').to_a[rand(26)]) }
    @letters
  end

  def score
    @result = {}
    letters = params[:letters].chars
    letters.delete(' ')
    #- API call and parsing
    answer = URI.open("https://wagon-dictionary.herokuapp.com/#{params[:score]}").read
    is_it_a_word = JSON.parse(answer)
    #- Check if it is engish and/or in the grid
    res = winning_conditions(letters, @result, is_it_a_word['found'], is_it_a_word['word'])
    @result[:message] = "Well done!😄 #{is_it_a_word['word']} it is a word" if res
  end

  private

  def winning_conditions(letters, result, value, word)
    return includes_letters?(letters, word, result) if value

    result[:score] = 0
    result[:message] = "Oooh man!😱 #{word} not an english word"
    false
  end

  def includes_letters?(letters, word, result)
    matching_arr = []
    letters.each { |letter| word.include?(letter.downcase) ? matching_arr.push(letter.downcase) : next }

    if matching_arr.length >= word.length && matching_arr.all? { |letter| word.include?(letter) }
      true

    else
      result[:message] = "Oooh man!😱 #{word} not in the grid"
      false
    end
  end

  def calc_score(end_time, start_time, word)
    word.length / calc_time(start_time, end_time)
  end

  def calc_time(start_time, end_time)
    end_time - start_time
  end
end
