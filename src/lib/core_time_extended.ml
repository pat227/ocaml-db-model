open Core
(*Need to support yojson if client project wants it*)
module Core_time_extended = struct
  include Core.Time
  type t = Core.Time.t
  let to_parts t =
    let s = Time.to_filename_string t ~zone:(Zone.of_utc_offset ~hours:0) in
    let halves = String.split ~on:'_' s in
    let former = String.split ~on:'-' (List.nth_exn halves 0) in
    let y = Int.of_string (List.nth_exn former 0) in
    let mon = Int.of_string (List.nth_exn former 1) in
    let d = Int.of_string (List.nth_exn former 2) in
    let latter = String.split ~on:'-' (List.nth_exn halves 1) in
    let h = Int.of_string (List.nth_exn latter 0) in
    let m = Int.of_string (List.nth_exn latter 1) in
    let s = Float.to_int (Float.of_string (List.nth_exn latter 2)) in
    [|y ; mon ; d ; h ; m ; s|];;

  (*NEED TO TEST*)
  let to_yojson t =
    let s = Core.Time.to_string t in
    let s2 = Core.String.concat ["{ts:";s;"}"] in
    Yojson.Safe.from_string s2;;
    
  let of_yojson j =
    let s = Yojson.Safe.to_string j in
    let splits = Core.String.split s ':' in
    let value_half = List.nth_exn splits 1 in
    let rbracket_i = Core.String.index_exn value_half '}' in 
    let value = Core.String.slice value_half 0 rbracket_i in 
    Core.Time.of_string value;;
end 
