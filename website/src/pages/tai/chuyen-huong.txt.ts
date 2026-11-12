// Danh sách chuyển hướng /tai/<ma> -> tệp của bản mới nhất, định dạng _redirects của Cloudflare. scripts/tao-chuyen-huong.mjs
// chuyển tệp này thành dist/_redirects sau khi build (Astro không sinh được tệp bắt đầu bằng "_").
import { banMoiNhat, goiNhanh } from '../../lib/noi-dung';

export async function GET() {
  const dong = goiNhanh(await banMoiNhat()).map((n) => `/tai/${n.ma} ${n.goi.url} 302`);
  return new Response(dong.join('\n') + '\n', { headers: { 'Content-Type': 'text/plain; charset=utf-8' } });
}
