#!/bin/bash
# INSTALL DEPENDANCIES
if ! type sshpass > /dev/null; then
    sudo apt-get install -y sshpass
fi

export SERVER="root@10.240.106.104"
export CLIENT="root@10.240.106.101"
export SSHPASS="!Vix!71639kuyhn"
export CURRENT_TEST=""
SECONDS=0


tc_start()
{
    SECONDS=0
    echo "##teamcity[testStarted name='$CURRENT_TEST']"
}

tc_fail()
{
    echo "##teamcity[testFailed name='$CURRENT_TEST' message='$1' details='$2']"
}

tc_finish()
{
    duration=$SECONDS
    echo "##teamcity[testFinished name='$CURRENT_TEST' duration='$duration']"
}

test()
{
    CURRENT_TEST="$1"
    tc_start
}

ssh_sync()
{
    sshpass -e ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $1 $2
}

ssh_start()
{
    sshpass -e ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -n -f $1 "sh -c 'nohup $2 > /dev/null 2>&1 &'"
}

ssh_file()
{
    sshpass -e ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $1 "bash -s" -- < $2 $3
}

assert_contains()
{
    result="$(eval $1)"
    if [[ "$result" == *"$2"* ]]
    then
        echo "Passed"
    else
        echo "Failed"
        tc_fail "Assertion failed" "$result"
    fi
}
