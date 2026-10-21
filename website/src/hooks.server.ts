import type { Handle } from '@sveltejs/kit/hooks';

// 预渲染时写入正确的 HTML 语言，无需等待客户端执行脚本。
export const handle: Handle = async ({ event, resolve }) => {
  const segment = event.url.pathname.split('/').filter(Boolean).at(-1);
  const language = segment === 'zh' ? 'zh-CN' : segment === 'ja' ? 'ja' : 'en';
  return resolve(event, {
    transformPageChunk: ({ html }) => html.replace('%lang%', language)
  });
};
