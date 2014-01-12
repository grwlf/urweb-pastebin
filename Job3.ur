con jobrec = [JobRef = int, ExitCode = option int, Cmd = string, Stdin = string, Stdout = string]

functor Make(S :
sig
  type t
  val f : record jobrec -> transaction t
end) :

sig

  type jobref = Callback.jobref

  val create : string -> string -> transaction jobref

  val monitor : jobref -> S.t -> transaction (Cb.aval S.t)

end =

struct

  type jobref = Callback.jobref

  table jobs : $jobrec
    PRIMARY KEY JobRef

  table handles : {JobRef : int, Channel : channel S.t}

  sequence jobrefs

  fun callback (jr:jobref) : transaction page =
    j <- Callback.deref jr;
    ec <- (return (Callback.exitcode j));
    so <- (return (Callback.stdout j));
    dml(UPDATE jobs SET ExitCode = {[Some ec]}, Stdout = {[so]} WHERE JobRef = {[jr]});
    ji <- oneRow (SELECT * FROM jobs WHERE jobs.JobRef = {[jr]});
    query1 (SELECT * FROM handles WHERE handles.JobRef = {[jr]}) (fn r s =>
      t <- S.f ji.Jobs;
      send r.Channel t;
      return s) {};
    dml (DELETE FROM handles WHERE JobRef = {[jr]});
    Callback.cleanup j;
    return <xml/>

  fun create (cmd:string) (inp:string) : transaction jobref =
    jr <- nextval jobrefs;
    j <- Callback.create cmd inp 1024 jr;
    dml(INSERT INTO jobs(JobRef,ExitCode,Cmd,Stdin,Stdout) VALUES ({[jr]}, {[None]}, {[cmd]}, {[inp]}, ""));
    Callback.run j (url (callback jr));
    return jr

  fun monitor (jr:jobref) (d:S.t) =
    r <- oneRow (SELECT * FROM jobs WHERE jobs.JobRef = {[jr]});
    case r.Jobs.ExitCode of
        None =>
          c <- channel;
          s <- source d;
          dml (INSERT INTO handles(JobRef,Channel) VALUES ({[jr]}, {[c]}));
          return (Cb.Future (c,s))
      | Some (ec:int) =>
          t <- S.f r.Jobs;
          return (Cb.Ready t)

  fun monitor (jr:jobref) (d:S.t) =
    r <- oneOrNoRows (SELECT * FROM jobs WHERE jobs.JobRef = {[jr]});
    case r of
        None => return (Cb.Ready d)
      | Some r =>
          case r.Jobs.ExitCode of
              None =>
                c <- channel;
                s <- source d;
                dml (INSERT INTO handles(JobRef,Channel) VALUES ({[jr]}, {[c]}));
                return (Cb.Future (c,s))
            | Some (ec:int) =>
                t <- S.f r.Jobs;
                return (Cb.Ready t)
    
end

