import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
// Firebase 서비스 계정 JSON 전체를 문자열로 저장한 환경변수
const FIREBASE_SERVICE_ACCOUNT = Deno.env.get('FIREBASE_SERVICE_ACCOUNT')!
const FIREBASE_PROJECT_ID = Deno.env.get('FIREBASE_PROJECT_ID')!

Deno.serve(async () => {
  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

  // Intl API로 KST 날짜를 정확하게 추출 (UTC 자정 경계 오류 방지)
  const now = new Date()
  const { month: todayM, day: todayD } = getKSTDateParts(now)
  const tomorrowUtc = new Date(now.getTime() + 24 * 60 * 60 * 1000)
  const { month: tomorrowM, day: tomorrowD } = getKSTDateParts(tomorrowUtc)
  const todayMMDD = `${todayM}-${todayD}`
  const tomorrowMMDD = `${tomorrowM}-${tomorrowD}`

  const { data: users, error } = await supabase
    .from('users')
    .select('kakao_id, anniversary, fcm_token')
    .not('fcm_token', 'is', null)
    .not('anniversary', 'is', null)

  if (error || !users) {
    return new Response(JSON.stringify({ error: error?.message }), { status: 500 })
  }

  const accessToken = await getFirebaseAccessToken()
  const results: string[] = []

  for (const user of users) {
    const mmdd = (user.anniversary as string).slice(5, 10) // "YYYY-MM-DD" → "MM-DD"

    if (mmdd === todayMMDD) {
      const anniversaryYear = new Date(user.anniversary as string).getFullYear()
      const years = new Date().getFullYear() - anniversaryYear
      const body = years > 0
        ? `오늘 ${years}주년이에요! 특별한 하루 보내세요 🎉`
        : '오늘 기념일이에요! 특별한 하루 보내세요 🎉'
      const ok = await sendFcm(supabase, accessToken, user.fcm_token, '기념일이에요 💕', body)
      if (ok) results.push(`[D-day] ${user.kakao_id}`)
    } else if (mmdd === tomorrowMMDD) {
      const ok = await sendFcm(
        supabase,
        accessToken,
        user.fcm_token,
        '내일이 기념일이에요 💝',
        '내일을 위한 특별한 계획을 세워보세요!',
      )
      if (ok) results.push(`[D-1] ${user.kakao_id}`)
    }
  }

  return new Response(JSON.stringify({ sent: results }), {
    headers: { 'Content-Type': 'application/json' },
  })
})

function getKSTDateParts(utcDate: Date): { month: string; day: string } {
  const formatter = new Intl.DateTimeFormat('en-CA', {
    timeZone: 'Asia/Seoul',
    month: '2-digit',
    day: '2-digit',
  })
  const parts = formatter.formatToParts(utcDate)
  const month = parts.find((p) => p.type === 'month')!.value
  const day = parts.find((p) => p.type === 'day')!.value
  return { month, day }
}

// base64url 인코딩 (JWT 표준: 패딩 제거, +→-, /→_)
function toBase64Url(input: string | Uint8Array): string {
  const str = typeof input === 'string'
    ? btoa(encodeURIComponent(input).replace(/%([0-9A-F]{2})/g, (_, p1) =>
        String.fromCharCode(parseInt(p1, 16))))
    : btoa(String.fromCharCode(...input))
  return str.replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '')
}

// FCM HTTP v1 API용 OAuth2 액세스 토큰 발급 (서비스 계정 JWT 방식)
async function getFirebaseAccessToken(): Promise<string> {
  const sa = JSON.parse(FIREBASE_SERVICE_ACCOUNT)
  const now = Math.floor(Date.now() / 1000)

  const header = toBase64Url(JSON.stringify({ alg: 'RS256', typ: 'JWT' }))
  const payload = toBase64Url(JSON.stringify({
    iss: sa.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: now + 3600,
  }))

  const signingInput = `${header}.${payload}`
  const privateKey = await importRsaPrivateKey(sa.private_key)
  const signatureBytes = await crypto.subtle.sign(
    { name: 'RSASSA-PKCS1-v1_5' },
    privateKey,
    new TextEncoder().encode(signingInput),
  )
  const signature = toBase64Url(new Uint8Array(signatureBytes))
  const jwt = `${signingInput}.${signature}`

  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  })
  const data = await res.json()
  return data.access_token as string
}

async function importRsaPrivateKey(pem: string): Promise<CryptoKey> {
  const pemContents = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, '')
    .replace(/-----END PRIVATE KEY-----/, '')
    .replace(/\n/g, '')
  const der = Uint8Array.from(atob(pemContents), (c) => c.charCodeAt(0))
  return crypto.subtle.importKey(
    'pkcs8',
    der.buffer,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  )
}

// FCM 전송 — 실패 시 false 반환, 토큰 만료(404)는 DB에서 제거
async function sendFcm(
  // deno-lint-ignore no-explicit-any
  supabase: any,
  accessToken: string,
  fcmToken: string,
  title: string,
  body: string,
): Promise<boolean> {
  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/messages:send`,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: {
          token: fcmToken,
          notification: { title, body },
          android: { priority: 'high' },
          apns: { payload: { aps: { sound: 'default' } } },
        },
      }),
    },
  )

  if (!res.ok) {
    const err = await res.json()
    console.error(`[FCM] send failed: ${JSON.stringify(err)}`)
    // 만료/무효 토큰은 DB에서 제거해 재발송 방지
    if (res.status === 404) {
      await supabase.from('users').update({ fcm_token: null }).eq('fcm_token', fcmToken)
    }
    return false
  }
  return true
}
