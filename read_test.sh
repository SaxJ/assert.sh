#!/bin/bash
. asserts.sh

bre_client="/afc/bre-client-test/bin/bre_client_test"
bre_client_vix="/afc/bre-client-test-vix/bin/bre_client_test_vix"
bre_server="/afc/bre-server-app/bin/bre_server_app -n9000"
bre_server_rs485="/afc/bre-server-app/bin/bre_server_app -n9000 -a1 -r/dev/ttymxc4"

test_start "VersionTest"
# ensure server processes won't conflict
ssh_start $SERVER "killall bre_server_app; $bre_server"

cmd="$bre_client -n10.240.106.104 -Vs"
echo "$cmd"
assert_contains "ssh_sync $CLIENT '$cmd'" "Got Server Information" #successfully get server info

# kill server and attempt to get server info
ssh_sync $SERVER "killall bre_server_app"
assert_contains "ssh_sync $CLIENT '$cmd'" "Command failed : \"-Vs\""
test_finish

########################################

test_start "ReadTests"

ssh_start $SERVER "killall bre_server_app; $bre_server"

cmd="$bre_client -n10.240.106.104 -d01020304050607 -v01020304050607 -R"
echo "$cmd"
assert_contains "ssh_sync $CLIENT '${cmd}5'" "Read test passed" #5 reads
assert_contains "ssh_sync $CLIENT '${cmd}10'" "Read test passed" #10 reads
assert_contains "ssh_sync $CLIENT '${cmd}100'" "Read test passed" #100 reads

echo "kill server and check read tests fail"
ssh_sync $SERVER "killall bre_server_app"
assert_contains "ssh_sync $CLIENT '$cmd'" "Command failed"
test_finish

########################################

test_start "ReadTests_RS485"

ssh_start $SERVER "killall bre_server_app; $bre_server_rs485"

cmd="$bre_client -a1 -r/dev/ttymxc4 -d01020304050607 -v01020304050607 -R"
echo "$cmd"
assert_contains "ssh_sync $CLIENT_VIPER '${cmd}5'" "Read test passed" #5 reads
assert_contains "ssh_sync $CLIENT_VIPER '${cmd}10'" "Read test passed" #10 reads
assert_contains "ssh_sync $CLIENT_VIPER '${cmd}100'" "Read test passed" #100 reads

echo "kill server and check read tests fail"
ssh_sync $SERVER "killall bre_server_app"
assert_contains "ssh_sync $CLIENT_VIPER '$cmd'" "Command failed"
test_finish

########################################

test_start "List_Atr"

ssh_start $SERVER "killall bre_server_app; $bre_server" #start bre-server-app for next tests
sleep 5

cmd="$bre_client -n10.240.106.104 -L"
echo "$cmd"
assert_contains "ssh_sync $CLIENT '${cmd}'" "HCM Session Information" # List SAMs

test_finish

########################################

test_start "CardDetect"


cmd="$bre_client -n10.240.106.104 -p -cd"
echo "$cmd"
assert_contains "ssh_sync $CLIENT '${cmd}'" "ATP = 01 0D 21 02 44 00 00 07 04 C7 07 D2 A0 3C 84"

cmd="$bre_client -S -n10.240.106.104 -d01020304050607 -v01020304050607 -cd"
echo "$cmd"
assert_contains "ssh_sync $CLIENT '${cmd}'" "ATP = 01 0D 41 02 44 00 00 07 01 02 03 04 05 06 07 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"

test_finish

########################################

test_start "Initialisation"


cmd="$bre_client -S -n10.240.106.104 -v01020304050607 -d01020304050607 -d01020304050607"
echo "$cmd"
assert_contains "ssh_sync $CLIENT '${cmd}'" "result indicated failure"

cmd="$bre_client -S -n10.240.106.104 -d01020304050607 -v01020304050607 -I"
echo "$cmd"
assert_contains "ssh_sync $CLIENT '${cmd}'" "Card initialised ok"

test_finish

########################################

test_start "Purse_Txn_Network"


cmd="$bre_client_vix -n10.240.106.104 -U5"
echo "$cmd"
assert_contains "ssh_sync $CLIENT '${cmd}'" "TXN_TEST_PURSE_USAGE"

test_finish

########################################

test_start "Server_Logs_Disabled"


cmd="$bre_client -n10.240.106.104 -lg2 -ll1 -cd"
echo "$cmd"
assert_not_contains "ssh_sync $CLIENT '${cmd}'" "[SERVER]"

test_finish

########################################

test_start "Server_Logs_Enabled"


cmd="$bre_client -n10.240.106.104 -lg1 -ll2 -cd"
echo "$cmd"
assert_contains "ssh_sync $CLIENT '${cmd}'" "[SERVER]"

test_finish
