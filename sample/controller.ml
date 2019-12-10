
(* should input ```#require "base"``` in repl. *)

(* actions for custom resource definition *)
let check_crd ~name =
  let command_str = Printf.sprintf "kubectl get crd %s" name in
  Sys.command command_str

let create_crd ~file =
  let command_str = Printf.sprintf "kubectl apply -f %s" file in
  Sys.command command_str

(* actions for service *)
let check_service ~name = 
  let command_str = Printf.sprintf "kubectl get srevice %s" name in
  Sys.command command_str

let create_service ~file = 
  let command_str = Printf.sprintf "kubectl apply -f %s" file in
  Sys.command command_str

(* actions for deployment *)
let check_deployment ~name = 
  let command_str = Printf.sprintf "kubectl get deployment %s" name in
  Sys.command command_str

let create_deployment ~file = 
  let command_str = Printf.sprintf "kubectl create -f %s" file in
  let return_code = Sys.command command_str in
  if return_code = 0 then
    Sys.command (Printf.sprintf "rm -f %s" file)
  else return_code

(* actions for pod *)
let check_pod_status_ready ~name =
  let command_str = Printf.sprintf "kubectl get pod %s -o jsonpath='{.status.conditions[?(@.type==\"Ready\")].status}'" name
  in
  Sys.command command_str
