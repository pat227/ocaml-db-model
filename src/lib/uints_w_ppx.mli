module Uints_w_sexp : sig
  include Uint64
  val sexp_of_t : t -> Sexp.Atom Sexp.List
  val t_of_sexp : Sexp.Atom -> t
  val compare : t1 -> t2 -> int
end 
