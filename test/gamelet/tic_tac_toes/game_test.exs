defmodule Gamelet.GameTest do
  use ExUnit.Case, async: true

  test "start_link/0" do
    assert {:ok, _pid} = Gamelet.TicTacToes.Game.start_link
  end

  describe "state is initialized" do
    test "join player" do
      {:ok, pid} = Gamelet.TicTacToes.Game.start_link
      user1 = UUID.uuid4()
      assert :gen_statem.call(pid, {:join_player, user1}) == {:ok, :waiting_other_player}
    end
  end

  describe "state is waiting_other_player" do
    setup do
      user1 = UUID.uuid4()
      {:ok, pid} = Gamelet.TicTacToes.Game.start_link
      {:ok, :waiting_other_player} = :gen_statem.call(pid, {:join_player, user1})
      {:ok, pid: pid, user1: user1}
    end

    test "join other player", %{pid: pid, user1: user1} do
      user2 = UUID.uuid4()
      assert :gen_statem.call(pid, {:join_player, user2}) == {:ok, :deciding_the_turn, {user1, user2}}
    end

    test "join twice", %{pid: pid, user1: user1}  do
      assert :gen_statem.call(pid, {:join_player, user1}) == {:error, :you_have_already_joined}
    end
  end

  describe "state is deciding_the_turn" do
    setup do
      user1 = UUID.uuid4()
      user2 = UUID.uuid4()
      {:ok, pid} = Gamelet.TicTacToes.Game.start_link
      {:ok, _} = :gen_statem.call(pid, {:join_player, user1})
      {:ok, :deciding_the_turn, _} = :gen_statem.call(pid, {:join_player, user2})
      {:ok, pid: pid, user1: user1, user2: user2}
    end

    test "order the player turn", %{pid: pid, user1: user1, user2: user2} do
      expected_game = %Gamelet.TicTacToes.Game{players: {user1, user2},
                                               records: []}
      assert :gen_statem.call(pid, :order) == {:ok, :first_players_turn, expected_game}
    end

    test "inverse the player turn", %{pid: pid, user1: user1, user2: user2} do
      expected_game = %Gamelet.TicTacToes.Game{players: {user2, user1},
                                               records: []}
      assert :gen_statem.call(pid, :inverse) == {:ok, :first_players_turn, expected_game}
    end
  end

  describe "state is first_players_turn" do
    setup do
      user1 = UUID.uuid4()
      user2 = UUID.uuid4()
      {:ok, pid} = Gamelet.TicTacToes.Game.start_link
      {:ok, _} = :gen_statem.call(pid, {:join_player, user1})
      {:ok, _, _} = :gen_statem.call(pid, {:join_player, user2})
      {:ok, :first_players_turn, game} = :gen_statem.call(pid, :order)
      {:ok, pid: pid, user1: user1, user2: user2, game: game}
    end

    test "first player puts a mark on the board", %{pid: pid, user1: user1, user2: user2, game: game} do
      expected_game = %{game | records: [{:first_player, user1, {1, 1}}]}
      assert :gen_statem.call(pid, {:put, {:first_player, user1, {1, 1}}}) == {:ok, :second_players_turn, expected_game}
    end

    test "second player puts a mark on the board", %{pid: pid, user1: user1, user2: user2, game: game} do
      assert :gen_statem.call(pid, {:put, {:second_player, user2, {1, 1}}}) == {:error, :first_players_turn, game}
    end

    @tag skip: "TODO"
    test "first player puts a mark on the board and win"

    @tag skip: "TODO"
    test "first player puts a mark which have been already marked"

    @tag skip: "TODO"
    test "first player puts an invalid record"

    @tag skip: "TODO"
    test "first player puts a mark which is invalid coodinates"

    @tag skip: "TODO"
    test "first player puts with invalid players id"
  end

  describe "state is second_players_turn" do
    setup do
      user1 = UUID.uuid4()
      user2 = UUID.uuid4()
      {:ok, pid} = Gamelet.TicTacToes.Game.start_link
      {:ok, _} = :gen_statem.call(pid, {:join_player, user1})
      {:ok, _, _} = :gen_statem.call(pid, {:join_player, user2})
      {:ok, _, _} = :gen_statem.call(pid, :order)
      {:ok, :second_players_turn, game} = :gen_statem.call(pid, {:put, {:first_player, user1, {1, 1}}})
      {:ok, pid: pid, user1: user1, user2: user2, game: game}
    end

    test "second player puts a board", %{pid: pid, user1: user1, user2: user2, game: game} do
      expected_game = %{game | records: [{:second_player, user2, {2, 2}},
                                         {:first_player, user1, {1, 1}}]}
      assert :gen_statem.call(pid, {:put, {:second_player, user2, {2, 2}}}) == {:ok, :first_players_turn, expected_game}
    end

    test "first player puts a board", %{pid: pid, user1: user1, user2: user2, game: game} do
      assert :gen_statem.call(pid, {:put, {:first_player, user1, {2, 2}}}) == {:error, :second_players_turn, game}
    end

    @tag skip: "TODO"
    test "second player puts a mark on the board and win"

    @tag skip: "TODO"
    test "second player puts a mark which have been already marked"

    @tag skip: "TODO"
    test "second player puts an invalid record"

    @tag skip: "TODO"
    test "second player puts a mark which is invalid coodinates"

    @tag skip: "TODO"
    test "second player puts with invalid players id"
  end

  describe "state is finished" do
  end
end
