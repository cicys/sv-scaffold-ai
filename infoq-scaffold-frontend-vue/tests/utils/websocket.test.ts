import { ElNotification } from 'element-plus/es/components/notification/index';

const websocketMocks = vi.hoisted(() => {
  return {
    useWebSocket: vi.fn(),
    getToken: vi.fn(),
    addNotice: vi.fn()
  };
});

vi.mock('@vueuse/core', () => ({
  useWebSocket: websocketMocks.useWebSocket
}));

vi.mock('@/utils/auth', () => ({
  getToken: websocketMocks.getToken
}));

vi.mock('@/store/modules/notice', () => ({
  useNoticeStore: vi.fn(() => ({
    addNotice: websocketMocks.addNotice
  }))
}));

import { initWebSocket } from '@/utils/websocket';

describe('utils/websocket', () => {
  const notificationMock = ElNotification as unknown as ReturnType<typeof vi.fn>;

  beforeEach(() => {
    vi.clearAllMocks();
    (import.meta.env as Record<string, string>).VITE_APP_CLIENT_ID = 'test-client-id';
    (import.meta.env as Record<string, string>).VITE_APP_WEBSOCKET = 'true';
  });

  it('skips websocket init when feature switch is disabled', () => {
    (import.meta.env as Record<string, string>).VITE_APP_WEBSOCKET = 'false';
    initWebSocket('/ws/notice');
    expect(websocketMocks.useWebSocket).not.toHaveBeenCalled();
  });

  it('initializes websocket and handles message callback', () => {
    websocketMocks.getToken.mockReturnValue('ws-token');
    websocketMocks.useWebSocket.mockReturnValue({});

    initWebSocket('/ws/notice');

    expect(websocketMocks.useWebSocket).toHaveBeenCalledTimes(1);
    const [url, options] = websocketMocks.useWebSocket.mock.calls[0] as [
      string,
      {
        autoReconnect: { onFailed: () => void; retries: number; delay: number };
        heartbeat: { interval: number; pongTimeout: number };
        onMessage: (_ws: unknown, event: { data: string }) => void;
      }
    ];
    expect(url).toBe('/ws/notice?Authorization=Bearer ws-token&clientid=test-client-id');
    expect(options).toEqual(
      expect.objectContaining({
        autoReconnect: expect.objectContaining({ retries: 3, delay: 1000 }),
        heartbeat: expect.objectContaining({ interval: 10000, pongTimeout: 2000 })
      })
    );

    options.onMessage({}, { data: '业务通知' });
    expect(websocketMocks.addNotice).toHaveBeenCalledWith(
      expect.objectContaining({
        message: '业务通知',
        read: false
      })
    );
    expect(notificationMock).toHaveBeenCalledWith(
      expect.objectContaining({
        message: '业务通知',
        type: 'success'
      })
    );
  });

  it('ignores websocket ping messages', () => {
    websocketMocks.getToken.mockReturnValue('ws-token');
    websocketMocks.useWebSocket.mockReturnValue({});

    initWebSocket('/ws/notice');
    const [, options] = websocketMocks.useWebSocket.mock.calls[0] as [
      string,
      {
        onMessage: (_ws: unknown, event: { data: string }) => void;
      }
    ];

    options.onMessage({}, { data: 'ping' });

    expect(websocketMocks.addNotice).not.toHaveBeenCalled();
    expect(notificationMock).not.toHaveBeenCalled();
  });

  it('logs reconnect failure at error level', () => {
    websocketMocks.getToken.mockReturnValue('ws-token');
    websocketMocks.useWebSocket.mockReturnValue({});
    const consoleErrorSpy = vi.spyOn(console, 'error').mockImplementation(() => {});

    initWebSocket('/ws/notice');
    const [, options] = websocketMocks.useWebSocket.mock.calls[0] as [
      string,
      {
        autoReconnect: { onFailed: () => void };
      }
    ];

    options.autoReconnect.onFailed();

    expect(consoleErrorSpy).toHaveBeenCalledWith('websocket重连失败');
  });
});
