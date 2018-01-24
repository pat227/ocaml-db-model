(*Could create types for each field, but perhaps that's going overboard.*)
module Credentials = struct
  type t = {
    username: string;
    pw:string;
    db:string;
  }
  let of_username_pw ~username ~pw ~db =
    { username = username;
      pw = pw;
      db = db;
    };;

  let getuname t = t.username;;
  let getpw t = t.pw;;
  let getdb t = t.db;;

end
