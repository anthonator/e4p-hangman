defmodule Hangman.Game do
  defstruct(
    game_state:    :initializing,
    letters:       [],
    turns_left:    7,
    used_letters: MapSet.new(),
  )

  def make_move(game = %{ game_state: state }, _guess) when state in [ :won, :lost ] do
    game
  end

  def make_move(game, guess) do
    accept_move(game, guess, MapSet.member?(game.used_letters, guess))
  end

  def new_game(word) do
    %Hangman.Game{
      letters: word |> String.codepoints
    }
  end

  def new_game() do
    new_game(Dictionary.random_word())
  end

  def tally(game) do
    %{
      game_state: game.game_state,
      turns_left: game.turns_left,
      letters: game.letters |> reveal_used_letters(game.used_letters)
    }
  end

  #
  # private
  #

  defp accept_move(game, _guess, _already_guessed = true) do
    game |> Map.put(:game_state, :already_used)
  end

  defp accept_move(game, guess, _already_moved) do
    game
    |> Map.put(:used_letters, MapSet.put(game.used_letters, guess))
    |> score_guess(Enum.member?(game.letters, guess))
  end

  defp maybe_won(true), do: :won
  defp maybe_won(_),    do: :good_guess

  defp reveal_letter(letter, _in_word = true), do: letter
  defp reveal_letter(_letter, _not_in_word),    do: "_"

  defp reveal_used_letters(letters, used_letters) do
    letters |> Enum.map(fn(letter) -> reveal_letter(letter, MapSet.member?(used_letters, letter)) end)
  end

  defp score_guess(game, _good_guess = true) do
    new_state =
      game.letters
      |> MapSet.new()
      |> MapSet.subset?(game.used_letters)
      |> maybe_won()

    %{ game | game_state: new_state }
  end

  defp score_guess(game = %{ turns_left: 1 }, _not_good_guess) do
    %{ game | game_state: :lost, turns_left: 0 }
  end

  defp score_guess(game = %{ turns_left: turns_left }, _not_good_guess) do
    %{ game | game_state: :bad_guess, turns_left: turns_left - 1 }
  end
end
