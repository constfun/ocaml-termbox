type color =
  | Default
  | Black
  | Red
  | Green
  | Yellow
  | Blue
  | Magenta
  | Cyan
  | White


type key =
  | F1
  | F2
  | F3
  | F4
  | F5
  | F6
  | F7
  | F8
  | F9
  | F10
  | F11
  | F12
  | Insert
  | Delete
  | Home
  | End
  | Page_up
  | Page_down
  | Arrow_up
  | Arrow_down
  | Arrow_left
  | Arrow_right


type event =
  | Key of key
  | Ascii of char
  | Utf8 of int32
  | Resize of int * int


external init : unit -> int = "tbstub_init"
external shutdown : unit -> unit = "tb_shutdown"
external width : unit -> int = "tbstub_width"
external height : unit -> int = "tbstub_height"
external clear : unit -> unit = "tb_clear"
external set_clear_attributes : color -> color -> unit = "tbstub_set_clear_attributes"
external present : unit -> unit = "tb_present"
external set_cursor : int -> int -> unit = "tbstub_set_cursor"
external tb_change_cell : int -> int -> int32 -> color -> color -> unit = "tbstub_change_cell"
external poll_event : unit -> event = "tbstub_poll_event"
external peek_event : int -> event option = "tbstub_peek_event"

let hide_cursor () =
  set_cursor (-1) (-1)

let set_cell_utf8 ?(fg=Default) ?(bg=Default) x y ch =
  tb_change_cell x y ch fg bg

let set_cell_char ?(fg=Default) ?(bg=Default) x y ch =
  let ch_int32 = Int32.of_int (Char.code ch) in
  set_cell_utf8 ~fg ~bg x y ch_int32
