@echo off
echo ********* Generating Documentation *********
call dartdoc
echo ********* Activating dhttpd *********
call pub global activate dhttpd
echo ********* Starting Server *********
call dhttpd --path doc/api