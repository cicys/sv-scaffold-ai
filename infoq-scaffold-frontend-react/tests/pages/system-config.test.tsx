import { beforeEach, describe, expect, it, vi } from 'vitest';
import { fireEvent, screen, waitFor } from '@testing-library/react';
import { renderWithRouter } from '../helpers/renderWithRouter';

const configPageMocks = vi.hoisted(() => ({
  listConfig: vi.fn(),
  getConfig: vi.fn(),
  getConfigKey: vi.fn(),
  addConfig: vi.fn(),
  updateConfig: vi.fn(),
  updateConfigByKey: vi.fn(),
  delConfig: vi.fn(),
  refreshCache: vi.fn()
}));

vi.mock('@/api/system/config', () => ({
  listConfig: configPageMocks.listConfig,
  getConfig: configPageMocks.getConfig,
  getConfigKey: configPageMocks.getConfigKey,
  addConfig: configPageMocks.addConfig,
  updateConfig: configPageMocks.updateConfig,
  updateConfigByKey: configPageMocks.updateConfigByKey,
  delConfig: configPageMocks.delConfig,
  refreshCache: configPageMocks.refreshCache
}));

vi.mock('@/hooks/useDictOptions', () => ({
  default: () => ({
    sys_yes_no: [
      { label: '是', value: 'Y' },
      { label: '否', value: 'N' }
    ]
  })
}));

vi.mock('@/components/Pagination', () => ({
  default: () => <div data-testid="pagination" />
}));

vi.mock('@/components/RightToolbar', () => ({
  default: () => <div data-testid="right-toolbar" />
}));

vi.mock('@/components/DictTag', () => ({
  default: ({ value }: { value?: string }) => <span>{value}</span>
}));

vi.mock('@/utils/modal', () => ({
  default: {
    confirm: vi.fn().mockResolvedValue(true),
    msgSuccess: vi.fn(),
    msgWarning: vi.fn(),
    msgError: vi.fn(),
    loading: vi.fn(),
    closeLoading: vi.fn()
  }
}));

vi.mock('@/utils/request', async () => {
  const actual = await vi.importActual<typeof import('@/utils/request')>('@/utils/request');
  return {
    ...actual,
    download: vi.fn()
  };
});

vi.mock('@/store/modules/user', () => ({
  useUserStore: (selector: (state: { roles: string[] }) => unknown) => selector({ roles: ['superadmin'] })
}));

const { default: ConfigPage } = await import('@/pages/system/config/index');

describe('pages/system/config', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    configPageMocks.listConfig.mockResolvedValue({
      rows: [
        {
          configId: 1,
          configName: '主题',
          configKey: 'sys.theme',
          configValue: 'light',
          configType: 'Y',
          remark: '',
          createTime: '2026-05-13 10:00:00'
        }
      ],
      total: 1
    });
    configPageMocks.getConfigKey.mockImplementation((key: string) =>
      Promise.resolve({
        data: key === 'sys.account.registerUser' ? 'true' : 'false'
      })
    );
    configPageMocks.updateConfigByKey.mockResolvedValue(undefined);
  });

  it('loads config list and account settings for superadmin', async () => {
    renderWithRouter(<ConfigPage />, '/system/config');

    expect(await screen.findByText('账号自助设置')).toBeInTheDocument();
    await waitFor(() => {
      expect(configPageMocks.listConfig).toHaveBeenCalled();
      expect(configPageMocks.getConfigKey).toHaveBeenCalledWith('sys.account.registerUser');
      expect(configPageMocks.getConfigKey).toHaveBeenCalledWith('sys.account.inviteRegister');
    });
  });

  it('updates register switch by config key', async () => {
    renderWithRouter(<ConfigPage />, '/system/config');

    const switches = await screen.findAllByRole('switch');
    fireEvent.click(switches[0]);

    await waitFor(() => {
      expect(configPageMocks.updateConfigByKey).toHaveBeenCalledWith('sys.account.registerUser', false);
    });
  });
});
