import { flushPromises, mount } from '@vue/test-utils';
import { computed, defineComponent, h, inject, provide, reactive } from 'vue';
import ConfigView from '@/views/system/config/index.vue';

const panelFixture = {
  groups: [
    {
      groupKey: 'account',
      groupName: '账号与登录',
      displayOrder: 10,
      items: [
        {
          configId: 5,
          configName: '是否开启注册',
          configKey: 'sys.account.registerUser',
          configValue: 'true',
          configType: 'Y',
          valueType: 'switch',
          defaultValue: 'false',
          groupKey: 'account',
          displayOrder: 10,
          options: null,
          uiProps: {},
          editable: true,
          editableReason: null,
          remark: '关闭后公开注册不可访问'
        },
        {
          configId: 2,
          configName: '初始密码',
          configKey: 'sys.user.initPassword',
          configValue: '123456',
          configType: 'Y',
          valueType: 'password',
          defaultValue: '123456',
          groupKey: 'account',
          displayOrder: 40,
          options: null,
          uiProps: {},
          editable: true,
          editableReason: null,
          remark: '初始化密码'
        }
      ]
    },
    {
      groupKey: 'theme',
      groupName: '界面与主题',
      displayOrder: 20,
      items: [
        {
          configId: 3,
          configName: '侧边栏主题',
          configKey: 'sys.index.sideTheme',
          configValue: 'theme-light',
          configType: 'Y',
          valueType: 'select',
          defaultValue: 'theme-light',
          groupKey: 'theme',
          displayOrder: 10,
          options: [
            { label: '深色主题', value: 'theme-dark' },
            { label: '浅色主题', value: 'theme-light' }
          ],
          uiProps: {},
          editable: true,
          editableReason: null,
          remark: '深色主题theme-dark，浅色主题theme-light'
        }
      ]
    }
  ]
};

const largePanelFixture = {
  groups: [
    {
      ...panelFixture.groups[0],
      items: Array.from({ length: 12 }, (_, index) => ({
        ...panelFixture.groups[0].items[0],
        configId: 100 + index,
        configName: `分页配置${index + 1}`,
        configKey: `sys.page.${index + 1}`,
        configValue: `value-${index + 1}`,
        valueType: 'text',
        remark: `分页测试${index + 1}`
      }))
    }
  ]
};

const configMocks = vi.hoisted(() => ({
  getConfigPanel: vi.fn(),
  addConfig: vi.fn(),
  updateConfig: vi.fn(),
  updateConfigByKey: vi.fn(),
  resetConfigByKey: vi.fn(),
  reorderConfig: vi.fn(),
  refreshCache: vi.fn(),
  msgSuccess: vi.fn(),
  msgWarning: vi.fn(),
  download: vi.fn()
}));

vi.mock('@/api/system/config', () => ({
  getConfigPanel: configMocks.getConfigPanel,
  addConfig: configMocks.addConfig,
  updateConfig: configMocks.updateConfig,
  updateConfigByKey: configMocks.updateConfigByKey,
  resetConfigByKey: configMocks.resetConfigByKey,
  reorderConfig: configMocks.reorderConfig,
  refreshCache: configMocks.refreshCache
}));

vi.mock('@/store/modules/user', () => ({
  useUserStore: () => ({
    roles: ['superadmin']
  })
}));

const passthroughStub = (name: string) =>
  defineComponent({
    name,
    setup(_, { slots }) {
      return () => h('div', slots.default?.());
    }
  });

const TABLE_DATA_SYMBOL = Symbol('configTableData');

const ElCardStub = defineComponent({
  name: 'ElCard',
  setup(_, { slots }) {
    return () => h('div', { class: 'el-card-stub' }, [slots.header?.(), slots.default?.()]);
  }
});

const ElButtonStub = defineComponent({
  name: 'ElButton',
  props: {
    icon: { type: String, default: '' },
    disabled: { type: Boolean, default: false }
  },
  emits: ['click'],
  setup(props, { slots, emit }) {
    return () =>
      h(
        'button',
        {
          class: 'el-button-stub',
          'data-icon': props.icon,
          disabled: props.disabled,
          onClick: (event: MouseEvent) => emit('click', event)
        },
        slots.default?.()
      );
  }
});

const ElSwitchStub = defineComponent({
  name: 'ElSwitch',
  props: {
    modelValue: { type: Boolean, default: false }
  },
  emits: ['update:modelValue', 'change'],
  setup(props, { emit }) {
    return () =>
      h(
        'button',
        {
          class: 'el-switch-stub',
          'data-model-value': String(props.modelValue),
          onClick: () => {
            const next = !props.modelValue;
            emit('update:modelValue', next);
            emit('change', next);
          }
        },
        'switch'
      );
  }
});

const ElFormStub = defineComponent({
  name: 'ElForm',
  setup(_, { slots, expose }) {
    expose({
      resetFields: vi.fn(),
      validate: (cb: (valid: boolean) => void) => cb(true)
    });
    return () => h('form', slots.default?.());
  }
});

const ElInputStub = defineComponent({
  name: 'ElInput',
  props: {
    modelValue: { type: [String, Number], default: '' },
    placeholder: { type: String, default: '' }
  },
  emits: ['update:modelValue'],
  setup(props, { emit }) {
    return () =>
      h('input', {
        value: props.modelValue,
        placeholder: props.placeholder,
        onInput: (event: Event) => emit('update:modelValue', (event.target as HTMLInputElement).value)
      });
  }
});

const ElTableStub = defineComponent({
  name: 'ElTable',
  props: {
    data: {
      type: Array,
      default: () => []
    }
  },
  setup(props, { slots }) {
    provide(
      TABLE_DATA_SYMBOL,
      computed(() => props.data as unknown[])
    );
    return () => h('div', { class: 'el-table-stub' }, slots.default?.());
  }
});

const ElTableColumnStub = defineComponent({
  name: 'ElTableColumn',
  setup(_, { slots }) {
    const rows = inject(
      TABLE_DATA_SYMBOL,
      computed(() => [] as unknown[])
    );
    return () => h('div', { class: 'el-table-column-stub' }, (slots.default && slots.default({ row: rows.value[0] || {}, $index: 0 })) || []);
  }
});

const PaginationStub = defineComponent({
  name: 'Pagination',
  props: {
    total: { type: Number, default: 0 },
    page: { type: Number, default: 1 },
    limit: { type: Number, default: 10 }
  },
  emits: ['update:page', 'update:limit', 'pagination'],
  setup(props, { emit }) {
    return () =>
      h('div', { class: 'pagination-stub', 'data-total': String(props.total) }, [
        h(
          'button',
          {
            class: 'pagination-next-stub',
            onClick: () => {
              emit('update:page', 2);
              emit('pagination', { page: 2, limit: props.limit });
            }
          },
          'next'
        )
      ]);
  }
});

describe('views/system/config/index', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    configMocks.getConfigPanel.mockResolvedValue({ data: panelFixture });
    configMocks.updateConfigByKey.mockResolvedValue(undefined);
    configMocks.resetConfigByKey.mockResolvedValue({ data: 'false' });
    configMocks.refreshCache.mockResolvedValue(undefined);
  });

  const mountView = () =>
    mount(ConfigView, {
      global: {
        config: {
          globalProperties: {
            useDict: () => reactive({}),
            $modal: {
              msgSuccess: configMocks.msgSuccess,
              msgWarning: configMocks.msgWarning
            },
            download: configMocks.download
          } as unknown as import('vue').ComponentCustomProperties & Record<string, unknown>
        },
        directives: {
          loading: {},
          hasPermi: {}
        },
        stubs: {
          'el-card': ElCardStub,
          'el-button': ElButtonStub,
          'el-switch': ElSwitchStub,
          'el-input': ElInputStub,
          'el-select': passthroughStub('ElSelect'),
          'el-option': passthroughStub('ElOption'),
          'el-tag': passthroughStub('ElTag'),
          'el-empty': passthroughStub('ElEmpty'),
          'el-drawer': passthroughStub('ElDrawer'),
          'el-tabs': passthroughStub('ElTabs'),
          'el-tab-pane': passthroughStub('ElTabPane'),
          'el-form': ElFormStub,
          'el-form-item': passthroughStub('ElFormItem'),
          'el-input-number': true,
          'el-table': ElTableStub,
          'el-table-column': ElTableColumnStub,
          pagination: PaginationStub
        }
      }
    });

  it('loads grouped config panel on mounted', async () => {
    const wrapper = mountView();
    await flushPromises();

    expect(configMocks.getConfigPanel).toHaveBeenCalled();
    expect(wrapper.text()).toContain('账号与登录');
    expect(wrapper.text()).toContain('是否开启注册');
    expect(wrapper.text()).toContain('初始密码');
    expect(wrapper.findAll('.config-setting-row')).toHaveLength(3);
    expect(wrapper.find('.config-list-panel').exists()).toBe(true);
    expect(wrapper.find('.config-list-scroll').exists()).toBe(true);
  });

  it('paginates the config list inside the scrollable list panel', async () => {
    configMocks.getConfigPanel.mockResolvedValueOnce({ data: largePanelFixture });
    const wrapper = mountView();
    await flushPromises();

    expect(wrapper.text()).toContain('分页配置1');
    expect(wrapper.findAll('.config-setting-row')).toHaveLength(10);
    expect(wrapper.text()).not.toContain('分页配置11');

    await wrapper.find('button.pagination-next-stub').trigger('click');
    await flushPromises();

    expect(wrapper.text()).toContain('分页配置11');
    expect(wrapper.findAll('.config-setting-row')).toHaveLength(2);
  });

  it('updates switch config by key', async () => {
    const wrapper = mountView();
    await flushPromises();

    const switchButton = wrapper.find('button.el-switch-stub[data-model-value="true"]');
    expect(switchButton.exists()).toBe(true);
    await switchButton.trigger('click');
    await flushPromises();

    expect(configMocks.updateConfigByKey).toHaveBeenCalledWith('sys.account.registerUser', false);
  });

  it('enters password edit mode without leaving the config card layout', async () => {
    const wrapper = mountView();
    await flushPromises();

    const editButton = wrapper.findAll('button.el-button-stub').find((button) => button.text().includes('编辑'));
    expect(editButton).toBeDefined();
    await editButton!.trigger('click');
    await flushPromises();

    expect(wrapper.find('.config-card-main-editing').exists()).toBe(true);
    expect(wrapper.findAll('input').some((input) => (input.element as HTMLInputElement).value === '123456')).toBe(true);
  });

  it('restores default value through resetByKey', async () => {
    const wrapper = mountView();
    await flushPromises();

    const resetButton = wrapper.findAll('button.el-button-stub').find((button) => button.text().includes('恢复默认'));
    expect(resetButton).toBeDefined();
    await resetButton!.trigger('click');
    await flushPromises();

    expect(configMocks.resetConfigByKey).toHaveBeenCalledWith('sys.account.registerUser');
  });
});
