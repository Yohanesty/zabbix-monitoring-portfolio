# Production Validation Checklist

운영 적용 전 구조와 안전장치를 검증하기 위한 체크리스트입니다.

## Agent

- [ ] Linux/AIX/Windows Agent 상태 확인
- [ ] Active/Passive 통신 확인
- [ ] 필요한 방화벽 정책 확인

## LLD / Item / Trigger

- [ ] Process LLD JSON 문법 검증
- [ ] Log LLD JSON 문법 검증
- [ ] JMX LLD JSON 문법 검증
- [ ] JSON 파싱 후 실제 Macro 값 확인
- [ ] Discovery Rule Test
- [ ] Item Prototype 생성 확인
- [ ] Trigger Prototype 생성 확인
- [ ] Macro 상속 및 Override 확인

## Log Monitoring

- [ ] `logrt[]` filename 정규식 동작 확인
- [ ] ERROR / Exception 패턴 검출
- [ ] 제외 패턴 / 전처리 동작
- [ ] Log Rotation 이후 연속 감시

## Process / Auto-Recovery

- [ ] Allow-list 대상만 원격 실행 가능
- [ ] Allow-list 외 서비스 실행 거부
- [ ] Linux/AIX Start 후 실제 Running 확인
- [ ] Linux/AIX Stop 후 실제 Stopped 확인
- [ ] Windows Start/Stop/Restart 상태 전이
- [ ] Timeout 시 현재 상태와 오류 메시지 확인
- [ ] OS별 Action 분기
- [ ] `autostart=false` 대상 자동조치 제외
- [ ] 다른 OS용 Action 중복 실행 방지

## Maintenance

- [ ] Maintenance 중 데이터 수집 유지
- [ ] Maintenance 중 Alert 억제
- [ ] Maintenance 중 자동조치 억제
- [ ] 종료 후 감시 / Action 정상 복귀

## 운영 품질

- [ ] 동일 이벤트 반복 시 Alert Storm 여부
- [ ] Severity / Tag 기준 검토
- [ ] 장애 복구 후 Problem Close 확인
- [ ] Dashboard 주요 상태 표시 확인

## Security

- [ ] 운영 IP / 계정 / 비밀번호 / Private Key 없음
- [ ] 실행계정 최소권한
- [ ] `.gitignore` 민감 파일 패턴 확인
- [ ] 스크립트 Credential 하드코딩 없음
