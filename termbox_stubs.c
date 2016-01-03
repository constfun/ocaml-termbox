#define CAML_NAME_SPACE

#include <string.h>

#include <termbox.h>

#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/callback.h>
#include <caml/fail.h>


#define raise_error(E) \
	caml_raise_constant(*caml_named_value(E)); \
	CAMLreturn(1); // Never executed, but needed to prevent a compile time error.


CAMLprim value tbstub_init() {

	return Val_int(tb_init());
}


CAMLprim value tbstub_width() {

	return Val_int(tb_width());
}


CAMLprim value tbstub_height() {

	return Val_int(tb_height());
}


void tbstub_set_clear_attributes(value caml_fg, value caml_bg) {

	CAMLparam2(caml_fg, caml_bg);

	tb_set_clear_attributes(Int_val(caml_fg), Int_val(caml_bg));

	CAMLreturn0;
}


void tbstub_set_cursor(value caml_cx, value caml_cy) {

	CAMLparam2(caml_cx, caml_cy);

	tb_set_cursor(Int_val(caml_cx), Int_val(caml_cy));

	CAMLreturn0;
}


void tbstub_change_cell(value caml_x, value caml_y, value caml_ch, value caml_fg, value caml_bg) {

	CAMLparam5(caml_x, caml_y, caml_ch, caml_fg, caml_bg);

	tb_change_cell(Int_val(caml_x), Int_val(caml_y), Int32_val(caml_ch), Int_val(caml_fg), Int_val(caml_bg));

	CAMLreturn0;
}


CAMLprim value tbstub_poll_event() {

	CAMLparam0();
	CAMLlocal3(caml_e, caml_ch, caml_size);

	struct tb_event e;
	tb_poll_event(&e);

	// type event =
	// | Key of key           -> block with tag 0
	// | Ascii of char        -> block with tag 1
	// | Utf8 of int32        -> block with tag 2
	// | Resize of int * int  -> block with tag 3

	if( e.type == TB_EVENT_KEY ) {

		// Key
		//
		// We deviate from tb_event definition of key here.
		// Some keys are really low enough to be considered ascii values.
		//
		// tb_poll_event reports ch as 0 whenever a 'key' is present.
		if( e.ch == 0 && e.key > 0xFF ) {

			caml_e = caml_alloc(1, 0);
			// We use a bit of a trick here to convert e.key to
			// type key =
			// | F1           -> Val_int(0)
			// ...
			// | Arrow_right  -> Val_int(21)
			//
			// All (non-ascii) TB_KEY_* values are defined as (0xFFFF-0)(F1)...(0xFFFF-21)(ARROW_RIGHT).
			// Notice the pattern ->                                  ^                ^
			//
			// By "restoring" that offset number we get the int value that we need to represent the variant.
			Store_field(caml_e, 0, Val_int(0xFFFF - e.key));
		}
		// Ascii
		//
		// tb_poll_event reports key as 0 whenever a ch is present.
		else if( e.ch <= 0xFF ) {

			caml_e = caml_alloc(1, 1);
			// Another bit of tricky code.
			// At this point, we know that either e.key < 255 && e.ch = 0
			//                                 or e.key = 0 && e.ch < 255
			// So we just bitwise or the two values to get our ascii value.
			Store_field(caml_e, 0, Val_int(e.ch | e.key));
		}
		// Utf8
		else {

			// All else failed, so we need to represent the ch value as an int32 block,
			// since OCaml has no unicode support.
			caml_e = caml_alloc(1, 2);
			caml_ch = caml_copy_int32(e.ch);
			Store_field(caml_e, 0, caml_ch);
		}
	}
	// Resize
	else {
		caml_size = caml_alloc_tuple(2);
		Store_field(caml_size, 0, Val_int(e.w));
		Store_field(caml_size, 1, Val_int(e.h));

		caml_e = caml_alloc(1, 3);
		Store_field(caml_e, 0, caml_size);
	}

	CAMLreturn(caml_e);
}

CAMLprim value tbstub_peek_event(value caml_timeout) {

	CAMLparam1(caml_timeout);
	CAMLlocal4(caml_e, caml_ch, caml_size, caml_optional);
  caml_optional = caml_alloc(1, 0);

	struct tb_event e;
	tb_peek_event(&e, Int_val(caml_timeout));

	// type event =
	// | Key of key           -> block with tag 0
	// | Ascii of char        -> block with tag 1
	// | Utf8 of int32        -> block with tag 2
	// | Resize of int * int  -> block with tag 3

	if( e.type == TB_EVENT_KEY ) {

		// Key
		//
		// We deviate from tb_event definition of key here.
		// Some keys are really low enough to be considered ascii values.
		//
		// tb_poll_event reports ch as 0 whenever a 'key' is present.
		if( e.ch == 0 && e.key > 0xFF ) {

			caml_e = caml_alloc(1, 0);
			// We use a bit of a trick here to convert e.key to
			// type key =
			// | F1           -> Val_int(0)
			// ...
			// | Arrow_right  -> Val_int(21)
			//
			// All (non-ascii) TB_KEY_* values are defined as (0xFFFF-0)(F1)...(0xFFFF-21)(ARROW_RIGHT).
			// Notice the pattern ->                                  ^                ^
			//
			// By "restoring" that offset number we get the int value that we need to represent the variant.
			Store_field(caml_e, 0, Val_int(0xFFFF - e.key));
      Store_field(caml_optional, 0, caml_e);
      CAMLreturn(caml_optional);
		}
    // Empty
    // There was no event, so let's return None.
    else if( e.ch == 0x00 ) {
      CAMLreturn(Val_int(0));
    }
		// Ascii
		//
		// tb_poll_event reports key as 0 whenever a ch is present.
		else if( e.ch <= 0xFF ) {

			caml_e = caml_alloc(1, 1);
			// Another bit of tricky code.
			// At this point, we know that either e.key < 255 && e.ch = 0
			//                                 or e.key = 0 && e.ch < 255
			// So we just bitwise or the two values to get our ascii value.
			Store_field(caml_e, 0, Val_int(e.ch | e.key));
      Store_field(caml_optional, 0, caml_e);
      CAMLreturn(caml_optional);
		}
		// Utf8
		else {

			// All else failed, so we need to represent the ch value as an int32 block,
			// since OCaml has no unicode support.
			caml_e = caml_alloc(1, 2);
			caml_ch = caml_copy_int32(e.ch);
			Store_field(caml_e, 0, caml_ch);
      Store_field(caml_optional, 0, caml_e);
      CAMLreturn(caml_optional);
		}
	}
	// Resize
	else {
		caml_size = caml_alloc_tuple(2);
		Store_field(caml_size, 0, Val_int(e.w));
		Store_field(caml_size, 1, Val_int(e.h));

		caml_e = caml_alloc(1, 3);
		Store_field(caml_e, 0, caml_size);
    Store_field(caml_optional, 0, caml_e);
    CAMLreturn(caml_optional);
	}
}
