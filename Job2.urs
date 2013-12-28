
con jobrec = [JobRef = int, ExitCode = option int, Cmd = string, Stdin = string, Stdout = string]

functor Make(S :
sig
  type t
  val f : t -> record jobrec -> transaction unit

  val proof1 :  sql_injectable t
end) :

sig

  type jobref = Callback.jobref

  val create : string -> string -> transaction jobref

  val monitor : jobref -> S.t -> transaction unit

end
