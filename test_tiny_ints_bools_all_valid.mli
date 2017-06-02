module Test_tiny_ints_bools_all_valid : sig 
type t = {
  id:Uint64.t;
  i:Uint8.t;
  is_ii:Uint8.t;
  iii:Uint8.t;
  is_iv:Uint8.t;
  vi:bool;
  is_vii:bool;
}
[@@deriving fields,show]
end