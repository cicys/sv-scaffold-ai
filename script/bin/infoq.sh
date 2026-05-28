#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
COMPOSE_FILE="${REPO_ROOT}/script/docker/docker-compose.yml"
REDIS_CONF_SOURCE="${REPO_ROOT}/script/docker/redis/conf/redis.conf"
SERVER_CONFIG_TEMPLATE="${REPO_ROOT}/script/docker/server/application-prod.yml"
SQL_INIT_FILE="${REPO_ROOT}/sql/infoq_scaffold_2.0.0.sql"
SQL_UPDATE_20260425_FILE="${REPO_ROOT}/sql/infoq_scaffold_update_20260425.sql"
SQL_UPDATE_20260429_FILE="${REPO_ROOT}/sql/infoq_scaffold_update_20260429.sql"
SQL_UPDATE_20260526_FILE="${REPO_ROOT}/sql/infoq_scaffold_update_20260526.sql"
BACKEND_DIR="${REPO_ROOT}/infoq-scaffold-backend"
BACKEND_SERVICES=(mysql redis minio infoq-admin)
DEFAULT_DEPLOY_ROOT="/infoq"
DEPLOY_ROOT=""
COMPOSE_CMD=()

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
  INFOQ_DEPLOY_ROOT="${DEPLOY_ROOT}" "${COMPOSE_CMD[@]}" -f "${COMPOSE_FILE}" "$@"
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
  )

  for dir in "${dirs[@]}"; do
    mkdir -p "${dir}"
    chmod 777 "${dir}" || true
  done

  cp -f "${REDIS_CONF_SOURCE}" "${DEPLOY_ROOT}/redis/conf/redis.conf"

  if [[ ! -f "${DEPLOY_ROOT}/server/config/application-prod.yml" ]]; then
    cp -f "${SERVER_CONFIG_TEMPLATE}" "${DEPLOY_ROOT}/server/config/application-prod.yml"
    echo "[backend] 已初始化 ${DEPLOY_ROOT}/server/config/application-prod.yml"
  else
    echo "[backend] 保留现有 ${DEPLOY_ROOT}/server/config/application-prod.yml"
  fi

  echo "[backend] 使用部署根目录: ${DEPLOY_ROOT}"
  echo "[backend] 目录和配置已同步完成"
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

table_exists() {
  local table_name="$1"
  mysql_query "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='infoq' AND LOWER(table_name)=LOWER('${table_name}');"
}

column_count() {
  local table_name="$1"
  local column_list="$2"
  mysql_query "SELECT COUNT(*) FROM information_schema.columns WHERE table_schema='infoq' AND LOWER(table_name)=LOWER('${table_name}') AND column_name IN (${column_list});"
}

menu_exists() {
  local menu_id="$1"
  mysql_query "SELECT COUNT(*) FROM infoq.sys_menu WHERE menu_id=${menu_id};"
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

  mysql_exec_infoq_file "${SQL_UPDATE_20260425_FILE}" "定时任务与 Quartz 表"
}

ensure_monitor_menu_data() {
  if [[ "$(menu_exists 2026042910)" == "1" ]]; then
    return
  fi

  mysql_exec_infoq_file "${SQL_UPDATE_20260429_FILE}" "监控菜单数据"
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

  mysql_exec_infoq_file "${SQL_UPDATE_20260526_FILE}" "配置元数据列"
}

validate_database_initialized() {
  local required_tables_count
  local metadata_columns_count
  local metadata_columns="'value_type','default_value','group_key','display_order','options_json','ui_props_json'"

  required_tables_count="$(mysql_query "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='infoq' AND LOWER(table_name) IN ('sys_oss_config','sys_job','qrtz_locks');")"
  metadata_columns_count="$(column_count sys_config "${metadata_columns}")"

  if [[ "${required_tables_count}" != "3" || "${metadata_columns_count}" != "6" ]]; then
    echo "[backend] 数据库初始化校验失败: required_tables=${required_tables_count}, sys_config_metadata_columns=${metadata_columns_count}" >&2
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
  ensure_scheduler_schema
  ensure_monitor_menu_data
  ensure_config_metadata_columns
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
  package_backend
  start_dependencies
  compose up -d --build infoq-admin
  echo "[backend] 部署完成，访问端口: 9090"
}

start_backend() {
  resolve_compose_command
  prepare_dirs
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
