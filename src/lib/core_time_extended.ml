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
    let s = ["{ts:"(string_of_int t.Unix.tm_day);".";(month_of_int t.Unix.tm_mon);".";
	     (string_of_int t.Unix.tm_year);"|";(string_of_int t.Unix.tm_hour);
	     ":";(string_of_int t.Unix.tm_min);":";(string_of_int t.Unix.tm_sec);"}"] in
    let s2 = String.concat_with_sep "" s in 
    Yojson.Safe.from_string s2;;

  let of_yojson j =
    try
      let s = Yojson.Safe.to_string j in
      let splits = String.split_on_char ':' s in
      let value_half = List.nth splits 1 in
      let rbracket_i = String.index value_half '}' in 
      let value = String.sub value_half 0 rbracket_i in
      let time_date_split = String.split_on_char "|" value in
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
      { Unix.tm_sec = sec }
    with err -> Error "core_time_extended::of_yojson() failed.";;

  let pp fmt t = (Format.fprintf fmt "%s") (Time.to_filename_string t ~zone:(Time.Zone.of_utc_offset 0))
  let show t = Time.to_filename_string t ~zone:(Time.Zone.of_utc_offset 0)
  let pp_core_time_extended = pp
  let show_core_time_extended = show

  let equal_core_time_extended t1 t2 =
    not (Core.Time.is_earlier t1 ~than:t2) &&
      not (Core.Time.is_later t1 ~than:t2);;
    
  let compare_core_time_extended t1 t2 =
    if Core.Time.is_later t1 t2 then 1
    else
      if Core.Time.is_earlier t1 t2 then -1
      else 0;;
	  
  let equal = equal_core_time_extended
  let compare = compare_core_time_extended
end 
