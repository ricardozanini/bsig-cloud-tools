#!/usr/bin/env bash

log() {
    local msg="${1}"
    local color="${2}"
    if [ -n "${color}" ] && [ "${NO_COLOR}" != "enabled" ]; then
        echo 1>&2 -e "\033[0;${color}m${msg}\033[0m"
    else
        echo 1>&2 -e "${msg}"
    fi
}

log_help() {
    # color: none
    log "${1}"
}

log_debug() {
    # color: blue
    log "[DEBUG] ${1}" "34"
}

log_info() {
    # color: green
    log " [INFO] ${1}" "32"
}

log_warn() {
    # color: yellow
    log " [WARN] ${1}" "33"
}

log_error() {
    # color: red
    log "[ERROR] ${1}" "31"
}

# Rebase every repo with upstream master
# {1} base dir where all kiecloud repos are
function sync_all_repos() {
  log_info "Trying to sync all Kiecloud projects"
  local validRepos=(cct_module jboss-eap-modules jboss-kie-modules kie-cloud-operator rhdm-7-image rhdm-7-openshift-image rhpam-7-image rhpam-7-openshift-image rhpam-apb)
  local baseRepo=${1}
  if [ -z "${baseRepo}" ]; then
    baseRepo="${KIECLOUD_HOME}"
  fi
  for repo in "${validRepos[@]}"; do
    if [ -d "${baseRepo}/${repo}"  ]; then
      log_info "Rebasing ${repo}" 
      cd "${baseRepo}/${repo}"
      git checkout master
      git pull --rebase upstream master
    else
      log_warn "Can't find ${repo} repository in your filesystem, skipping."
    fi
  done
}

function main() {
  log_info "Welcome to Kiecloud Git Utils"
  local args
  IFS=' ' read -r -a args <<< "$(echo ${@})"
  local baseDir
  local sync=false
  local OPTIND opt
  while getopts "sd:" opt ${args[@]}; do
    case "${opt}" in
       s)  sync=true       ;;
       d)  baseDir=$OPTARG ;;
      \?) log_error "Invalid arg: ${OPTARG}" ;;
    esac
  done
  if [ "${sync}" = true  ]; then
    sync_all_repos ${baseDir}
  fi
}

main $@
