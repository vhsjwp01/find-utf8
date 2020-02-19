#!/bin/bash
#set -x

PATH=/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin
TERM=vt100
export TERM PATH

SUCCESS=0
ERROR=1

exit_code=${SUCCESS}

my_basename=`which basename 2> /dev/null` &&
my_diff=`which diff 2> /dev/null` &&
my_egrep=`which egrep 2> /dev/null` &&
my_file=`which file 2> /dev/null` &&
my_mkdir=`which mkdir 2> /dev/null` &&
my_rm=`which rm 2> /dev/null` &&
my_strings=`which strings 2> /dev/null`
exit_code=${?}

if [ ${exit_code} -eq ${SUCCESS} ]; then

    # Make sure we have an argument, and that the argument is a readable file
    if [ "${1}" != "" -a -e "${1}" ]; then
        let ascii_check=`${my_file} "${1}" | ${my_egrep} -ci "text"`

        if [ ${ascii_check} -gt 0 ]; then
            temp_dir="/tmp/$$"
            temp_file=`${my_basename} "${1}"`
            temp_file="${temp_file}.ascii"
            ${my_mkdir} -p "${temp_dir}" &&
            ${my_strings} "${1}" > "${temp_dir}/${temp_file}" &&
            ${my_diff} --unchanged-line-format="" --new-line-format="" --old-line-format="Line %dn: %L" "${1}" "${temp_dir}/${temp_file}"
            ${my_rm} -rf "${temp_dir}"
        else
            echo "    ERROR:  Target file is not text ... exiting"
            exit_code=${ERROR}
        fi

    else
        echo "    ERROR:  Could not locate input file \"${1}\""
        exit_code=${ERROR}
    fi

fi

exit ${exit_code}
