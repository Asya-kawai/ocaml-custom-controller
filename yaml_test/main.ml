(* Yaml の使い方を見る *)

(* replで利用する際には、
   #require "yaml" ;;
   #require "yaml.unix" ;;
   をやっておく
*)

let read_file ~file = 
  let f = Fpath.v file in
  let r = Yaml_unix.of_file_exn f in
  let contents = match r with
  | `O x -> x
  | _ -> [("", `Null)]
  in contents
