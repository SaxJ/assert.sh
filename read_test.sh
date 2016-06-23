#!/bin/bash
. asserts.sh

run_client_read_test()
{
    echo "/afc/bre-client-test/bin/bre_client_test -n10.240.106.104 -v01020304050607 -R$1"
}
bre_client="/afc/bre-client-test/bin/bre_client_test"
bre_server="/afc/bre-server-app/bin/bre_server_app -n9000"

test "VersionTest"
# ensure server processes won't conflict
ssh_start $SERVER "killall bre_server_app; $bre_server"

cmd="$bre_client -n10.240.106.104 -Vs"
assert_contains "ssh_sync $CLIENT '$cmd'" "Got Server Information" #successfully get server info

# kill server and attempt to get server info
ssh_sync $SERVER "killall bre_server_app"
assert_contains "ssh_sync $CLIENT '$cmd'" "Command failed : \"-Vs\""
tc_finish

