# conf.d/functions.zsh — shell functions (kubectl helpers, AWS utils, git).

# ── Git ───────────────────────────────────────────────────────────────────────
# git add . && commit && push in one shot
# Usage: gacp "fix: my message"       regular push
#        gacp "fix: my message" -f    force push
gacp() {
    local force=0
    local msg=""
    for arg in "$@"; do
        [[ "$arg" == "-f" || "$arg" == "--force" ]] && force=1 || msg="$arg"
    done
    git add . && git commit -m "$msg" && { [[ $force -eq 1 ]] && git push -f || git push; }
}

# ── Headroom ──────────────────────────────────────────────────────────────────

# Launch Claude Code through the Headroom optimizing proxy. `headroom wrap`
# starts the proxy on demand, sets ANTHROPIC_BASE_URL, and launches claude;
# the corp CA env (SSL_CERT_FILE) from env.zsh lets the proxy verify upstream
# TLS behind Zscaler. Plain `claude` stays untouched/direct.
# Usage: claudep [claude args...]   e.g. claudep --resume <id>
claudep() {
    headroom wrap claude "$@"
}

# ── kubectl utility functions ────────────────────────────────────────────────

# Pick a kubeconfig from ~/Downloads using fzf and export KUBECONFIG
kuse() {
    local config
    config=$(ls ~/Downloads/ 2>/dev/null | grep -i kubeconfig | fzf --prompt="Select kubeconfig: ")
    if [[ -z "$config" ]]; then
        echo "No config selected"
    else
        export KUBECONFIG="$HOME/Downloads/$config"
        echo "KUBECONFIG set to $KUBECONFIG"
    fi
}

# Unset KUBECONFIG (revert to default ~/.kube/config)
kuoff() {
    unset KUBECONFIG
    echo "KUBECONFIG unset"
}

# ── AWS ───────────────────────────────────────────────────────────────────────

# Parse "export KEY="VALUE"" lines from clipboard (AWS console creds format)
# Copy creds from AWS console, then run: aws-paste
aws-paste() {
    local loaded=0
    while IFS= read -r line; do
        [[ "$line" == export\ * ]] || continue
        local kv="${line#export }"
        local key="${kv%%=*}"
        local val="${kv#*=}"
        val="${val#\"}"
        val="${val%\"}"
        export "$key=$val"
        (( loaded++ ))
    done < <(pbpaste)
    echo "Loaded $loaded AWS environment variables"
}

# Run a bash command string — useful for pasting multi-line bash with backslashes
# Usage: bshc 'aws eks describe-nodegroup \ --cluster-name foo \ --nodegroup-name bar'
bshc() { bash -c "$1"; }

# ── jq-based ports of the nushell equivalents ────────────────────────────────

# ── Pods sorted by restart count (kube-system) ────────────────────────────────
kpods_restarts_ks() {
  local data
  data=$(kubectl get pods -n kube-system -o json | jq -r '
    .items[] | [
      (.status.containerStatuses // [] | map(.restartCount) | add // 0),
      .metadata.name
    ] | @tsv
  ' | sort -k1 -rn)
  { echo $'RESTARTS\tNAME'; echo "$data"; } | column -t -s $'\t'
}

# ── All running pods with IPs (cluster-wide) ──────────────────────────────────
kpods_running_all() {
  kubectl get pods -A -o json | jq -r '
    ["NAMESPACE", "NAME", "POD_IP"],
    (.items[] | select(.status.phase == "Running") | [
      .metadata.namespace, .metadata.name, (.status.podIP // "")
    ] | @tsv)
  ' | column -t -s $'\t'
}

# ── Top 5 pods by memory request (cluster-wide) ───────────────────────────────
kpods_top_mem() {
  local data
  data=$(kubectl get pods -A -o json | jq -r '
    def to_mi(m):
      if m | test("Gi$") then (m | gsub("[^0-9.]";"") | tonumber * 1024)
      elif m | test("Mi$") then (m | gsub("[^0-9.]";"") | tonumber)
      elif m | test("Ki$") then (m | gsub("[^0-9.]";"") | tonumber / 1024)
      else 0 end;
    .items[] | [
      ([.spec.containers[].resources.requests.memory? // "0"] | map(to_mi(.)) | add // 0),
      .metadata.namespace,
      .metadata.name
    ] | @tsv
  ' | sort -k1 -rn | head -5 | awk -F'\t' '{printf "%s\t%s\t%.0fMi\n", $2, $3, $1}')
  { echo $'NAMESPACE\tNAME\tMEM_REQUEST'; echo "$data"; } | column -t -s $'\t'
}

# ── All LoadBalancer services with their IPs ──────────────────────────────────
ksvc_lbs_all() {
  kubectl get svc -A -o json | jq -r '
    ["NAMESPACE", "NAME", "IPS", "PORTS"],
    (.items[] | select(.spec.type == "LoadBalancer") | [
      .metadata.namespace,
      .metadata.name,
      (
        (.spec.externalIPs // [] | .[]) as $ext |
        (.status.loadBalancer.ingress // [] | .[] | (.ip // .hostname // "")) as $ing |
        [$ext, $ing] | map(select(. != "")) | join(",")
      ),
      (.spec.ports | map("\(.port)/\(.protocol)") | join(","))
    ] | @tsv)
  ' | column -t -s $'\t'
}

# ── Deployments where ready < desired ────────────────────────────────────────
kdeploys_unready_all() {
  kubectl get deploy -A -o json | jq -r '
    ["NAMESPACE", "NAME", "READY", "DESIRED"],
    (.items[] | select(
      (.status.readyReplicas // 0) < (.status.replicas // 0)
    ) | [
      .metadata.namespace,
      .metadata.name,
      (.status.readyReplicas // 0 | tostring),
      (.status.replicas // 0 | tostring)
    ] | @tsv)
  ' | column -t -s $'\t'
}

# ── Node CPU architecture ─────────────────────────────────────────────────────
knodes_arch() {
  kubectl get nodes -o json | jq -r '
    ["NAME", "ARCH"],
    (.items[] | [.metadata.name, .status.nodeInfo.architecture] | @tsv)
  ' | column -t -s $'\t'
}

# ── Nodes with unhealthy conditions ──────────────────────────────────────────
knodes_conditions() {
  kubectl get nodes -o json | jq -r '
    .items[] |
    (
      .status.conditions | map(select(
        (.status != "False" and .type != "Ready") or
        (.type == "Ready" and .status != "True")
      ))
    ) as $bad |
    select($bad | length > 0) |
    [.metadata.name, ($bad | map(.type) | join(","))] |
    @tsv
  ' | { echo $'NAME\tUNHEALTHY_CONDITIONS'; cat; } | column -t -s $'\t'
}

# ── Pods in Pending state ─────────────────────────────────────────────────────
kpods_pending() {
  kubectl get pods -A -o json | jq -r '
    ["NAMESPACE", "NAME", "REASON", "MESSAGE"],
    (.items[] | select(.status.phase == "Pending") |
      ((.status.conditions // []) | last? // {}) as $last |
      [
        .metadata.namespace,
        .metadata.name,
        ($last.reason // ""),
        ($last.message // "" | .[0:80])
      ] | @tsv)
  ' | column -t -s $'\t'
}

# ── Pods that were OOMKilled ──────────────────────────────────────────────────
kpods_oomkilled() {
  kubectl get pods -A -o json | jq -r '
    ["NAMESPACE", "NAME", "CONTAINER", "EXIT_CODE"],
    (.items[] |
      ((.status.containerStatuses // []) |
        map(select(.lastState.terminated?.reason? == "OOMKilled"))
      ) as $oom |
      select($oom | length > 0) |
      [
        .metadata.namespace, .metadata.name,
        $oom[0].name,
        ($oom[0].lastState.terminated.exitCode | tostring)
      ] | @tsv)
  ' | column -t -s $'\t'
}

# ── Pods with failed init containers ─────────────────────────────────────────
kpods_init_failed() {
  kubectl get pods -A -o json | jq -r '
    ["NAMESPACE", "NAME", "INIT_CONTAINER", "REASON"],
    (.items[] |
      ((.status.initContainerStatuses // []) |
        map(select(.state.waiting?.reason? |
          IN("Error", "CrashLoopBackOff", "OOMKilled")))
      ) as $bad |
      select($bad | length > 0) |
      [
        .metadata.namespace, .metadata.name,
        $bad[0].name,
        $bad[0].state.waiting.reason
      ] | @tsv)
  ' | column -t -s $'\t'
}

# ── Warning events cluster-wide, newest first ─────────────────────────────────
kevents_warnings() {
  kubectl get events -A -o json | jq -r '
    ["NAMESPACE", "OBJECT", "KIND", "REASON", "COUNT", "LAST_SEEN"],
    ([.items[] | select(.type == "Warning")] |
      sort_by(.lastTimestamp) | reverse | .[] | [
        .metadata.namespace,
        .involvedObject.name,
        .involvedObject.kind,
        .reason,
        (.count | tostring),
        .lastTimestamp
      ] | @tsv)
  ' | column -t -s $'\t'
}

# ── Events for a specific object ──────────────────────────────────────────────
# Usage: kevents_for <name> [-n namespace]
kevents_for() {
  local name="${1:?Usage: kevents_for <name> [-n namespace]}"
  local ns="default"
  [[ "${2:-}" == "-n" ]] && ns="${3:?-n requires a namespace}"
  kubectl get events -n "$ns" -o json | jq -r \
    --arg name "$name" '
    ["REASON", "MESSAGE", "COUNT", "TIME"],
    ([.items[] | select(.involvedObject.name == $name)] |
      sort_by(.lastTimestamp) | .[] | [
        .reason,
        (.message | .[0:80]),
        (.count | tostring),
        .lastTimestamp
      ] | @tsv)
  ' | column -t -s $'\t'
}

# ── Top 15 noisiest warning sources cluster-wide ───────────────────────────────
kevents_noisy() {
  kubectl get events -A -o json | jq -r '
    ["COUNT", "OBJECT"],
    ([.items[] | select(.type == "Warning")] |
      group_by(.involvedObject.name) |
      map({name: .[0].involvedObject.name, count: length}) |
      sort_by(.count) | reverse | .[0:15] | .[] |
      [(.count | tostring), .name] | @tsv)
  ' | column -t -s $'\t'
}

# ── Tail logs from pods matching a label ─────────────────────────────────────
# Usage: klogs_label <label-selector> [-n namespace]
klogs_label() {
  local label="${1:?Usage: klogs_label <label-selector> [-n namespace]}"
  local ns="default"
  [[ "${2:-}" == "-n" ]] && ns="${3:?-n requires a namespace}"
  kubectl get pods -n "$ns" -l "$label" -o jsonpath='{.items[*].metadata.name}' \
  | tr ' ' '\n' | while read -r pod; do
    echo "=== $pod ==="
    kubectl logs -n "$ns" "$pod" --tail=50
  done
}

# ── Logs from previously terminated containers ───────────────────────────────
# Usage: klogs_previous [-n namespace]
klogs_previous() {
  local ns="default"
  [[ "${1:-}" == "-n" ]] && ns="${2:?-n requires a namespace}"
  kubectl get pods -n "$ns" -o json | jq -r '
    .items[] |
    select(.status.containerStatuses // [] | any(.restartCount > 0)) |
    .metadata.name
  ' | while read -r pod; do
    echo "=== $pod - previous ==="
    kubectl logs -n "$ns" "$pod" --previous --tail=100
  done
}

# ── Secret keys (without revealing values) ───────────────────────────────────
# Usage: ksecret_keys <name> [-n namespace]
ksecret_keys() {
  local name="${1:?Usage: ksecret_keys <name> [-n namespace]}"
  local ns="default"
  [[ "${2:-}" == "-n" ]] && ns="${3:?-n requires a namespace}"
  kubectl get secret "$name" -n "$ns" -o json | jq -r '.data | keys[]'
}

# ── Delete all Evicted pods cluster-wide ─────────────────────────────────────
kclean_evicted() {
  kubectl get pods -A -o json | jq -r '
    .items[] | select(.status.reason? == "Evicted") |
    [.metadata.namespace, .metadata.name] | @tsv
  ' | while IFS=$'\t' read -r ns pod; do
    echo "Deleting $ns/$pod"
    kubectl delete pod -n "$ns" "$pod"
  done
}

# ── Remove a stuck namespace by clearing finalizers ───────────────────────────
kclean_stuck_ns() {
  local ns="${1:?Usage: kclean_stuck_ns <namespace>}"
  kubectl get namespace "$ns" -o json \
  | jq '.spec.finalizers = []' \
  | kubectl replace --raw "/api/v1/namespaces/$ns/finalize" -f -
}

# ── Node resource usage sorted by CPU% (requires metrics-server) ──────────────
ktopn() {
  kubectl top nodes | { read -r header; echo "$header"; sort -k3 -rn; }
}

# ── Pod resource usage sorted by memory, top 20 (requires metrics-server) ─────
ktopp() {
  kubectl top pods -A | (
    read -r header
    echo "$header"
    awk '
      {
        mem=$4; num=mem; gsub(/[^0-9.]/, "", num)
        if      (mem ~ /Gi$/) val = num * 1024
        else if (mem ~ /Mi$/) val = num
        else if (mem ~ /Ki$/) val = num / 1024
        else                   val = 0
        printf "%f\t%s\n", val, $0
      }
    ' | sort -rn | head -20 | awk -F'\t' '{print $2}'
  )
}
