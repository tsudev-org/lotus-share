// Hình học hoạ tiết chữ ký `canh-sen` (tsudev-standards v5.0.0, DESIGN_SYSTEM mục 1.2.4): bảy cánh sen tạo bởi các
// điểm nối nhau. GIỐNG HỆT `app/lib/widget/canh_sen_motif.dart` và `scripts/brand_assets.py` (og-image) - đổi một nơi
// thì đổi cả ba. Gốc (0, 0) ở đáy giữa, đơn vị = chiều dài cánh giữa, ngọn cánh giữa ở (0, -1).

export type Diem = [number, number];

export const SO_CANH = 7;
export const SO_BUOC = 5;

export function canhSen(): { trai: Diem[]; phai: Diem[] }[] {
  const ket: { trai: Diem[]; phai: Diem[] }[] = [];
  for (let k = 0; k < SO_CANH; k++) {
    const lech = k - (SO_CANH - 1) / 2;
    const goc = -Math.PI / 2 + (lech * 22 * Math.PI) / 180;
    const dai = 1 - 0.12 * Math.abs(lech);
    const [dx, dy] = [Math.cos(goc), Math.sin(goc)];
    const [nx, ny] = [-dy, dx];
    const trai: Diem[] = [];
    const phai: Diem[] = [];
    for (let i = 0; i <= SO_BUOC; i++) {
      const t = i / SO_BUOC;
      const w = 0.26 * dai * Math.sin(Math.PI * t);
      const [ax, ay] = [dx * t * dai, dy * t * dai];
      trai.push([ax - nx * w, ay - ny * w]);
      phai.push([ax + nx * w, ay + ny * w]);
    }
    ket.push({ trai, phai });
  }
  return ket;
}
