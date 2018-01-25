defmodule Gamelet.TicTacToes.Game do
  defstruct players: {nil, nil},
            records: []

  @xaxis [1,2,3]
  @yaxis [1,2,3]

  # Coodinates of the board
  #    1 2 3
  #   +-+-+-+
  # 1 | | | |
  #   +-+-+-+
  # 2 | | | |
  #   +-+-+-+
  # 3 | | | |
  #   +-+-+-+

  def start_link do
    :gen_statem.start_link(__MODULE__, [], [])
  end

  def init([]) do
    {:ok, :initialized, %__MODULE__{}}
  end

  def callback_mode do
    :state_functions
  end

  def initialized({:call, from}, {:join_player, player}, %__MODULE__{players: {nil, nil}} = game) do
    new_game = %{game | players: {player, nil}}
    {:next_state, :waiting_other_player, new_game, {:reply, from, {:ok, :waiting_other_player}}}
  end

  def waiting_other_player({:call, from}, {:join_player, player}, %__MODULE__{players: {player, nil}} = game) do
    {:next_state, :waiting_other_player, game, {:reply, from, {:error, :you_have_already_joined}}}
  end

  def waiting_other_player({:call, from}, {:join_player, player}, %__MODULE__{players: {f, nil}} = game) when not is_nil(f) do
    new_players = {f, player}
    new_game = %{game | players: new_players}
    {:next_state, :deciding_the_turn, new_game, {:reply, from, {:ok, :deciding_the_turn, new_players}}}
  end

  def deciding_the_turn({:call, from}, :order, %__MODULE__{players: {f, s}} = game) do
    {:next_state, :first_players_turn, game, {:reply, from, {:ok, :first_players_turn, game}}}
  end

  def deciding_the_turn({:call, from}, :inverse, %__MODULE__{players: {f, s}} = game) do
    new_players_order = {s, f}
    new_game = %{game | players: new_players_order}
    {:next_state, :first_players_turn, new_game, {:reply, from, {:ok, :first_players_turn, new_game}}}
  end

  def first_players_turn({:call, from}, {:put, {:first_player, f, {x, y}} = record}, %__MODULE__{players: {f, _}, records: records} = game) when x in @xaxis and y in @yaxis do
    new_game = %{game | records: [record | records] }
    {:next_state, :second_players_turn, new_game, {:reply, from, {:ok, :second_players_turn, new_game}}}
  end

  def first_players_turn({:call, from}, {:put, {:second_player, s, {x, y}} = record}, %__MODULE__{players: {_, s}} = game) when x in @xaxis and y in @yaxis do
    {:next_state, :first_players_turn, game, {:reply, from, {:error, :first_players_turn, game}}}
  end

  def second_players_turn({:call, from}, {:put, {:second_player, s, {x, y}} = record}, %__MODULE__{players: {_, s}, records: records} = game) when x in @xaxis and y in @yaxis do
    new_game = %{game | records: [record | records] }
    {:next_state, :first_players_turn, new_game, {:reply, from, {:ok, :first_players_turn, new_game}}}
  end

  def second_players_turn({:call, from}, {:put, {:first_player, s, {x, y}} = record}, %__MODULE__{players: {f, _}, records: records} = game) when x in @xaxis and y in @yaxis do
    {:next_state, :second_players_turn, game, {:reply, from, {:error, :second_players_turn, game}}}
  end
end
