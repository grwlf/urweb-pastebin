
type jobst = {ExitCode : int, Stdout : string}

type jobref = Callback.jobref

val create : string -> string -> transaction jobref

val monitor : jobref -> channel jobst -> transaction unit
