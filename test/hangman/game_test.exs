defmodule Hangman.GameTest do
  use ExUnit.Case

  alias Hangman.Game

  test "new_game/0 returns structure" do
    game = Game.new_game()

    assert game.game_state == :initializing
    assert game.turns_left == 7
    assert length(game.letters) > 0
  end

  test "state isn't changed for :won or :lost game" do
    for state <- [ :won, :lost ] do
      game = Game.new_game() |> Map.put(:game_state, state)

      assert game == Game.make_move(game, "x")
    end
  end

  test "first occurence of letter is not already used" do
    game = Game.new_game() |> Game.make_move("x")

    assert game.game_state != :already_used
  end

  test "second occurence of letter is already used" do
    game = Game.new_game() |> Game.make_move("x")
    assert game.game_state != :already_used
    game = Game.make_move(game, "x")
    assert game.game_state == :already_used
  end

  test "a good guess is recognized" do
    game = Game.new_game("wibble") |> Game.make_move("w")

    assert game.game_state == :good_guess
    assert game.turns_left == 7
  end

  test "a guessed word is a won game" do
    game = Game.new_game("wibble")

    moves = [
      {"w", :good_guess},
      {"i", :good_guess},
      {"b", :good_guess},
      {"l", :good_guess},
      {"e", :won}
    ]

    Enum.reduce(moves, game, fn({letter, game_state}, game) ->
      game = Game.make_move(game, letter)

      assert game.game_state == game_state
      assert game.turns_left == 7

      game
    end)
  end

  test "a bad guess is recognized" do
    game = Game.new_game("wibble") |> Game.make_move("x")

    assert game.game_state == :bad_guess
    assert game.turns_left == 6
  end

  test "a lost game is recognized" do
    game = Game.new_game("wibble")

    moves = [
      {"a", 6, :bad_guess},
      {"c", 5, :bad_guess},
      {"d", 4, :bad_guess},
      {"f", 3, :bad_guess},
      {"g", 2, :bad_guess},
      {"h", 1, :bad_guess},
      {"j", 0, :lost}
    ]

    Enum.reduce(moves, game, fn({letter, turns_left, game_state}, game) ->
      game = Game.make_move(game, letter)

      assert game.game_state == game_state
      assert game.turns_left == turns_left

      game
    end)
  end
end
