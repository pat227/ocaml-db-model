(*Does SQL allow us to insert using a float value?
  New module for date type, represented as days since epoch? 
    As intervals of 24 hours starting from epoch + 1 second?
  New module for time type, as seconds?

READ sql standard...literals.
*)
module Date_time_extended = struct
  include Core.Time

  let show t = to_string_abs ~zone:(Core.Time.Zone.of_utc_offset ~hours:(-5)) t;;

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
    with err -> Error "date_time_extended::of_yojson() failed.";;
   
  let equal t1 t2 = not (is_earlier t1 ~than:t2) && not (is_earlier t2 ~than:t1)
  let compare t1 t2 = if is_earlier t1 ~than:t2 then 1
		      else if is_earlier t2 ~than:t1 then -1
		      else 0

  let to_xml v =
    [Csvfields.Xml.parse_string
       (Core.String.concat ["<date_time>";(to_string v);"</date_time>"])]
      
  let of_xml xml =
    let sopt = Csvfields.Xml.contents xml in
    match sopt with
    | None -> raise (Failure "date_extended::of_xml() passed None as input")
    | Some s -> of_string s

  let xsd_format =
    let open Csvfields.Xml.Restriction.Format in
    `string
  let xsd_restrictions = []
  let xsd = []
end
