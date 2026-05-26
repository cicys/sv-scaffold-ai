<template>
  <div class="p-2">
    <transition :enter-active-class="proxy?.animate.searchAnimate.enter" :leave-active-class="proxy?.animate.searchAnimate.leave">
      <div v-show="showSearch" class="mb-[10px]">
        <el-card shadow="hover">
          <el-form ref="queryFormRef" :model="queryParams" :inline="true">
            <el-form-item label="参数名称" prop="configName">
              <el-input v-model="queryParams.configName" placeholder="请输入参数名称" clearable @keyup.enter="handleQuery" />
            </el-form-item>
            <el-form-item label="参数键名" prop="configKey">
              <el-input v-model="queryParams.configKey" placeholder="请输入参数键名" clearable @keyup.enter="handleQuery" />
            </el-form-item>
            <el-form-item label="系统内置" prop="configType">
              <el-select v-model="queryParams.configType" placeholder="系统内置" clearable>
                <el-option v-for="dict in sys_yes_no" :key="dict.value" :label="dict.label" :value="dict.value" />
              </el-select>
            </el-form-item>
            <el-form-item label="创建时间" style="width: 308px">
              <el-date-picker
                v-model="dateRange"
                value-format="YYYY-MM-DD HH:mm:ss"
                type="daterange"
                range-separator="-"
                start-placeholder="开始日期"
                end-placeholder="结束日期"
                :default-time="[new Date(2000, 1, 1, 0, 0, 0), new Date(2000, 1, 1, 23, 59, 59)]"
              />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
              <el-button icon="Refresh" @click="resetQuery">重置</el-button>
            </el-form-item>
          </el-form>
        </el-card>
      </div>
    </transition>

    <el-card v-if="isSuperAdmin" shadow="hover" class="mb-[10px]" v-loading="accountSettingLoading">
      <template #header>
        <div class="account-setting-header">
          <span>账号自助设置</span>
          <span class="account-setting-tip">仅 superadmin 可修改，邀请码注册依赖注册总开关与验证码能力。</span>
        </div>
      </template>
      <div class="account-setting-list">
        <div class="account-setting-item">
          <div>
            <div class="account-setting-label">是否开启注册</div>
            <div class="account-setting-desc">关闭后会自动关闭邀请码注册，公开注册页不可访问。</div>
          </div>
          <el-switch v-model="accountSettings.registerEnabled" :loading="registerSwitchLoading" @change="handleRegisterSettingChange" />
        </div>
        <div class="account-setting-item">
          <div>
            <div class="account-setting-label">是否开启邀请码注册</div>
            <div class="account-setting-desc">开启后公开注册页显示邀请码输入框，发送验证码前必须先校验邀请码。</div>
          </div>
          <el-switch
            v-model="accountSettings.inviteRegisterEnabled"
            :disabled="!accountSettings.registerEnabled || accountSettingLoading"
            :loading="inviteSwitchLoading"
            @change="handleInviteSettingChange"
          />
        </div>
      </div>
    </el-card>

    <el-card shadow="hover">
      <template #header>
        <el-row :gutter="10" class="mb8">
          <el-col :span="1.5">
            <el-button v-hasPermi="['system:config:add']" type="primary" plain icon="Plus" @click="handleAdd">新增</el-button>
          </el-col>
          <el-col :span="1.5">
            <el-button v-hasPermi="['system:config:edit']" type="success" plain icon="Edit" :disabled="single" @click="handleUpdate()">修改</el-button>
          </el-col>
          <el-col :span="1.5">
            <el-button v-hasPermi="['system:config:remove']" type="danger" plain icon="Delete" :disabled="multiple" @click="handleDelete()">删除</el-button>
          </el-col>
          <el-col :span="1.5">
            <el-button v-hasPermi="['system:config:export']" type="warning" plain icon="Download" @click="handleExport">导出</el-button>
          </el-col>
          <el-col :span="1.5">
            <el-button v-hasPermi="['system:config:remove']" type="danger" plain icon="Refresh" @click="handleRefreshCache">刷新缓存</el-button>
          </el-col>
          <right-toolbar v-model:show-search="showSearch" @query-table="getList" />
        </el-row>
      </template>

      <el-table v-loading="loading" border :data="configList" @selection-change="handleSelectionChange">
        <el-table-column type="selection" width="55" align="center" />
        <el-table-column label="参数名称" align="center" prop="configName" :show-overflow-tooltip="true" />
        <el-table-column label="参数键名" align="center" prop="configKey" :show-overflow-tooltip="true" />
        <el-table-column label="参数键值" align="center" prop="configValue" :show-overflow-tooltip="true" />
        <el-table-column label="系统内置" align="center" prop="configType">
          <template #default="scope">
            <dict-tag :options="sys_yes_no" :value="scope.row.configType" />
          </template>
        </el-table-column>
        <el-table-column label="备注" align="center" prop="remark" :show-overflow-tooltip="true" />
        <el-table-column label="创建时间" align="center" prop="createTime" width="180">
          <template #default="scope">
            <span>{{ proxy.parseTime(scope.row.createTime) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" align="center" width="150" class-name="small-padding fixed-width">
          <template #default="scope">
            <el-tooltip content="修改" placement="top">
              <el-button v-hasPermi="['system:config:edit']" link type="primary" icon="Edit" @click="handleUpdate(scope.row)" />
            </el-tooltip>
            <el-tooltip content="删除" placement="top">
              <el-button v-hasPermi="['system:config:remove']" link type="primary" icon="Delete" @click="handleDelete(scope.row)" />
            </el-tooltip>
          </template>
        </el-table-column>
      </el-table>
      <pagination v-show="total > 0" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" :total="total" @pagination="getList" />
    </el-card>

    <el-dialog v-model="dialog.visible" :title="dialog.title" width="500px" append-to-body>
      <el-form ref="configFormRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="参数名称" prop="configName">
          <el-input v-model="form.configName" placeholder="请输入参数名称" />
        </el-form-item>
        <el-form-item label="参数键名" prop="configKey">
          <el-input v-model="form.configKey" placeholder="请输入参数键名" />
        </el-form-item>
        <el-form-item label="参数键值" prop="configValue">
          <el-input v-model="form.configValue" type="textarea" placeholder="请输入参数键值" />
        </el-form-item>
        <el-form-item label="系统内置" prop="configType">
          <el-radio-group v-model="form.configType">
            <el-radio v-for="dict in sys_yes_no" :key="dict.value" :value="dict.value">{{ dict.label }}</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" type="textarea" placeholder="请输入内容" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确定</el-button>
          <el-button @click="cancel">取消</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="Config" lang="ts">
import { useUserStore } from '@/store/modules/user';
import { listConfig, getConfig, getConfigKey, delConfig, addConfig, updateConfig, updateConfigByKey, refreshCache } from '@/api/system/config';
import type { ConfigForm, ConfigQuery, ConfigVO } from '@/api/system/config/types';
import { toDictRefs } from '@/utils/dict';

const { proxy } = getCurrentInstance() as ComponentInternalInstance;
const { sys_yes_no } = toDictRefs((proxy?.useDict('sys_yes_no') ?? {}) as Record<'sys_yes_no', DictDataOption[]>);
const userStore = useUserStore();

const configList = ref<ConfigVO[]>([]);
const loading = ref(true);
const showSearch = ref(true);
const ids = ref<Array<number | string>>([]);
const single = ref(true);
const multiple = ref(true);
const total = ref(0);
const dateRange = ref<[DateModelType, DateModelType]>(['', '']);
const accountSettingLoading = ref(false);
const registerSwitchLoading = ref(false);
const inviteSwitchLoading = ref(false);
const accountSettings = reactive({
  registerEnabled: false,
  inviteRegisterEnabled: false
});
const accountConfigKeys = {
  register: 'sys.account.registerUser',
  invite: 'sys.account.inviteRegister'
};
const isSuperAdmin = computed(() => userStore.roles.includes('superadmin'));

const queryFormRef = ref<ElFormInstance>();
const configFormRef = ref<ElFormInstance>();
const dialog = reactive<DialogOption>({
  visible: false,
  title: ''
});
const initFormData: ConfigForm = {
  configId: undefined,
  configName: '',
  configKey: '',
  configValue: '',
  configType: 'Y',
  remark: ''
};
const data = reactive<PageData<ConfigForm, ConfigQuery>>({
  form: { ...initFormData },
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    configName: '',
    configKey: '',
    configType: ''
  },
  rules: {
    configName: [{ required: true, message: '参数名称不能为空', trigger: 'blur' }],
    configKey: [{ required: true, message: '参数键名不能为空', trigger: 'blur' }],
    configValue: [{ required: true, message: '参数键值不能为空', trigger: 'blur' }]
  }
});

const { queryParams, form, rules } = toRefs(data);

const loadAccountSettings = async () => {
  if (!isSuperAdmin.value) {
    return;
  }
  accountSettingLoading.value = true;
  try {
    const [registerRes, inviteRes] = await Promise.all([getConfigKey(accountConfigKeys.register), getConfigKey(accountConfigKeys.invite)]);
    accountSettings.registerEnabled = registerRes.data === 'true';
    accountSettings.inviteRegisterEnabled = inviteRes.data === 'true';
  } finally {
    accountSettingLoading.value = false;
  }
};

const getList = async () => {
  loading.value = true;
  const res = await listConfig(proxy?.addDateRange(queryParams.value, dateRange.value));
  configList.value = res.rows;
  total.value = res.total;
  loading.value = false;
};

const cancel = () => {
  reset();
  dialog.visible = false;
};

const reset = () => {
  form.value = { ...initFormData };
  configFormRef.value?.resetFields();
};

const handleQuery = () => {
  queryParams.value.pageNum = 1;
  getList();
};

const resetQuery = () => {
  dateRange.value = ['', ''];
  queryFormRef.value?.resetFields();
  handleQuery();
};

const handleSelectionChange = (selection: ConfigVO[]) => {
  ids.value = selection.map((item) => item.configId);
  single.value = selection.length !== 1;
  multiple.value = !selection.length;
};

const handleAdd = () => {
  reset();
  dialog.visible = true;
  dialog.title = '添加参数';
};

const handleUpdate = async (row?: ConfigVO) => {
  reset();
  const configId = row?.configId || ids.value[0];
  const res = await getConfig(configId);
  Object.assign(form.value, res.data);
  dialog.visible = true;
  dialog.title = '修改参数';
};

const submitForm = () => {
  configFormRef.value?.validate(async (valid: boolean) => {
    if (!valid) {
      return;
    }
    form.value.configId ? await updateConfig(form.value) : await addConfig(form.value);
    proxy?.$modal.msgSuccess('操作成功');
    dialog.visible = false;
    await getList();
  });
};

const handleDelete = async (row?: ConfigVO) => {
  const configIds = row?.configId || ids.value;
  await proxy?.$modal.confirm('是否确认删除参数编号为"' + configIds + '"的数据项？');
  await delConfig(configIds);
  await getList();
  proxy?.$modal.msgSuccess('删除成功');
};

const handleExport = () => {
  proxy?.download(
    'system/config/export',
    {
      ...queryParams.value
    },
    `config_${new Date().getTime()}.xlsx`
  );
};

const handleRefreshCache = async () => {
  await refreshCache();
  proxy?.$modal.msgSuccess('刷新缓存成功');
};

const handleRegisterSettingChange = async (value: boolean) => {
  const previous = !value;
  registerSwitchLoading.value = true;
  try {
    await updateConfigByKey(accountConfigKeys.register, value);
    await loadAccountSettings();
    proxy?.$modal.msgSuccess('操作成功');
  } catch (error) {
    accountSettings.registerEnabled = previous;
    throw error;
  } finally {
    registerSwitchLoading.value = false;
  }
};

const handleInviteSettingChange = async (value: boolean) => {
  const previous = !value;
  inviteSwitchLoading.value = true;
  try {
    await updateConfigByKey(accountConfigKeys.invite, value);
    await loadAccountSettings();
    proxy?.$modal.msgSuccess('操作成功');
  } catch (error) {
    accountSettings.inviteRegisterEnabled = previous;
    throw error;
  } finally {
    inviteSwitchLoading.value = false;
  }
};

onMounted(() => {
  getList();
  loadAccountSettings();
});
</script>

<style lang="scss" scoped>
.account-setting-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  flex-wrap: wrap;
}

.account-setting-tip {
  font-size: 12px;
  color: var(--el-text-color-secondary);
}

.account-setting-list {
  display: grid;
  gap: 16px;
}

.account-setting-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 24px;
  padding: 16px 0;
  border-bottom: 1px solid var(--el-border-color-light);
}

.account-setting-item:last-child {
  padding-bottom: 0;
  border-bottom: none;
}

.account-setting-label {
  font-size: 14px;
  font-weight: 600;
  color: var(--el-text-color-primary);
}

.account-setting-desc {
  margin-top: 4px;
  font-size: 12px;
  line-height: 1.6;
  color: var(--el-text-color-secondary);
}
</style>
