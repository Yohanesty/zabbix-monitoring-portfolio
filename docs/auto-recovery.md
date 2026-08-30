# Auto-Recovery & Maintenance

## 장애 대응 흐름

```text
Problem
  │
  ▼
Trigger
  │
  ▼
Tag / 대상 조건 확인
  │
  ▼
Maintenance 상태 확인
  │
  ▼
Allow-list 검증
  │
  ▼
Start / Stop / Restart
  │
  ▼
실제 Process / Service 상태 확인
  │
  ▼
Success / Failure
```

## 핵심 안전장치

- 자동조치 대상은 명시적 Allow-list로 제한
- Linux/AIX와 Windows Action 분리
- `autostart=true` 등 Trigger Tag로 대상 제한
- Maintenance 중 자동조치 억제 조건 명시
- 실행계정은 최소권한 원칙 적용
- Credential / Private Key 하드코딩 금지
- Command 실행 성공 여부와 실제 상태 전이를 별도로 확인
- Timeout 발생 시 현재 상태를 확인한 뒤 비정상 종료코드 반환

## Maintenance

운영 작업 시간에는 데이터 수집은 유지하면서 불필요한 Alert와 원격조치를 억제하는 방향으로 설계했습니다.

Remote Command가 Maintenance 상태만으로 자동 차단된다고 가정하지 않고, Action Condition에서 Suppression 상태를 명시적으로 확인하는 방식을 사용합니다.

## 실패 처리

자동재기동은 성공만 가정하지 않습니다.

- Start script 실행 실패
- Stop script 실행 실패
- Timeout
- 서비스 상태 전이 실패
- Allow-list 외 대상
- 존재하지 않는 Service

각 상황을 구분할 수 있도록 종료코드와 오류 메시지를 반환하도록 예제를 구성했습니다.
