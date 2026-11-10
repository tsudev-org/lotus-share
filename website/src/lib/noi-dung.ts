// Nội dung trang lấy trực tiếp từ các tệp .md của repo (một nguồn duy nhất cho tài liệu) và từ GitHub Releases lúc build.
import { readFileSync } from 'node:fs';
import { dirname, join, normalize } from 'node:path';
import { Marked } from 'marked';

export const SAN_PHAM = 'tsudev-lotus';
export const REPO = 'tsudev-org/tsudev-lotus';
export const REPO_URL = `https://github.com/${REPO}`;
export const RELEASES_URL = `${REPO_URL}/releases/latest`;
export const UPSTREAM_URL = 'https://github.com/localsend/localsend';
export const SITE = 'https://lotus.tsudev.com';

// Gốc repo: build chạy trong thư mục website/ (npm run build), nên gốc là thư mục cha.
const GOC = normalize(join(process.cwd(), '..'));

/** Tệp .md của repo -> đường dẫn trên website. Tệp khác của repo trỏ về GitHub. */
export const TRANG_MD: Record<string, string> = {
  'README.md': '/',
  'SECURITY.md': '/bao-mat/',
  'docs/vi/KIEN-TRUC-BAO-MAT.md': '/bao-mat/kien-truc/',
  'CHANGELOG.md': '/nhat-ky/',
  'NOTICE': '/ban-quyen/#thong-bao-sua-doi',
  'LICENSE': '/ban-quyen/#giay-phep-apache',
};

export function docTep(duongDan: string): string {
  return readFileSync(join(GOC, duongDan), 'utf8').replace(/^﻿/, '');
}

/** Slug kiểu GitHub: chữ thường, bỏ dấu câu, khoảng trắng -> "-" (giữ chữ có dấu tiếng Việt). */
export function slug(text: string): string {
  // Bỏ thẻ HTML lặp tới khi hết (một lượt có thể để lại thẻ ghép lồng như "<scr<b>ipt>")
  let s = text.toLowerCase().trim();
  for (let truoc = ''; truoc !== s; ) {
    truoc = s;
    s = s.replace(/<[^<>]*>/g, '');
  }
  return s.replace(/&[a-z#0-9]+;/g, '').replace(/[^\p{L}\p{N}\s_-]/gu, '').replace(/\s/g, '-');
}

function viTriLienKet(href: string, tepMd: string): string {
  if (/^(https?:|mailto:|#)/.test(href)) return href;
  const [duong, neo] = href.split('#', 2);
  const tuyetDoi = normalize(join(dirname(tepMd), decodeURI(duong))).replace(/\\/g, '/').replace(/\/$/, '');
  const trang = TRANG_MD[tuyetDoi];
  if (trang) return neo ? `${trang.split('#')[0]}#${neo}` : trang;
  const loai = /\.[A-Za-z0-9_-]+$/.test(tuyetDoi) ? 'blob' : 'tree';
  return `${REPO_URL}/${loai}/main/${encodeURI(tuyetDoi)}${neo ? '#' + neo : ''}`;
}

/** Liên kết ngoài = http(s) tới host khác trang này (so hostname, không so chuỗi đầu: "lotus.tsudev.com.evil.example" là ngoài). */
export function laNgoai(href: string): boolean {
  if (!/^https?:/i.test(href)) return false;
  try {
    return new URL(href).hostname.toLowerCase() !== new URL(SITE).hostname;
  } catch {
    return true;   // URL hỏng: coi là ngoài (thêm rel="noopener noreferrer")
  }
}

const thoat = (s: string) => s.replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/</g, '&lt;');

/** Chuyển Markdown của repo sang HTML: sửa liên kết tương đối, thêm id cho tiêu đề, rel cho liên kết ngoài. */
export function renderMd(tepMd: string, opts: { boTieuDeDau?: boolean; md?: string; haCap?: number } = {}): { html: string; tieuDe: string } {
  let md = opts.md ?? docTep(tepMd);
  // Bỏ chú thích HTML (khối <!-- update ... --> của CHANGELOG, ghi chú nội bộ): không hiển thị, không cần gửi đi.
  md = md.replace(/<!--[\s\S]*?-->/g, '');
  const tieuDe = md.match(/^#\s+(.+)$/m)?.[1]?.trim() ?? '';
  if (opts.boTieuDeDau) md = md.replace(/^#\s+.+\n/m, '');
  const haCap = opts.haCap ?? 0;   // hạ cấp tiêu đề khi ghép tài liệu vào giữa trang
  const marked = new Marked({ gfm: true });
  marked.use({
    renderer: {
      heading({ tokens, depth }) {
        const text = this.parser.parseInline(tokens);
        const d = Math.min(depth + haCap, 6);
        return `<h${d} id="${slug(text)}">${text}</h${d}>\n`;
      },
      link({ href, title, tokens }) {
        const text = this.parser.parseInline(tokens);
        const dich = viTriLienKet(href, tepMd);
        const ngoai = laNgoai(dich) ? ' target="_blank" rel="noopener noreferrer"' : '';
        return `<a href="${thoat(dich)}"${title ? ` title="${thoat(title)}"` : ''}${ngoai}>${text}</a>`;
      },
      image({ href, title, text }) {
        return `<img src="${thoat(viTriLienKet(href, tepMd))}" alt="${thoat(text)}"${title ? ` title="${thoat(title)}"` : ''} loading="lazy">`;
      },
    },
  });
  const html = (marked.parse(md, { async: false }) as string)
    .replace(/<table>/g, '<div class="bang" tabindex="0" role="region" aria-label="Bảng, cuộn ngang được"><table>')
    .replace(/<\/table>/g, '</table></div>')
    // Khối mã có thể cuộn ngang: cho nhận focus để cuộn bằng bàn phím (WCAG 2.1.1, axe scrollable-region-focusable)
    .replace(/<pre>/g, '<pre tabindex="0">')
    // Danh sách việc "- [ ]" của GFM ra ô chọn không nhãn (axe: label). Trang chỉ đọc: thay bằng ký hiệu + chữ ẩn.
    .replace(/<input checked="" disabled="" type="checkbox">/g, '<span aria-hidden="true">☑</span><span class="an-di">Đã xong:</span>')
    .replace(/<input disabled="" type="checkbox">/g, '<span aria-hidden="true">☐</span><span class="an-di">Chưa làm:</span>');
  return { html, tieuDe };
}

/** `soMuc` mục `## x.y.z` mới nhất của CHANGELOG (nhật ký của upstream, tiếng Anh). */
export function changelogMoiNhat(soMuc: number): string {
  const md = docTep('CHANGELOG.md');
  const dau = md.search(/^## \d/m);
  if (dau < 0) return '';
  return md.slice(dau).split(/^(?=## \d)/m).slice(0, soMuc).join('');
}

// ---------------------------------------------------------------------------------------------------------------
// Bản phát hành

export interface GoiTai { nenTang: string; ten: string; url: string; sha256: string; kichThuoc: number; loai: string }
export interface BanPhatHanh { tag: string; phienBan: string; ngay: string; url: string; goi: GoiTai[]; tepSums: { ten: string; url: string }[] }

/**
 * Nền tảng theo hậu tố tên tệp phát hành (cùng quy tắc đặt tên của workflow build_*.yml kế thừa từ LocalSend:
 * <tên>-<phiên bản>-<nền tảng>-<kiến trúc>.<đuôi>). Thứ tự = thứ tự hiển thị.
 */
export const NEN_TANG: { ma: string; ten: string; mau: RegExp }[] = [
  { ma: 'windows-x64', ten: 'Windows 10/11 (x64)', mau: /-windows-x86-64\.(exe|zip|msix)$/ },
  { ma: 'windows-arm64', ten: 'Windows 11 trên ARM (ARM64)', mau: /-windows-arm-64\.(exe|zip|msix)$/ },
  { ma: 'macos', ten: 'macOS 12+ (chip Apple và Intel)', mau: /\.dmg$/ },
  { ma: 'linux-x64', ten: 'Linux x64', mau: /-linux-x86-64\.(AppImage|deb|rpm|tar\.gz)$/ },
  { ma: 'linux-arm64', ten: 'Linux ARM64', mau: /-linux-arm-64\.(AppImage|deb|rpm|tar\.gz)$/ },
  { ma: 'android', ten: 'Android 5.0+', mau: /\.apk$/ },
  { ma: 'cli', ten: 'Dòng lệnh (CLI)', mau: /^tsudev-lotus-cli-/ },
];

function loaiGoi(ten: string): string {
  if (ten.endsWith('.exe')) return 'Bộ cài Windows';
  if (ten.endsWith('.msix')) return 'Gói MSIX';
  if (ten.endsWith('.zip')) return 'Bản di động (ZIP)';
  if (ten.endsWith('.dmg')) return 'Ảnh đĩa (DMG)';
  if (ten.endsWith('.AppImage')) return 'AppImage (chạy ngay, không cần cài)';
  if (ten.endsWith('.deb')) return 'Gói .deb (Debian, Ubuntu)';
  if (ten.endsWith('.rpm')) return 'Gói .rpm (Fedora, openSUSE)';
  if (ten.endsWith('.apk')) return ten.includes('universal') ? 'APK (mọi kiến trúc)' : `APK ${ten.match(/android-([^.]+)\.apk$/)?.[1] ?? ''}`;
  if (ten.includes('-cli-')) return ten.endsWith('.exe') ? 'CLI Windows' : 'CLI Linux';
  return 'Gói nén (tar.gz)';
}

let boNho: Promise<BanPhatHanh | null> | undefined;

/**
 * Bản phát hành mới nhất, lấy lúc build từ GitHub (SHA-256 từ các tệp *SHA256SUMS.txt).
 * Trả null khi repo chưa có bản phát hành nào (API trả 404): trang vẫn build và chỉ tới trang phát hành.
 * Lỗi mạng/API khác: dừng build, đừng đưa lên trang một danh sách tải sai.
 */
export function banMoiNhat(): Promise<BanPhatHanh | null> {
  boNho ??= (async () => {
    const headers: Record<string, string> = { Accept: 'application/vnd.github+json', 'User-Agent': 'tsudev-lotus-website' };
    if (process.env.GITHUB_TOKEN) headers.Authorization = `Bearer ${process.env.GITHUB_TOKEN}`;
    const res = await fetch(`https://api.github.com/repos/${REPO}/releases/latest`, { headers });
    if (res.status === 404) return null;
    if (!res.ok) throw new Error(`GitHub API ${res.status}`);
    const r = await res.json() as { tag_name: string; published_at: string; html_url: string; assets: { name: string; browser_download_url: string; size: number }[] };
    const bang = new Map<string, string>();
    const tepSums = r.assets.filter((a) => a.name.endsWith('SHA256SUMS.txt'));
    for (const s of tepSums) {
      const res2 = await fetch(s.browser_download_url);
      if (!res2.ok) throw new Error(`Tải ${s.name}: ${res2.status}`);
      for (const dong of (await res2.text()).split('\n')) {
        const m = dong.trim().match(/^([0-9a-fA-F]{64})\s+\*?(.+)$/);
        if (m) bang.set(m[2].trim(), m[1].toLowerCase());
      }
    }
    const goi: GoiTai[] = [];
    for (const nt of NEN_TANG) {
      for (const a of r.assets.filter((x) => nt.mau.test(x.name))) {
        goi.push({ nenTang: nt.ma, ten: a.name, url: a.browser_download_url, sha256: bang.get(a.name) ?? '', kichThuoc: a.size, loai: loaiGoi(a.name) });
      }
    }
    return {
      tag: r.tag_name,
      phienBan: r.tag_name.replace(/^v/, ''),
      ngay: r.published_at.slice(0, 10).split('-').reverse().join('/'),
      url: r.html_url,
      goi,
      tepSums: tepSums.map((s) => ({ ten: s.name, url: s.browser_download_url })),
    };
  })();
  return boNho;
}
