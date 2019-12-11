
(**
   should load modules in repl.

   #require "base"
   #require "unix"
*)

(* ocamlfind ocamlopt -linkpkg -package base,unix controller.ml *)

(* actions for custom resource definition *)
let check_crd ~name =
  print_endline (Printf.sprintf "check_crd %s" name);
  let command_str = Printf.sprintf "kubectl get crd %s" name in
  Sys.command command_str

let create_crd ~file =
  print_endline (Printf.sprintf "create_crd %s" file);
  let command_str = Printf.sprintf "kubectl apply -f %s" file in
  Sys.command command_str

(* actions for service *)
let check_service ~name = 
  print_endline (Printf.sprintf "check_service %s" name);
  let command_str = Printf.sprintf "kubectl get service %s" name in
  Sys.command command_str

let create_service ~file = 
  print_endline (Printf.sprintf "create_service %s" file);
  let command_str = Printf.sprintf "kubectl apply -f %s" file in
  Sys.command command_str

(* actions for deployment *)
let check_deployment ~name = 
  print_endline (Printf.sprintf "check_deployment %s" name);
  let command_str = Printf.sprintf "kubectl get deployment %s" name in
  Sys.command command_str

let create_deployment ~file = 
  print_endline (Printf.sprintf "create_deployment %s" file);
  let command_str = Printf.sprintf "kubectl create -f %s" file in
  let return_code = Sys.command command_str in
  if return_code = 0 then
    Sys.command (Printf.sprintf "rm -f %s" file)
  else return_code

let operator_action () =
  print_endline "### execute operator action...OK ####"

(* actions for pod *)
(* https://www.rosettacode.org/wiki/Execute_a_system_command *)
let pod_status_is_ready ~name =
  let command_str = Printf.sprintf "kubectl get pod %s -o jsonpath='{.status.conditions[?(@.type==\"Ready\")].status}'" name
  in
  let stdout_str = 
    let ic, _ = Unix.open_process command_str in
    input_line ic
  in
  match stdout_str with
  | "True" -> true
  | _ -> false

let ensure_service ~service_name ~deployment_name ~deployment_yaml ~pod_name =
  let service_result =
    match check_service service_name with
    | 0 -> operator_action()
    | _ -> (create_service "service.yaml"; ())
  in
  match check_deployment deployment_name with
  | 0 -> operator_action()
  | _ -> (create_deployment ~file:deployment_yaml;operator_action())

let loop () =  
  let crd_name = Sys.argv.(1) in 
  let crd_yaml = Sys.argv.(2) in
  let service_name = Sys.argv.(3) in
  let deployment_name = Sys.argv.(4) in
  let deployment_yaml = Sys.argv.(5) in
  let pod_name = Sys.argv.(6) in
  let rec _loop crd_name service_name deployment_name deployment_yaml pod_name = 
    print_endline "";
    Unix.sleep 1;
    if check_crd crd_name != 0 then
      _loop crd_name service_name deployment_name deployment_yaml pod_name
    ;
    let r = create_crd crd_yaml in
    if r = 0 then (
      ensure_service service_name deployment_name deployment_yaml pod_name;
      _loop crd_name service_name deployment_name deployment_yaml pod_name
    )
    else
    _loop crd_name service_name deployment_name deployment_yaml pod_name
    ;
    Unix.sleep 5;
    print_endline "";
  in _loop crd_name service_name deployment_name deployment_yaml pod_name

let () = loop()
    
 

