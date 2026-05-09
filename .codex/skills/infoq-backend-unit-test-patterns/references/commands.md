# 命令清单

## 定向类测试

```bash
mvn -pl infoq-modules/infoq-system -am \
  -DskipTests=false \
  -Dsurefire.failIfNoSpecifiedTests=false \
  -Dtest=<ClassNameTest> test
```

## 定向 Mapper XML 集成测试

```bash
mvn -pl infoq-modules/infoq-system -am \
  -DskipTests=false \
  -Dsurefire.failIfNoSpecifiedTests=false \
  -Dtest=Sys*MapperXmlIntegrationTest test
```

## 单个 Mapper XML 集成测试类

```bash
mvn -pl infoq-modules/infoq-system -am \
  -DskipTests=false \
  -Dsurefire.failIfNoSpecifiedTests=false \
  -Dtest=SysUserMapperXmlIntegrationTest test
```

## 多类联合测试

```bash
mvn -pl infoq-modules/infoq-system -am \
  -DskipTests=false \
  -Dsurefire.failIfNoSpecifiedTests=false \
  -Dtest=ClassATest,ClassBTest,ClassCTest test
```

## 模块全量测试

```bash
mvn -pl infoq-modules/infoq-system -am -DskipTests=false test
```

## 覆盖缺口扫描（类级）

```bash
node .codex/skills/infoq-backend-unit-test-patterns/scripts/scan_missing_tests.mjs
```

## 打包与冒烟

```bash
mvn -pl infoq-modules/infoq-system -am clean package -P dev -DskipTests=false
node .codex/skills/infoq-backend-smoke-test/scripts/run_smoke.mjs
```
