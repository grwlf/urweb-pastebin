
con jobrec = [JobRef = int, ExitCode = option int, Cmd = string, Stdin = string, Stdout = string]

functor Make(S :
sig
  type t
  type r
  val fl : t -> record jobrec -> transaction r
  val fr : t -> record jobrec -> transaction r

  val proof1 :  sql_injectable t
end) :

sig

  type jobref = Callback.jobref

  val create : string -> string -> transaction jobref

  val monitor : jobref -> S.t -> transaction (option S.r)

end
