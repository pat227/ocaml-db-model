(*Does SQL allow us to insert using a float value?
  New module for date type, represented as days since epoch? 
    As intervals of 24 hours starting from epoch + 1 second?
  New module for time type, as seconds?

READ sql standard...literals.
*)
module Date_time_extended = struct
  type t = Unix.tm

  let month_of_int i =
    match i with
    | 0 -> "Jan"
    | 1 -> "Feb"
    | 2 -> "Mar"
    | 3 -> "Apr"
    | 4 -> "May"
    | 5 -> "June"
    | 6 -> "July"
    | 7 -> "Aug"
    | 8 -> "Sept"
    | 9 -> "Oct"
    | 10 -> "Nov"
    | 11 -> "Dec"
    | _ -> raise (Failure "month_of_int() input out of bounds, must be 0 - 11")
     
  let to_yojson t =
    let f,t2 = Unix.mktime t in
    let s = String.concat "" ["{dt:";(string_of_float f);"}"] in 
    Yojson.Safe.from_string s;;

  let of_yojson j =
    try
      let s = Yojson.Safe.to_string j in
      let splits = String.split_on_char ':' s in
      let value_half = List.nth splits 1 in
      let rbracket_i = String.index value_half '}' in 
      let value = String.sub value_half 0 rbracket_i in
      let f = float_of_string value in
      Ok (Unix.gmtime f)
      (*let time_date_split = String.split_on_char "|" value in
      let time_value = List.nth time_date_split 0 in
      let date_value = List.nth time_date_split 1 in
      let time_parts = String.split_on_char ':' time_value in
      let hour = List.nth time_parts 0 in
      let min = List.nth time_parts 1 in
      let sec = List.nth time_parts 2 in
      let date_parts = String.split_on_char '.' date_value in
      let day = List.nth date_parts 0 in
      let month = List.nth date_parts 1 in
      let year = List.nth date_parts 2 in 
      let tl = 
      { Unix.tm_sec = sec; tm_min = min;
        tm_hour = hour; tm_mday = day;
	tm_mon = month; tm_year = year;
	tm_wday = 0;
	tm_yday = 0;
	tm_isdst = false;
      } in 
      let f,t2 = Unix.mktime tl in t2 *)
    with err -> Error "date_time_extended::of_yojson() failed.";;

  let to_string t =
    String.concat
      "" [(string_of_int ((t.Unix.tm_year)+1900));"-";
	  (string_of_int t.Unix.tm_mon);"-";(string_of_int t.Unix.tm_mday);" ";
	  (string_of_int t.Unix.tm_hour);":";(string_of_int t.Unix.tm_min);":";
	  (string_of_int t.Unix.tm_sec)];;

  let show t =
    to_string t;;

  let pp fmt t = (Format.fprintf fmt "%s") (to_string t)

  let of_string_exn s =
    try
      let splits = String.split_on_char ' ' s in
      let date_half = List.nth splits 0 in
      let time_half = List.nth splits 1 in
      let date_parts = String.split_on_char '-' date_half in
      let time_parts = String.split_on_char ':' time_half in
      let year = (int_of_string (List.nth date_parts 0)) - 1900 in
      let month = int_of_string (List.nth date_parts 1) in 
      let day = int_of_string (List.nth date_parts 2) in
      let hour = int_of_string (List.nth time_parts 0) in
      let min = int_of_string (List.nth time_parts 1) in
      let sec = int_of_string (List.nth time_parts 2) in
      let tm = { Unix.tm_sec = sec; tm_min = min;
		 tm_hour = hour; tm_mday = day;
		 tm_mon = month; tm_year = year;
		 tm_wday = 0;
		 tm_yday = 0;
		 tm_isdst = false;
	       } in 
      let _f,t = Unix.mktime tm in Ok t
    with err -> Error "date_time_extended::of_string() failed";;

  let equal_datetime_extended t1 t2 =
    let f1,tm1 = Unix.mktime t1 in
    let f2,tm2 = Unix.mktime t2 in 
    not (f1 > f2) &&
      not (f2 < f2);;

  let compare_datetime_extended t1 t2 =
    let f1,tm1 = Unix.mktime t1 in
    let f2,tm2 = Unix.mktime t2 in 
    if f1 > f2 then 1
    else
      if f1 < f2 then -1
      else 0;;

  let equal = equal_datetime_extended
  let compare = compare_datetime_extended
end
