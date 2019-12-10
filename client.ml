module type Pod = sig
  type t
  val get : ?name:string -> t
end


(*

https://kubernetes.io/docs/tasks/administer-cluster/access-cluster-api/#python-client
*)

