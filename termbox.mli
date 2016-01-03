(** Minimalistic API for creating text-based interfaces. Alternative to ncurses.

    For API documentation see {{: https://github.com/nsf/termbox/blob/master/src/termbox.h } termbox.h}.

    One important difference is that values of TB_KEY_* that are in the ASCII range (< 256) are reported as Ascii and not Key.

    So if you wanted to check for [Ctrl + C] you'd do something like this:

    {[
    match Termbox.poll_event () with
    | Ascii c when c = '\x03' (* CTRL_C *) -> ...
    ]}
*)

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


val init : unit -> int
val shutdown : unit -> unit

val width : unit -> int
val height : unit -> int

val clear : unit -> unit
val set_clear_attributes : color -> color -> unit

val present : unit -> unit

val set_cursor : int -> int -> unit
val hide_cursor : unit -> unit

val set_cell_char : ?fg : color -> ?bg : color -> int -> int -> char -> unit
val set_cell_utf8 : ?fg : color -> ?bg : color -> int -> int -> int32 -> unit

val poll_event : unit -> event
val peek_event : int -> event option
