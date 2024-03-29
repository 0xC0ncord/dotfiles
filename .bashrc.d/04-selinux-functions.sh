#!/usr/bin/env bash

# sefindif - Find interface definitions that have a string that matches the
# given regular expression
function sefindif {
    REGEXP="$1";
    if [ -d ${POLICY_LOCATION}/policy/modules ];
    then
        pushd ${POLICY_LOCATION}/policy/modules > /dev/null 2>&1;
    elif [ -d ${POLICY_LOCATION}/include ];
    then
        pushd ${POLICY_LOCATION}/include > /dev/null 2>&1;
    else
        echo "Variable POLICY_LOCATION is not properly defined.";
        return 1;
    fi
    for FILE in */*.if;
    do
        awk "BEGIN { P=1 } /(interface\(|template\()/ { NAME=\$0; P=0 }; /${REGEXP}/ { if (P==0) {P=1; print NAME}; if (NAME!=\$0) print };" ${FILE} | sed -e "s:^:${FILE}\: :g";
    done
    popd > /dev/null 2>&1;
}

# seshowif - Show the interface definition
function seshowif {
    INTERFACE="$1";
    if [ -d ${POLICY_LOCATION}/policy/modules ];
    then
        pushd ${POLICY_LOCATION}/policy/modules > /dev/null 2>&1;
    elif [ -d ${POLICY_LOCATION}/include ];
    then
        pushd ${POLICY_LOCATION}/include > /dev/null 2>&1;
    else
        echo "Variable POLICY_LOCATION is not properly defined.";
        return 1;
    fi
    for FILE in */*.if;
    do
        grep -A 9999 "\(interface(\`${INTERFACE}'\|template(\`${INTERFACE}'\)" ${FILE} | grep -B 9999 -m 1 "^')";
    done
    popd > /dev/null 2>&1;
}

# sefinddef - Find macro definitions that have a string that matches the given
# regular expression
function sefinddef {
    REGEXP="$1";
    if [ -d ${POLICY_LOCATION}/policy/support ];
    then
        pushd ${POLICY_LOCATION}/policy/support > /dev/null 2>&1;
    elif [ -d ${POLICY_LOCATION}/include/support ];
    then
        pushd ${POLICY_LOCATION}/include/support > /dev/null 2>&1;
    else
        echo "Variable POLICY_LOCATION is not properly defined.";
        return 1;
    fi
    for FILE in *;
    do
        awk "BEGIN { P=1; } /(define\(\`[^\`]*\`$)/ { NAME=\$0; P=0 }; /${REGEXP}/ { if (P==0) {P=1; print NAME}; if (NAME!=\$0) print };" ${FILE};
    done
    popd > /dev/null 2>&1;
}

# seshowdef - Show the macro definition
seshowdef() {
    MACRONAME="$1";
    if [ -d ${POLICY_LOCATION}/policy/support ];
    then
        pushd ${POLICY_LOCATION}/policy/support > /dev/null 2>&1;
    elif [ -d ${POLICY_LOCATION}/include/support ];
    then
        pushd ${POLICY_LOCATION}/include/support > /dev/null 2>&1;
    else
        echo "Variable POLICY_LOCATION is not properly defined.";
        return 1;
    fi
    for FILE in *.spt;
    do
        grep -A 9999 "define(\`${MACRONAME}'" ${FILE} | grep -B 999 -m 1 "')";
    done
    popd > /dev/null 2>&1;
}
