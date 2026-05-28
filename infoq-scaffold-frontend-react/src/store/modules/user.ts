import { create } from 'zustand';
import { login as loginApi, logout as logoutApi, getInfo as getUserInfo } from '@/api/login';
import type { LoginData } from '@/api/types';
import { getToken, removeToken, setToken } from '@/utils/auth';
import { closeSSE, initSSE } from '@/utils/sse';
import { closeWebSocket, initWebSocket } from '@/utils/websocket';
import defaultAvatar from '@/assets/images/profile.jpg';

const ensureStringArray = (value: unknown, label: string) => {
  if (!Array.isArray(value) || value.some((item) => typeof item !== 'string')) {
    throw new Error(`${label} 必须是字符串数组`);
  }
  return value;
};

export type UserState = {
  token: string;
  name: string;
  nickname: string;
  userId: string | number;
  avatar: string;
  roles: string[];
  permissions: string[];
  login: (userInfo: LoginData) => Promise<void>;
  getInfo: () => Promise<void>;
  logout: () => Promise<void>;
  setAvatar: (value: string) => void;
};

export const useUserStore = create<UserState>((set) => ({
  token: getToken(),
  name: '',
  nickname: '',
  userId: '',
  avatar: '',
  roles: [],
  permissions: [],
  login: async (userInfo) => {
    const res = await loginApi(userInfo);
    const token = res.data.access_token;
    setToken(token);
    set({ token });
    initSSE(import.meta.env.VITE_APP_BASE_API + '/resource/sse');
    initWebSocket(import.meta.env.VITE_APP_BASE_API + '/resource/websocket');
  },
  getInfo: async () => {
    const res = await getUserInfo();
    const data = res.data;
    const user = data.user;
    const roles = ensureStringArray(data.roles, '用户角色');
    const permissions = ensureStringArray(data.permissions, '用户权限');
    set({
      roles,
      permissions,
      name: user.userName,
      nickname: user.nickName,
      avatar: user.avatar || defaultAvatar,
      userId: user.userId
    });
  },
  logout: async () => {
    closeSSE();
    closeWebSocket();
    await logoutApi();
    removeToken();
    set({ token: '', roles: [], permissions: [], name: '', nickname: '', avatar: '', userId: '' });
  },
  setAvatar: (value) => set({ avatar: value })
}));
