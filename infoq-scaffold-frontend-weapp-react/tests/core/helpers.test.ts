import * as Taro from '@tarojs/taro';
import {describe, expect, it, type MockInstance, vi} from 'vitest';
import type {TableResponse} from '../../src/api/types';
import {
  asCaptchaImage,
  assertArrayData,
  assertAvatarUploadData,
  assertObjectData,
  flattenTree,
  formatDateTime,
  getDictLabel,
  parseStrEmpty,
  resolveTableTotal,
  stripHtml,
  tansParams,
  toDictOptions
} from '../../src/utils/helpers';

type FileSystemWriteOptions = {
  filePath: string;
  data: ArrayBuffer;
  success?: () => void;
  fail?: (error: unknown) => void;
};

type MockFileSystemManager = {
  writeFile: (options: FileSystemWriteOptions) => void;
};

type WxRuntimeShape = {
  wx?: {
    env?: {
      USER_DATA_PATH?: string;
    };
  };
};

const base64ToArrayBufferMock = Taro.base64ToArrayBuffer as unknown as MockInstance<[string], ArrayBuffer>;
const getFileSystemManagerMock = Taro.getFileSystemManager as unknown as MockInstance<[], MockFileSystemManager>;

describe('helpers', () => {
  it('parseStrEmpty should normalize nullable values', () => {
    expect(parseStrEmpty(undefined)).toBe('');
    expect(parseStrEmpty(null)).toBe('');
    expect(parseStrEmpty('undefined')).toBe('');
    expect(parseStrEmpty('null')).toBe('');
    expect(parseStrEmpty(42)).toBe('42');
  });

  it('tansParams should serialize primitive and nested values', () => {
    const query = tansParams({
      pageNum: 1,
      empty: '',
      filters: {
        status: '0',
        dept: 12,
        ignored: ''
      }
    });

    expect(query).toContain('pageNum=1');
    expect(query).toContain('filters%5Bstatus%5D=0');
    expect(query).toContain('filters%5Bdept%5D=12');
    expect(query).not.toContain('empty=');
    expect(query).not.toContain('ignored=');
  });

  it('stripHtml should remove tags and normalize spaces', () => {
    expect(stripHtml('<p> hello <b>world</b> </p>')).toBe('hello world');
    expect(stripHtml('')).toBe('');
  });

  it('formatDateTime should format valid dates and keep invalid input', () => {
    expect(formatDateTime('2026-04-07 08:09:10')).toBe('2026-04-07 08:09');
    expect(formatDateTime(new Date('2026-04-07T08:09:10Z')).startsWith('2026-04-07')).toBe(true);
    expect(formatDateTime(1712477350000).length).toBe(16);
    expect(formatDateTime('invalid-date')).toBe('invalid-date');
    expect(formatDateTime(undefined)).toBe('');
  });

  it('asCaptchaImage should return empty string when image is missing', async () => {
    await expect(asCaptchaImage(undefined)).resolves.toBe('');
  });

  it('asCaptchaImage should materialize to user data path in weapp runtime', async () => {
    base64ToArrayBufferMock.mockImplementation((value: string) => new TextEncoder().encode(value).buffer);
    getFileSystemManagerMock.mockReturnValue({
      writeFile: ({ success }: { success?: () => void }) => {
        success?.();
      }
    });

    const result = await asCaptchaImage('YWJjZA==', 'qa/a?1');

    expect(result).toBe('/tmp/captcha-qaa1.gif');
  });

  it('asCaptchaImage should keep data URL and fallback cache key to latest', async () => {
    base64ToArrayBufferMock.mockImplementation((value: string) => new TextEncoder().encode(value).buffer);
    getFileSystemManagerMock.mockReturnValue({
      writeFile: ({ success }: { success?: () => void }) => {
        success?.();
      }
    });

    const result = await asCaptchaImage('data:image/gif;base64,YWJj', '***');

    expect(result).toBe('/tmp/captcha-latest.gif');
  });

  it('asCaptchaImage should use latest cache key when cacheKey is undefined', async () => {
    base64ToArrayBufferMock.mockImplementation((value: string) => new TextEncoder().encode(value).buffer);
    getFileSystemManagerMock.mockReturnValue({
      writeFile: ({ success }: { success?: () => void }) => {
        success?.();
      }
    });

    const result = await asCaptchaImage('YWJjZA==');

    expect(result).toBe('/tmp/captcha-latest.gif');
  });

  it('asCaptchaImage should fallback to data URL when write file fails', async () => {
    const warnSpy = vi.spyOn(console, 'warn').mockImplementation(() => {});
    getFileSystemManagerMock.mockReturnValue({
      writeFile: ({ fail }: { fail?: (error: unknown) => void }) => {
        fail?.(new Error('write-failed'));
      }
    });

    const result = await asCaptchaImage('raw-base64', 'captcha-key');

    expect(result).toBe('data:image/gif;base64,raw-base64');
    expect(warnSpy).toHaveBeenCalledTimes(1);
    warnSpy.mockRestore();
  });

  it('asCaptchaImage should fallback when wx user data path is missing', async () => {
    const runtime = globalThis as WxRuntimeShape;
    const originalWx = runtime.wx;
    runtime.wx = {};

    const result = await asCaptchaImage('raw-base64-no-path', 'cache-key');

    expect(result).toBe('data:image/gif;base64,raw-base64-no-path');
    runtime.wx = originalWx;
  });

  it('toDictOptions and getDictLabel should map labels correctly', () => {
    const options = toDictOptions([
      { dictLabel: '正常', dictValue: '0' },
      { dictLabel: '停用', dictValue: '1' }
    ]);

    expect(options).toEqual([
      { label: '正常', value: '0', cssClass: undefined, listClass: undefined },
      { label: '停用', value: '1', cssClass: undefined, listClass: undefined }
    ]);
    expect(getDictLabel(options, '1')).toBe('停用');
    expect(getDictLabel(options, 'x')).toBe('x');
    expect(getDictLabel(options, undefined)).toBe('');
    expect(() => toDictOptions(undefined as unknown as [])).toThrow('字典响应 data 必须是数组');
  });

  it('flattenTree and resolveTableTotal should work for list responses', () => {
    const flat = flattenTree([
      {
        id: 1,
        label: 'A',
        children: [{ id: 2, label: 'B', children: [] }]
      }
    ]);

    expect(flat.map((item) => `${item.id}:${item._depth}`)).toEqual(['1:0', '2:1']);
    const responseWithTotal: TableResponse<number> = { code: 200, rows: [1, 2, 3], total: 9 };
    expect(resolveTableTotal(responseWithTotal)).toBe(9);
    expect(() => flattenTree(undefined as unknown as [])).toThrow('树形列表响应 data 必须是数组');
  });

  it('assertArrayData and assertObjectData should reject malformed response data', () => {
    const arrayData = [{ id: 1 }];
    const objectData = { id: 1 };

    expect(assertArrayData(arrayData, '列表响应 data')).toBe(arrayData);
    expect(assertObjectData(objectData, '详情响应 data')).toBe(objectData);
    expect(() => assertArrayData(undefined as unknown as [], '列表响应 data')).toThrow('列表响应 data 必须是数组');
    expect(() => assertObjectData(undefined as unknown as object, '详情响应 data')).toThrow('详情响应 data 必须是对象');
  });

  it('assertAvatarUploadData should reject missing avatar url', () => {
    expect(assertAvatarUploadData({ imgUrl: 'https://cdn.example.com/avatar.png' })).toEqual({ imgUrl: 'https://cdn.example.com/avatar.png' });
    expect(() => assertAvatarUploadData({})).toThrow('头像上传响应 data.imgUrl 必须是字符串');
    expect(() => assertAvatarUploadData({ imgUrl: '' })).toThrow('头像上传响应 data.imgUrl 不能为空');
  });
});
