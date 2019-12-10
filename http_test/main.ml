(*
   #require "lwt"
   #require "lwt.unix"
   #require "cohttp-lwt-unix"
*)

(**
   Lwt's operator 
   - >>=
   - https://stackoverflow.com/questions/34381608/ocaml-lwt-utop-infix-bind-operator-is-missing
*)


(**
   build:
   ocamlfind ocamlopt -linkpkg -package cohttp-lwt-unix main.ml
*)

let body = 
  let (>>=) = Lwt.(>>=) in
  let (>|=) = Lwt.(>|=) in
  Cohttp_lwt_unix.Client.get (Uri.of_string "http://localhost:8080/api") >>=
    fun (resp, body) ->
      let code = 
        resp
        |> Cohttp.Response.status
        |> Cohttp.Code.code_of_status 
      in
      Printf.printf "Response code: %d\n" code;
      
      let resp_str =
        resp
        |> Cohttp.Response.headers
        |> Cohttp.Header.to_string 
      in
      Printf.printf "Headers: %s\n" resp_str;

      body |> Cohttp_lwt.Body.to_string >|= fun body ->
      Printf.printf "Body of length: %d\n" (String.length body);
      body

let () =
  let body = Lwt_main.run body in
  print_endline ("Received body\n" ^ body)
