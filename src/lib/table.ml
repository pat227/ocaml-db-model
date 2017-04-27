module Table = struct
  type t = {
    table_name : string;
    table_type: string;
    engine : string;
  } [@@ppx_deriving fields]
end
