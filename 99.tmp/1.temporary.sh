#!/bin/bash

# 此处需要注释掉，因为用例有可能执行失败，若打开则会导致脚本退出。
# set -x
# set -o errexit
# set -o nounset
# set -o pipefail

main() {
    ((sshpass -p 'aGJXK1I4yxhiV6Y6VvcE' ssh -o StrictHostKeyChecking=no root@109.123.92.89 "source /etc/profile && dlogutil -v threadtime" ) > doutput.log 2>&1)&

    last_pi=$!

    echo ${last_pi}

    (sshpass -p 'aGJXK1I4yxhiV6Y6VvcE' ssh -o StrictHostKeyChecking=no root@109.123.92.89 "source /etc/profile && plusplayer_ut --gtest_filter=PersistentplayerOtaFixture.DISABLED_Persistentplayer_simple_playtest --gtest_also_run_disabled_tests") > output.log 2>&1
    sleep 2

    kill -15 ${last_pi}

    sshpass -p 'aGJXK1I4yxhiV6Y6VvcE' ssh -o StrictHostKeyChecking=no root@109.123.92.89 "source /etc/profile && pkill -9 dlogutil"

    sshpass -p 'aGJXK1I4yxhiV6Y6VvcE' scp 1.temporary.sh root@109.123.92.89:/root
}

main "$@"