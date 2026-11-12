// Sinh dist/_redirects từ dist/tai/chuyen-huong.txt (xem src/pages/tai/chuyen-huong.txt.ts) rồi xóa tệp trung gian.
// Chỉ nhận dòng "/tai/<ma> https://github.com/tsudev-org/lotus-share/releases/download/... 302": không để lọt chuyển
// hướng mở tới tên miền khác.
import { existsSync, readFileSync, rmdirSync, rmSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const dist = join(dirname(fileURLToPath(import.meta.url)), '../dist');
const nguon = join(dist, 'tai/chuyen-huong.txt');
if (!existsSync(nguon)) {
  console.error('Thiếu dist/tai/chuyen-huong.txt');
  process.exit(1);
}
const mau = /^\/tai\/[a-z0-9-]+ https:\/\/github\.com\/tsudev-org\/lotus-share\/releases\/download\/[A-Za-z0-9._-]+\/[A-Za-z0-9._-]+ 302$/;
const dong = readFileSync(nguon, 'utf8').split('\n').filter(Boolean);
const sai = dong.filter((d) => !mau.test(d));
if (sai.length) {
  console.error(`Dòng chuyển hướng không hợp lệ:\n${sai.join('\n')}`);
  process.exit(1);
}
writeFileSync(join(dist, '_redirects'), dong.join('\n') + (dong.length ? '\n' : ''));
rmSync(nguon);
try { rmdirSync(dirname(nguon)); } catch { /* thư mục còn tệp khác */ }
console.log(`_redirects: ${dong.length} đường dẫn tải nhanh (${dong.map((d) => d.split(' ')[0]).join(', ') || 'chưa có bản phát hành'})`);
