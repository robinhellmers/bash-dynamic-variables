#####################
### Guard library ###
#####################
guard_source_max_once() {
    local file_name="$(basename "${BASH_SOURCE[0]}")"
    local guard_var="guard_${file_name%.*}" # file_name wo file extension

    [[ "${!guard_var}" ]] && return 1
    [[ "$guard_var" =~ ^[_a-zA-Z][_a-zA-Z0-9]*$ ]] \
        || { echo "Invalid guard: '$guard_var'"; exit 1; }
    declare -gr "$guard_var=true"
}

guard_source_max_once || return

##############################
### Library initialization ###
##############################
init_lib()
{
    # Unset as only called once and most likely overwritten when sourcing libs
    unset -f init_lib

    if ! [[ -d "$LIB_PATH" ]]
    then
        echo "LIB_PATH is not defined to a directory for the sourced script."
        echo "LIB_PATH: '$LIB_PATH'"
        exit 1
    fi

    ### Source libraries ###
    #
    # Always start with 'lib_core.bash'
    source "$LIB_PATH/lib_core.bash"
}

init_lib

#####################
### Library start ###
#####################

###
# List of functions for usage outside of lib
#
# - create_dynamic_array()
# - append_dynamic_array()
# - set_dynamic_array_element()
# - get_dynamic_array_element()
# - get_dynamic_array()
# - get_dynamic_array_len()
###

create_dynamic_array()
{
    local array_name="$1"
    shift
    declare -g -a "$array_name=(\"$@\")"
}

append_dynamic_array()
{
    local array_name="$1"
    local value="$2"
    # Get length of array
    eval eval "local len=\${#${array_name}[@]}"

    # Append to array
    read -r "${array_name}[${len}]" <<< "$value"
}

set_dynamic_array_element()
{
    local array_name="$1"
    local value="$2"
    local index="$3"

    # Append to array
    read -r "${array_name}[${index}]" <<< "$value"
}

get_dynamic_array_element()
{
    local array_name="$1"
    local index="$2"

    dynamic_array_element=$(eval "echo \"\${$array_name[$index]}\"")
    echo "$dynamic_array_element"
}

get_dynamic_array()
{
    local array_name="$1"

    dynamic_array=()
    dynamic_array_len="$(get_dynamic_array_len $array_name)"
    for (( i=0; i < dynamic_array_len; i++ ))
    do
        dynamic_array+=("$(get_dynamic_array_element $array_name $i)")
    done
}

get_dynamic_array_len()
{
    local array_name="$1"

    dynamic_array_len=$(eval "echo \${#$array_name[@]}")
    echo "$dynamic_array_len"
}
