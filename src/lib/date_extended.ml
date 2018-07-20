(*Does SQL allow us to insert using a float value?
  New module for date type, represented as days since epoch? 
    As intervals of 24 hours starting from epoch + 1 second?
  New module for time type, as seconds?

READ sql standard...literals.
*)
module Date_extended = struct
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
    let s = String.concat "" ["{date:";(string_of_float f);"}"] in 
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
	tm_mon = month; tn_year = year;
	tm_wday = 0;
	tm_yday = 0;
	tm_isdst = false;
      } in 
      let f,t2 = Unix.mktime tl in t2 *)
    with err -> Error "date_extended::of_yojson() failed.";;

  let to_string t =
    String.concat
      "" [(string_of_int ((t.Unix.tm_year) + 1900));
	  "-";(string_of_int t.Unix.tm_mon);"-";
	  (string_of_int t.Unix.tm_mday)];;

  let show t =
    String.concat
      "" [(string_of_int t.Unix.tm_year);"-";
	  (string_of_int t.Unix.tm_mon);"-";(string_of_int t.Unix.tm_mday)];;
  let pp fmt t = (Format.fprintf fmt "%s") (to_string t)
  let of_string_exn s =
    try
      let date_parts = String.split_on_char '-' s in
      let year = (int_of_string (List.nth date_parts 0)) - 1900 in
      let month = int_of_string (List.nth date_parts 1) in 
      let day = int_of_string (List.nth date_parts 2) in
      let tm = { Unix.tm_sec = 0; tm_min = 0; tm_hour = 0;
		 tm_mday = day; tm_mon = month; tm_year = year;
		 tm_wday = 0;
		 tm_yday = 0;
		 tm_isdst = false;
	       } in 
      let _f,t = Unix.mktime tm in t
    with err ->
      raise (Failure "date_extended::of_string() failed");;
    
  let equal_date_extended t1 t2 =
    let f1,tm1 = Unix.mktime t1 in
    let f2,tm2 = Unix.mktime t2 in
    (tm1.Unix.tm_year = tm2.Unix.tm_year) && 
      (tm1.Unix.tm_mon = t2.Unix.tm_mon) &&
	(tm1.Unix.tm_mday = tm2.Unix.tm_mday) &&
	  (tm1.Unix.tm_hour = tm2.Unix.tm_hour) &&
	    (tm1.Unix.tm_sec = tm2.Unix.tm_sec);;

  let compare_date_extended t1 t2 =
    let _f1,tm1 = Unix.mktime t1 in
    let _f2,tm2 = Unix.mktime t2 in 
    if tm1.Unix.tm_year > tm2.Unix.tm_year then 1
    else if tm1.Unix.tm_year = tm2.Unix.tm_year && tm1.Unix.tm_mon > tm2.Unix.tm_mon then 1
    else if tm1.Unix.tm_year = tm2.Unix.tm_year && tm1.Unix.tm_mon = tm2.Unix.tm_mon &&
	      tm1.Unix.tm_mday > tm2.Unix.tm_mday then 1
    else if tm1.Unix.tm_year = tm2.Unix.tm_year && tm1.Unix.tm_mon = tm2.Unix.tm_mon &&
	      tm1.Unix.tm_mday = tm2.Unix.tm_mday then 0
    else -1;;

  let equal = equal_date_extended
  let compare = compare_date_extended
end
