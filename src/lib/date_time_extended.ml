(*READ sql standard...literals. Set your server timezone and supply a timezone 
if you wish, eles don't supply a time zone and all values inserted are presumed 
to be in server tz. And regardless of all that, queries never show the tz that 
was supplied during the insert, ie, the tz supplied during insert is lost.
Core.Time, like sql, applies time zones to supplied datetimes to alter 
the value to utc. The initially supplied timezone must be supplied again
upon conversion back to string to make a rountrip of the same value possible.
ie, we store utc time values on the server, the client must supply a timezone
during inserts and queries, the latter needed so that values displayed are in
the client's local time. Without ever supplying a tz, we only insert and see utc.*)
module Date_time_extended = struct
  include Core.Time
  (*                                                0123456789ABCDEFGHIJKLM*)
  (*MUST support alernate format with this example: 20190304000000 [-5:EST] *)
  let of_string ?(zoneoffset=0) s =
    try
      (*a query of an sql datetime does not show the time zone even if one was 
        supplied during insert and column type includes timezone. The server tz
        becomes relevant if a time zone is supplied during inserts. of_localized_string 
        must be supplied with a space between date and time portion, not a T in between 
        those parts and without a trailing tz*)
      match (Core.String.contains s 'T') with
      | true -> let s2 = Core.String.tr ~target:'T' ~replacement:' ' s in
                of_localized_string ~zone:(Zone.of_utc_offset ~hours:zoneoffset) s2
      | false -> of_localized_string ~zone:(Zone.of_utc_offset ~hours:zoneoffset) s
    with _ ->
      (*pure sql query results should never end up in here since they lack tz info*)
      of_string_with_utc_offset s

  let show ?(zoneoffset=0) t = to_string_abs ~zone:(Core.Time.Zone.of_utc_offset ~hours:(zoneoffset)) t;;
  let to_string ?(zoneoffset=0) t = show ~zoneoffset t;;

  let to_yojson t =
    let s = show t in 
    let s = Core.String.concat ["{dt:";s;"}"] in 
    Yojson.Safe.from_string s;;

  let of_yojson j =
    try
      let s = Yojson.Safe.to_string j in
      let splits = String.split_on_char ':' s in
      let value_half = List.nth splits 1 in
      let rbracket_i = String.index value_half '}' in 
      let value = String.sub value_half 0 rbracket_i in
      let t = of_string value in
      Ok t
    with _err -> Error "date_time_extended::of_yojson() failed.";;
   
  let equal t1 t2 = not (is_earlier t1 ~than:t2) && not (is_earlier t2 ~than:t1)
  let compare t1 t2 = if is_earlier t1 ~than:t2 then 1
		      else if is_earlier t2 ~than:t1 then -1
		      else 0
end
