module Cakefile where

import Development.Cake3
import Development.Cake3.Ext.UrWeb
import Cakefile_P

instance IsString File where fromString = file

project = do

  let dbn = "Pastebin"

  a <- uwapp "-dbms postgres" "Pastebin.urp" $ do
    ur (sys "option")
    ur (pair "Cb.ur")
    -- ur (pair "Job3.ur")
    ur (pair "Pastebin.ur")
    safeGet "Pastebin.ur" "main"
    safeGet "Pastebin.ur" "monitor"
    safeGet "Pastebin.ur" "pview"
    safeGet "Pastebin.ur" "gview"
    safeGet "Pastebin.ur" "gnew"
    safeGet "Pastebin.ur" "pnew"
    safeGet "Job.ur" "callback"
    safeGet "Pastebin.ur" "J/callback"
    allow mime "text/javascript"
    allow mime "text/css"
    database ("dbname="++dbn)
    sql "Pastebin.sql"
    library' (externalMake "../urweb-callback/lib.urp")
    library' (externalMake "../urweb-monad-pack/lib.urp")
    library' (externalMake "../uru2/lib.urp")
    debug

  db2 <- rule $ do
    phony "db"
    shell [cmd|dropdb --if-exists $(string dbn)|]
    shell [cmd|createdb $(string dbn)|]
    shell [cmd|psql -f $(urpSql (toUrp a)) $(string dbn)|]

  rule $ do
    phony "clean"
    unsafeShell [cmd|rm -rf .cake3 $(tempfiles a)|]

  rule $ do
    phony "all"
    depend a

main = do
  writeMake (file "Makefile") (project)
  writeMake (file "Makefile.devel") (selfUpdate >> project)

