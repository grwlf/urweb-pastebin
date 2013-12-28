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

end =

struct

  type jobref = Callback.jobref

  table jobs : $jobrec
    PRIMARY KEY JobRef

  table handles : {JobRef : int, Payload : S.t}

  fun callback (jr:jobref) : transaction page =
    j <- Callback.deref jr;
    ec <- (return (Callback.exitcode j));
    so <- (return (Callback.stdout j));
    dml(UPDATE jobs SET ExitCode = {[Some ec]}, Stdout = {[so]} WHERE JobRef = {[jr]});
    ji <- oneRow (SELECT * FROM jobs WHERE jobs.JobRef = {[jr]});
    query1 (SELECT * FROM handles WHERE handles.JobRef = {[jr]}) (fn r s =>
      S.f r.Payload ji.Jobs;
      return s) {};
    dml (DELETE FROM handles WHERE JobRef = {[jr]});
    Callback.cleanup j;
    return <xml/>

  fun create (cmd:string) (inp:string) : transaction jobref =
    j <- Callback.create cmd inp 1024;
    jr <- (return (Callback.ref j));
    dml(INSERT INTO jobs(JobRef,ExitCode,Cmd,Stdin,Stdout) VALUES ({[jr]}, {[None]}, {[cmd]}, {[inp]}, ""));
    Callback.run j (url (callback jr));
    return jr

  fun monitor (jr:jobref) (c:S.t) : transaction unit =
    r <- oneRow (SELECT * FROM jobs WHERE jobs.JobRef = {[jr]});
    case r.Jobs.ExitCode of
        None => dml (INSERT INTO handles(JobRef,Payload) VALUES ({[jr]}, {[c]}))
      | Some (ec:int) => S.f c r.Jobs;
    return {}
    
end

