"""
Daystory App Icon Generator  v6 - final
1024x1024px  iOS/Android app icon
"""

import math
from PIL import Image, ImageDraw

SIZE   = 1024
OUTPUT = "/Users/jaemin/Desktop/date_app/assets/images/app_logo_1024.png"
CX     = SIZE // 2
CY     = SIZE // 2

# ---------------------------------------------------------------------------
# 1. 대각선 그라데이션 배경  #FF5A8A → #C94079
# ---------------------------------------------------------------------------
COLOR_START = (255, 90,  138)
COLOR_END   = (201, 64,  121)

img    = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
pixels = img.load()
for y in range(SIZE):
    for x in range(SIZE):
        t = (x + y) / (2.0 * (SIZE - 1))
        pixels[x, y] = (
            int(COLOR_START[0] + (COLOR_END[0] - COLOR_START[0]) * t),
            int(COLOR_START[1] + (COLOR_END[1] - COLOR_START[1]) * t),
            int(COLOR_START[2] + (COLOR_END[2] - COLOR_START[2]) * t),
            255,
        )

# ---------------------------------------------------------------------------
# 2. 둥근 모서리 마스크
# ---------------------------------------------------------------------------
mask = Image.new("L", (SIZE, SIZE), 0)
ImageDraw.Draw(mask).rounded_rectangle([0, 0, SIZE-1, SIZE-1], radius=160, fill=255)
img.putalpha(mask)
draw = ImageDraw.Draw(img)

WHITE = (255, 255, 255, 255)

# ---------------------------------------------------------------------------
# 아이콘 치수 설계
# 전체 아이콘(하트 상단 ~ 책 하단) 높이를 약 560px로 설정
# 화면 중앙(512)에 수직 중앙 정렬
#
#  하트 상단  = ICON_TOP
#  책 하단    = ICON_BOTTOM
#  ICON_TOP ~ ICON_BOTTOM = 560px
#  세로 중심  = (ICON_TOP + ICON_BOTTOM) / 2 = CY (512)
# ---------------------------------------------------------------------------
HEART_SIZE  = 128
BOOK_WIDTH  = 225
BOOK_HEIGHT = 255

# 아이콘 절대 좌표 직접 지정 (1024 기준)
# 책 상단 ~ 책 하단: 430 ~ 750  (높이 320)
# 하트 상단: 250, 하트 하단은 책 상단 근처
BOOK_TOP    = 435
BOOK_BOTTOM = 745
ICON_TOP    = 250
ICON_BOTTOM = BOOK_BOTTOM

BOOK_CY  = (BOOK_TOP + BOOK_BOTTOM) // 2
BH       = BOOK_BOTTOM - BOOK_TOP

# 하트 중심: 하트 하단(≈HEART_CY + HEART_SIZE*0.82)이 BOOK_TOP + 20
HEART_CY = BOOK_TOP + 20 - int(HEART_SIZE * 0.82)

# ---------------------------------------------------------------------------
# 3. 열린 책
# ---------------------------------------------------------------------------
TOP  = BOOK_TOP
BOTTOM = BOOK_BOTTOM
BW   = BOOK_WIDTH

# 왼쪽 페이지
left_page = [
    (CX,              TOP),
    (CX - BW * 1//3,  TOP - 14),
    (CX - BW,         TOP + 30),
    (CX - BW,         BOTTOM - 26),
    (CX - BW * 1//3,  BOTTOM + 12),
    (CX,              BOTTOM),
]

# 오른쪽 페이지
right_page = [
    (CX,              TOP),
    (CX + BW * 1//3,  TOP - 14),
    (CX + BW,         TOP + 30),
    (CX + BW,         BOTTOM - 26),
    (CX + BW * 1//3,  BOTTOM + 12),
    (CX,              BOTTOM),
]

draw.polygon(left_page,  fill=(255, 255, 255, 245))
draw.polygon(right_page, fill=(255, 255, 255, 245))
draw.polygon(left_page,  outline=WHITE, width=11)
draw.polygon(right_page, outline=WHITE, width=11)

# 척추
draw.line([(CX, TOP + 5), (CX, BOTTOM - 5)], fill=WHITE, width=16)

# 상단 펼침 호
draw.arc(
    [CX - BW + 44, TOP - 22, CX + BW - 44, TOP + 18],
    start=208, end=332, fill=WHITE, width=11,
)

# ---------------------------------------------------------------------------
# 4. 책 줄
# ---------------------------------------------------------------------------
LINE_COLOR = (255, 110, 155, 172)
PAD_X    = 30
START_Y  = TOP + 58
LINE_GAP = 52
N_LINES  = 4

for i in range(N_LINES):
    ly = START_Y + i * LINE_GAP
    draw.line(
        [(CX - BW + PAD_X + 14, ly), (CX - PAD_X - 10, ly)],
        fill=LINE_COLOR, width=7,
    )
    draw.line(
        [(CX + PAD_X + 10, ly), (CX + BW - PAD_X - 14, ly)],
        fill=LINE_COLOR, width=7,
    )

# ---------------------------------------------------------------------------
# 5. 하트
# ---------------------------------------------------------------------------
def heart_polygon(cx, cy, size, n=400):
    pts = []
    for k in range(n):
        a  = 2 * math.pi * k / n
        hx = 16 * (math.sin(a) ** 3)
        hy = -(13*math.cos(a) - 5*math.cos(2*a)
               - 2*math.cos(3*a) - math.cos(4*a))
        pts.append((cx + hx * size / 17.0, cy + hy * size / 17.0))
    return pts

# 그림자
draw.polygon(heart_polygon(CX+6, HEART_CY+10, HEART_SIZE), fill=(145, 20, 62, 70))
# 흰 하트
draw.polygon(heart_polygon(CX, HEART_CY, HEART_SIZE), fill=WHITE)

# 하트 안 핑크 줄
STRIPE = (255, 105, 150, 232)
sw = int(HEART_SIZE * 0.48)
draw.line([(CX-sw, HEART_CY-18), (CX+sw, HEART_CY-18)], fill=STRIPE, width=9)
draw.line([(CX-sw*3//5, HEART_CY+14), (CX+sw*3//5, HEART_CY+14)],
          fill=STRIPE, width=9)

# ---------------------------------------------------------------------------
# 6. 저장
# ---------------------------------------------------------------------------
img.save(OUTPUT, "PNG")
print(f"Saved : {OUTPUT}  {img.size}")
print(f"ICON_TOP={ICON_TOP}  BOOK_TOP={BOOK_TOP}  HEART_CY={HEART_CY}")

thumb = img.copy()
thumb.thumbnail((128, 128), Image.LANCZOS)
thumb.save(OUTPUT.replace("_1024.png", "_128.png"), "PNG")
print("Thumb saved.")
