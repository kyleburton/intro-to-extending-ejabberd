-module(muc_interact).

%-include("ejabberd.hrl").
%-include("jlib.hrl").
-include("mod_muc_room.hrl").


-export([
    list_rooms/0,
    create_room/1,
    join/1,
    get_room_config/1,
    get_room_pid/1,
    get_room_state/1,
    get_room_history/1,
    get_room_occupants/1,
    save_room_state/2,
    save_all_room_state/1,
    restore_all_room_state/1,
    load_room_state/1,
    restore_room_history_from_file/1,
    restore_room_history/2]).

local_init() ->
    mnesia:change_table_copy_type(schema, node(), disc_copies).

join(OtherNode) ->
  mnesia:stop(),
  mnesia:delete_schema([node()]),
  application:start(mnesia),
  mnesia:change_config(extra_db_nodes, [OtherNode]),
  local_init().

all_muc_rooms() ->
  TableName = muc_room,
  mnesia:dirty_all_keys(TableName).

list_rooms() ->
  TableName = muc_room,
  Iterator = fun(RoomName) ->
      io:fwrite("Room: ~p~n", [RoomName])
  end,
  case mnesia:is_transaction() of
    true ->
      lists:foreach(Iterator,mnesia:all_keys(TableName));
    false ->
      Exec = fun({Fun, Tab}) -> lists:foreach(Fun, mnesia:all_keys(Tab)) end,
      mnesia:activity(transaction, Exec, [{Iterator, TableName}], mnesia_frag)
  end.

get_room_config(RoomName) ->
  case mnesia:dirty_read(muc_room, RoomName) of
    {aborted, Reason} ->
      {aborted, Reason};
    [Pid|_] ->
      Pid;
    _ ->
      {notfound, RoomName}
  end.

get_room_pid(RoomName) ->
  case mnesia:dirty_read(muc_online_room, RoomName) of
    {aborted, Reason} ->
      {aborted, Reason};
    [{muc_online_room,_RoomName,Pid}|_] ->
      Pid;
    _ ->
      {notfound, RoomName}
  end.

get_room_state(RoomName) ->
  Room1Pid = get_room_pid(RoomName),
  case gen_fsm:sync_send_all_state_event(Room1Pid, get_state) of
    {ok, State} ->
      State;
    _ ->
      {notfound, RoomName}
  end.

get_room_history(RoomName) ->
  case get_room_state(RoomName) of 
    {notfound, RoomName} ->
      {notfound, RoomName};
    State ->
      #state{history = History} = State,
      History
  end.

save_room_state(RoomName, Path) ->
  State = muc_interact:get_room_state(RoomName),
  {RName, SName} = RoomName,
  FileName = string:concat(Path, string:join(["room", RName, SName, "state"], ".")),
  RoomInfo = {RoomName,state,State},
  file:write_file(FileName, erlang:term_to_binary(RoomInfo)).

save_all_room_state(Path) ->
  lists:foreach(fun (RoomName) ->
        save_room_state(RoomName, Path)
    end,
    all_muc_rooms()).

restore_all_room_state(Path) ->
  Pattern = string:concat(Path,"/room.*.state"),
  ?INFO_MSG("Path=~p all state files: ~p~n", [Path, filelib:wildcard(Pattern)]),
  lists:foreach(fun (FileName) ->
        restore_room_history_from_file(FileName)
    end,
    filelib:wildcard(Pattern)).

load_room_state(FileName) ->
  {ok, Data} = file:read_file(FileName),
  erlang:binary_to_term(Data).

restore_room_history(RoomName, SavedState) ->
  Room1Pid = get_room_pid(RoomName),
  CurrentState = get_room_state(RoomName),
  NewState = CurrentState#state{history = SavedState#state.history},
  gen_fsm:sync_send_all_state_event(Room1Pid, {change_state, NewState}).

restore_room_history_from_file(FileName) ->
  {RoomName, state, OldState} = muc_interact:load_room_state(FileName),
  muc_interact:restore_room_history(RoomName, OldState).


get_room_occupants(_RoomName) ->
  {error, "Not implemented yet"}.

create_room(_RoomName) ->
  {error, "Not implemented"}.


