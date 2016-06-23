#!/bin/bash
. asserts.sh

bre_client="/afc/bre-client-test/bin/bre_client_test"
bre_server="/afc/bre-server-app/bin/bre_server_app -n9000"
bre_server_rs485="/afc/bre-server-app/bin/bre_server_app -n9000 -a1 -r/dev/ttymxc4"

test_start "VersionTest"
# ensure server processes won't conflict
ssh_start $SERVER "killall bre_server_app; $bre_server"

cmd="$bre_client -n10.240.106.104 -Vs"
assert_contains "ssh_sync $CLIENT '$cmd'" "Got Server Information" #successfully get server info

# kill server and attempt to get server info
ssh_sync $SERVER "killall bre_server_app"
assert_contains "ssh_sync $CLIENT '$cmd'" "Command failed : \"-Vs\""
test_finish

########################################

test_start "ReadTests"

ssh_start $SERVER "killall bre_server_app; $bre_server"

cmd="$bre_client -n10.240.106.104 -d01020304050607 -v01020304050607 -R"
assert_contains "ssh_sync $CLIENT '${cmd}5'" "Got Server Information" #5 reads
assert_contains "ssh_sync $CLIENT '${cmd}10'" "Got Server Information" #10 reads
assert_contains "ssh_sync $CLIENT '${cmd}100'" "Got Server Information" #100 reads

echo "kill server and check read tests fail"
ssh_sync $SERVER "killall bre_server_app"
assert_contains "ssh_sync $CLIENT '$cmd'" "Command failed"
test_finish

########################################

test_start "ReadTests_RS485"

ssh_start $SERVER "killall bre_server_app; $bre_server_rs485"

cmd="$bre_client -a1 -r/dev/ttymxc4 -d01020304050607 -v01020304050607 -R"
assert_contains "ssh_sync $CLIENT_VIPER '${cmd}5'" "Got Server Information" #5 reads
assert_contains "ssh_sync $CLIENT_VIPER '${cmd}10'" "Got Server Information" #10 reads
assert_contains "ssh_sync $CLIENT_VIPER '${cmd}100'" "Got Server Information" #100 reads

echo "kill server and check read tests fail"
ssh_sync $SERVER "killall bre_server_app"
assert_contains "ssh_sync $CLIENT_VIPER '$cmd'" "Command failed"
test_finish

########################################
