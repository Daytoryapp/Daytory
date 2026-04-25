import os
import subprocess
from openai import OpenAI

client = OpenAI(api_key=os.environ["OPENAI_API_KEY"])

pr_title = os.getenv("PR_TITLE", "")
pr_body = os.getenv("PR_BODY", "")
pr_number = os.getenv("PR_NUMBER")
repo = os.getenv("REPO")

with open("pr_diff.txt", "r", encoding="utf-8", errors="ignore") as f:
    diff = f.read()

diff = diff[:40000]

prompt = f"""너는 Flutter 앱 프로젝트의 시니어 코드리뷰어야.
이 PR은 데이트 기록 앱 Daytory의 변경사항이야.

아래 PR 제목, 기존 설명, diff를 보고 한국어로 리뷰해줘.

## 🔍 AI PR 요약
- 변경 목적
- 주요 변경 파일/기능
- 사용자 영향

## 📋 코드 리뷰
### ✅ 잘된 점
### ⚠️ 확인이 필요한 점
- 버그 가능성
- Flutter/Riverpod 구조 문제
- 상태관리 문제
- UI/UX 문제
- 보안/개인정보 문제
- iOS/Android 빌드 이슈

## 💡 개선 제안
우선순위 높은 것부터 제안해줘.

## 🧪 테스트 체크리스트
직접 확인해야 할 항목들

PR 제목:
{pr_title}

기존 PR 설명:
{pr_body}

Diff:
{diff}
"""

response = client.responses.create(
    model="gpt-4.1-mini",
    input=prompt,
    max_output_tokens=2048,
)

review_text = response.output_text

comment_file = "ai_review_comment.md"
with open(comment_file, "w", encoding="utf-8") as f:
    f.write("<!-- AI PR Review by OpenAI -->\n")
    f.write(review_text)

subprocess.run(
    ["gh", "pr", "comment", pr_number, "--repo", repo, "--body-file", comment_file],
    check=True,
    env={**os.environ, "GH_TOKEN": os.environ["GH_TOKEN"]},
)