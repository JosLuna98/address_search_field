echo ********* Generating Documentation *********
dartdoc
echo ********* Activating dhttpd *********
pub global activate dhttpd
echo ********* Starting Server *********
echo http://localhost:8080/
dhttpd --path doc/api
