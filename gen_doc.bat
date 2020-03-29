@echo off
echo ********* Generating Documentation *********
call dartdoc
echo ********* Activating dhttpd *********
call pub global activate dhttpd
echo ********* Starting Server *********
echo http://localhost:8080/
call dhttpd --path doc/api
