#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
COMPOSE_FILE="${REPO_ROOT}/script/docker/docker-compose.yml"
REDIS_CONF_SOURCE="${REPO_ROOT}/script/docker/redis/conf/redis.conf"
SERVER_CONFIG_TEMPLATE="${REPO_ROOT}/script/docker/server/application-prod.yml"
IP2REGION_V6_SOURCE="${REPO_ROOT}/script/docker/server/ip2region/ip2region_v6.xdb"
SQL_DIR="${REPO_ROOT}/sql"
SQL_INIT_FILE="${SQL_DIR}/infoq_scaffold_2.0.0.sql"
BACKEND_DIR="${REPO_ROOT}/infoq-scaffold-backend"
BACKEND_SERVICES=(mysql redis minio infoq-admin)
DEFAULT_DEPLOY_ROOT="/infoq"
DEPLOY_ROOT=""
COMPOSE_CMD=()
DEPLOY_ID="${DEPLOY_ID:-}"

usage() {
  cat <<'EOF'
用法: bash script/bin/infoq.sh {prepare|package|build-image|deploy|start|stop|restart|status|logs} [service]

命令说明:
  prepare      创建后端及依赖服务所需宿主机目录，并同步 redis.conf 与 application-prod.yml
  package      执行后端 prod 打包
  build-image  仅构建 infoq-admin 镜像
  deploy       prepare + package + 启动依赖服务 + 自动初始化数据库 + 启动 infoq-admin
  start        启动现有 mysql、redis、minio、infoq-admin 容器
  stop         停止 mysql、redis、minio、infoq-admin
  restart      重启现有 infoq-admin 容器
  status       查看后端相关服务状态
  logs         查看服务日志，默认 infoq-admin，可选 mysql|redis|minio|infoq-admin
EOF
}

require_command() {
  local name="$1"
  if ! command -v "$name" >/dev/null 2>&1; then
    echo "[backend] 缺少命令: $name" >&2
    exit 1
  fi
}

resolve_compose_command() {
  if (( ${#COMPOSE_CMD[@]} > 0 )); then
    return
  fi

  if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    COMPOSE_CMD=(docker compose)
    return
  fi

  if command -v docker-compose >/dev/null 2>&1 && docker-compose version >/dev/null 2>&1; then
    COMPOSE_CMD=(docker-compose)
    return
  fi

  echo "[backend] 缺少 Docker Compose CLI: 需要 docker compose 或 docker-compose" >&2
  exit 1
}

compose() {
  resolve_compose_command
  INFOQ_DEPLOY_ROOT="${DEPLOY_ROOT}" DEPLOY_ID="${DEPLOY_ID:-}" "${COMPOSE_CMD[@]}" -f "${COMPOSE_FILE}" "$@"
}

resolve_deploy_root() {
  if [[ -n "${INFOQ_DEPLOY_ROOT:-}" ]]; then
    DEPLOY_ROOT="${INFOQ_DEPLOY_ROOT}"
  elif [[ -d "${DEFAULT_DEPLOY_ROOT}" || -w "/" ]]; then
    DEPLOY_ROOT="${DEFAULT_DEPLOY_ROOT}"
  else
    DEPLOY_ROOT="${HOME}/infoq"
  fi
}

prepare_dirs() {
  local dirs=(
    "${DEPLOY_ROOT}/mysql/data"
    "${DEPLOY_ROOT}/mysql/conf"
    "${DEPLOY_ROOT}/redis/conf"
    "${DEPLOY_ROOT}/redis/data"
    "${DEPLOY_ROOT}/minio/data"
    "${DEPLOY_ROOT}/server/config"
    "${DEPLOY_ROOT}/server/logs"
    "${DEPLOY_ROOT}/server/temp"
    "${DEPLOY_ROOT}/server/ip2region"
  )

  for dir in "${dirs[@]}"; do
    mkdir -p "${dir}"
    chmod 777 "${dir}" || true
  done

  cp -f "${REDIS_CONF_SOURCE}" "${DEPLOY_ROOT}/redis/conf/redis.conf"

  if [[ ! -f "${IP2REGION_V6_SOURCE}" ]]; then
    echo "[backend] 缺少 IPv6 地址库源文件: ${IP2REGION_V6_SOURCE}" >&2
    exit 1
  fi
  if [[ ! -f "${DEPLOY_ROOT}/server/ip2region/ip2region_v6.xdb" ]]; then
    cp -f "${IP2REGION_V6_SOURCE}" "${DEPLOY_ROOT}/server/ip2region/ip2region_v6.xdb"
    chmod 644 "${DEPLOY_ROOT}/server/ip2region/ip2region_v6.xdb" || true
    echo "[backend] 已同步 ${DEPLOY_ROOT}/server/ip2region/ip2region_v6.xdb"
  else
    echo "[backend] 保留现有 ${DEPLOY_ROOT}/server/ip2region/ip2region_v6.xdb"
  fi

  if [[ ! -f "${DEPLOY_ROOT}/server/config/application-prod.yml" ]]; then
    cp -f "${SERVER_CONFIG_TEMPLATE}" "${DEPLOY_ROOT}/server/config/application-prod.yml"
    echo "[backend] 已初始化 ${DEPLOY_ROOT}/server/config/application-prod.yml"
  else
    echo "[backend] 保留现有 ${DEPLOY_ROOT}/server/config/application-prod.yml"
  fi

  echo "[backend] 使用部署根目录: ${DEPLOY_ROOT}"
  echo "[backend] 目录和配置已同步完成"
}

backend_revision() {
  local revision
  revision="$(sed -n 's/.*<revision>\(.*\)<\/revision>.*/\1/p' "${BACKEND_DIR}/pom.xml" | head -n 1)"
  if [[ -z "${revision}" ]]; then
    revision="unknown"
  fi
  printf '%s' "${revision}"
}

generate_deploy_id() {
  printf '%s-%s' "$(backend_revision)" "$(date +%Y%m%d%H%M%S)"
}

validate_deploy_id() {
  if [[ -z "${DEPLOY_ID//[[:space:]]/}" ]]; then
    echo "[backend] DEPLOY_ID 不能为空。生产同一批 backend 节点必须使用同一个 DEPLOY_ID" >&2
    exit 1
  fi
}

persist_deploy_id() {
  local deploy_id_file="${DEPLOY_ROOT}/server/config/deploy-id"
  printf '%s\n' "${DEPLOY_ID}" > "${deploy_id_file}"
  echo "[backend] 当前部署批次 DEPLOY_ID=${DEPLOY_ID}"
}

load_existing_deploy_id() {
  local deploy_id_file="${DEPLOY_ROOT}/server/config/deploy-id"
  if [[ ! -f "${deploy_id_file}" ]]; then
    echo "[backend] 缺少 ${deploy_id_file}，请先执行 deploy 或显式设置 DEPLOY_ID" >&2
    exit 1
  fi
  IFS= read -r DEPLOY_ID < "${deploy_id_file}"
  validate_deploy_id
}

prepare_new_deploy_id() {
  if [[ -z "${DEPLOY_ID//[[:space:]]/}" ]]; then
    DEPLOY_ID="$(generate_deploy_id)"
  fi
  validate_deploy_id
  persist_deploy_id
}

prepare_existing_deploy_id() {
  if [[ -n "${DEPLOY_ID//[[:space:]]/}" ]]; then
    validate_deploy_id
    echo "[backend] 使用外部 DEPLOY_ID=${DEPLOY_ID}"
    return
  fi
  load_existing_deploy_id
  echo "[backend] 复用部署批次 DEPLOY_ID=${DEPLOY_ID}"
}

package_backend() {
  require_command mvn
  (
    cd "${BACKEND_DIR}"
    mvn clean package -P prod -pl infoq-admin -am
  )
}

build_image() {
  resolve_compose_command
  compose build infoq-admin
}

wait_for_mysql() {
  local max_attempts=60
  local attempt=1

  echo "[backend] 等待 MySQL 就绪..."
  until compose exec -T mysql mysqladmin ping -h 127.0.0.1 -uroot -proot --silent >/dev/null 2>&1; do
    if (( attempt >= max_attempts )); then
      echo "[backend] MySQL 启动超时" >&2
      exit 1
    fi
    attempt=$((attempt + 1))
    sleep 2
  done
}

wait_for_redis() {
  local max_attempts=60
  local attempt=1

  echo "[backend] 等待 Redis 就绪..."
  until compose exec -T redis redis-cli -a 123456 ping 2>/dev/null | grep -q '^PONG$'; do
    if (( attempt >= max_attempts )); then
      echo "[backend] Redis 启动超时" >&2
      exit 1
    fi
    attempt=$((attempt + 1))
    sleep 2
  done
}

mysql_query() {
  local sql="$1"
  compose exec -T mysql mysql -uroot -proot -Nse "${sql}" 2>/dev/null | tr -d '\r'
}

mysql_exec_infoq_file() {
  local sql_file="$1"
  local label="$2"

  if [[ ! -f "${sql_file}" ]]; then
    echo "[backend] 缺少 SQL 文件: ${sql_file}" >&2
    exit 1
  fi

  echo "[backend] 导入 ${label}: ${sql_file##${REPO_ROOT}/}"
  compose exec -T mysql mysql -uroot -proot infoq < "${sql_file}"
}

discover_sql_update_files() {
  local files=()
  local file

  shopt -s nullglob
  for file in "${SQL_DIR}"/infoq_scaffold_update_*.sql; do
    files+=("${file}")
  done
  shopt -u nullglob

  if (( ${#files[@]} == 0 )); then
    echo "[backend] 未发现 SQL 增量脚本: ${SQL_DIR}/infoq_scaffold_update_*.sql" >&2
    exit 1
  fi

  printf '%s\n' "${files[@]}"
}

table_exists() {
  local table_name="$1"
  mysql_query "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='infoq' AND LOWER(table_name)=LOWER('${table_name}');"
}

column_count() {
  local table_name="$1"
  local column_list="$2"
  mysql_query "SELECT COUNT(*) FROM information_schema.columns WHERE table_schema='infoq' AND LOWER(table_name)=LOWER('${table_name}') AND column_name IN (${column_list});"
}

menu_count() {
  mysql_query "SELECT COUNT(*) FROM infoq.sys_menu WHERE menu_id IN (2026042910,2026042911,2026042920,2026042921);"
}

ensure_base_schema() {
  if [[ "$(table_exists sys_oss_config)" == "1" ]]; then
    return
  fi

  mysql_exec_infoq_file "${SQL_INIT_FILE}" "基础库"
}

ensure_scheduler_schema() {
  local job_table_exists
  local quartz_lock_exists

  job_table_exists="$(table_exists sys_job)"
  quartz_lock_exists="$(table_exists qrtz_locks)"

  if [[ "${job_table_exists}" == "1" && "${quartz_lock_exists}" == "1" ]]; then
    return
  fi

  mysql_exec_infoq_file "${SQL_DIR}/infoq_scaffold_update_20260425.sql" "定时任务与 Quartz 表"
}

ensure_monitor_menu_data() {
  if [[ "$(menu_count)" == "4" ]]; then
    return
  fi

  mysql_exec_infoq_file "${SQL_DIR}/infoq_scaffold_update_20260429.sql" "监控菜单数据"
}

ensure_config_metadata_columns() {
  local expected_count=6
  local actual_count
  local metadata_columns="'value_type','default_value','group_key','display_order','options_json','ui_props_json'"

  actual_count="$(column_count sys_config "${metadata_columns}")"
  if [[ "${actual_count}" == "${expected_count}" ]]; then
    return
  fi

  if [[ "${actual_count}" != "0" ]]; then
    echo "[backend] 检测到 sys_config 配置元数据列处于部分迁移状态，请人工检查后重试" >&2
    exit 1
  fi

  mysql_exec_infoq_file "${SQL_DIR}/infoq_scaffold_update_20260526.sql" "配置元数据列"
}

oauth_schema_ready() {
  local oauth_tables_count
  local oauth_dict_count
  local oauth_client_count

  oauth_tables_count="$(mysql_query "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='infoq' AND LOWER(table_name) IN ('sys_oauth_provider','sys_oauth_identity');")"
  oauth_dict_count="$(mysql_query "SELECT COUNT(*) FROM infoq.sys_dict_data WHERE dict_type='sys_grant_type' AND dict_value='oauth';")"
  oauth_client_count="$(mysql_query "SELECT COUNT(*) FROM infoq.sys_client WHERE client_id='e5cd7e4891bf95d1d19206ce24a7b32e' AND FIND_IN_SET('oauth', REPLACE(COALESCE(grant_type, ''), ' ', '')) > 0;")"

  [[ "${oauth_tables_count}" == "2" && "${oauth_dict_count}" == "1" && "${oauth_client_count}" == "1" ]]
}

ensure_oauth_schema() {
  if oauth_schema_ready; then
    return
  fi

  mysql_exec_infoq_file "${SQL_DIR}/infoq_scaffold_update_20260529.sql" "OAuth 登录表与授权类型"

  if ! oauth_schema_ready; then
    echo "[backend] OAuth 增量 SQL 校验失败，请检查 sys_oauth_provider、sys_oauth_identity、sys_grant_type=oauth 与 sys_client.grant_type" >&2
    exit 1
  fi
}

ensure_sql_update_applied() {
  local sql_file="$1"

  case "${sql_file##*/}" in
    infoq_scaffold_update_20260425.sql)
      ensure_scheduler_schema
      ;;
    infoq_scaffold_update_20260429.sql)
      ensure_monitor_menu_data
      ;;
    infoq_scaffold_update_20260526.sql)
      ensure_config_metadata_columns
      ;;
    infoq_scaffold_update_20260529.sql)
      ensure_oauth_schema
      ;;
    *)
      echo "[backend] 发现未接入校验逻辑的 SQL 增量脚本: ${sql_file##${REPO_ROOT}/}" >&2
      echo "[backend] 请先在 script/bin/infoq.sh 增加幂等执行和执行后校验规则，避免部分迁移状态" >&2
      exit 1
      ;;
  esac
}

ensure_sql_updates() {
  local sql_file

  while IFS= read -r sql_file; do
    ensure_sql_update_applied "${sql_file}"
  done < <(discover_sql_update_files)
}

validate_database_initialized() {
  local required_tables_count
  local monitor_menu_count
  local metadata_columns_count
  local oauth_tables_count
  local oauth_dict_count
  local oauth_client_count
  local metadata_columns="'value_type','default_value','group_key','display_order','options_json','ui_props_json'"

  required_tables_count="$(mysql_query "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='infoq' AND LOWER(table_name) IN ('sys_oss_config','sys_job','qrtz_locks','sys_oauth_provider','sys_oauth_identity');")"
  monitor_menu_count="$(menu_count)"
  metadata_columns_count="$(column_count sys_config "${metadata_columns}")"
  oauth_tables_count="$(mysql_query "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='infoq' AND LOWER(table_name) IN ('sys_oauth_provider','sys_oauth_identity');")"
  oauth_dict_count="$(mysql_query "SELECT COUNT(*) FROM infoq.sys_dict_data WHERE dict_type='sys_grant_type' AND dict_value='oauth';")"
  oauth_client_count="$(mysql_query "SELECT COUNT(*) FROM infoq.sys_client WHERE client_id='e5cd7e4891bf95d1d19206ce24a7b32e' AND FIND_IN_SET('oauth', REPLACE(COALESCE(grant_type, ''), ' ', '')) > 0;")"

  if [[ "${required_tables_count}" != "5" || "${monitor_menu_count}" != "4" || "${metadata_columns_count}" != "6" || "${oauth_tables_count}" != "2" || "${oauth_dict_count}" != "1" || "${oauth_client_count}" != "1" ]]; then
    echo "[backend] 数据库初始化校验失败: required_tables=${required_tables_count}, monitor_menus=${monitor_menu_count}, sys_config_metadata_columns=${metadata_columns_count}, oauth_tables=${oauth_tables_count}, oauth_dict=${oauth_dict_count}, oauth_client_grant=${oauth_client_count}" >&2
    exit 1
  fi
}

ensure_database_initialized() {
  if [[ ! -f "${SQL_INIT_FILE}" ]]; then
    echo "[backend] 缺少 SQL 初始化文件: ${SQL_INIT_FILE}" >&2
    exit 1
  fi

  compose exec -T mysql mysql -uroot -proot -e "CREATE DATABASE IF NOT EXISTS infoq CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
  ensure_base_schema
  ensure_sql_updates
  validate_database_initialized
  echo "[backend] 数据库初始化和增量 SQL 校验完成"
}

start_dependencies() {
  compose up -d mysql redis minio
  wait_for_mysql
  wait_for_redis
  ensure_database_initialized
}

deploy_backend() {
  resolve_compose_command
  prepare_dirs
  prepare_new_deploy_id
  package_backend
  start_dependencies
  compose up -d --build infoq-admin
  echo "[backend] 部署完成，访问端口: 9090"
}

start_backend() {
  resolve_compose_command
  prepare_dirs
  prepare_existing_deploy_id
  start_dependencies
  compose start infoq-admin
  echo "[backend] 服务已启动，访问端口: 9090"
}

stop_backend() {
  resolve_compose_command
  compose stop "${BACKEND_SERVICES[@]}"
}

restart_backend() {
  resolve_compose_command
  prepare_existing_deploy_id
  compose restart infoq-admin
}

status_backend() {
  resolve_compose_command
  compose ps "${BACKEND_SERVICES[@]}"
}

show_logs() {
  resolve_compose_command
  local service="${1:-infoq-admin}"
  compose logs -f "${service}"
}

case "${1:-}" in
  prepare)
    resolve_deploy_root
    prepare_dirs
    ;;
  package)
    package_backend
    ;;
  build-image)
    resolve_deploy_root
    build_image
    ;;
  deploy)
    resolve_deploy_root
    deploy_backend
    ;;
  start)
    resolve_deploy_root
    start_backend
    ;;
  stop)
    resolve_deploy_root
    stop_backend
    ;;
  restart)
    resolve_deploy_root
    restart_backend
    ;;
  status)
    resolve_deploy_root
    status_backend
    ;;
  logs)
    resolve_deploy_root
    show_logs "${2:-infoq-admin}"
    ;;
  *)
    usage
    exit 1
    ;;
esac
