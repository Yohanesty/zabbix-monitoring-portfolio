# Zabbix Monitoring & Operations Portfolio

Zabbix 6.4 기반 서버·Application 통합 모니터링과 운영 자동화 설계 경험을 정리한 **Engineering Case Study**입니다.

> 실제 Enterprise 운영 경험을 기반으로 하되 회사명, 시스템명, 서버 규모, IP, Port, 계정, 내부 경로, 운영 일정 및 비용 정보는 공개하지 않거나 일반화했습니다.

## 1. Problem

기존 환경에서는 서버와 Application별 감시 구성이 분산되어 있어 신규 시스템 추가 시 반복 설정이 필요했고, 서버 자원뿐 아니라 Process, Log, JVM 등 Application 관점의 운영 가시성을 확대할 필요가 있었습니다.

주요 해결 과제는 다음과 같았습니다.

- Linux / AIX / Windows 환경의 모니터링 기준 표준화
- Host별 반복 설정 최소화
- Process / Log / JVM까지 Application Monitoring 범위 확대
- 장애 발생 시 안전한 조건부 자동조치 구조 설계
- Maintenance 및 운영 변경 중 불필요한 알림·오조치 방지
- 운영 담당자가 지속적으로 확장 가능한 Template 구조 구성

## 2. Architecture

```text
Linux / AIX / Windows
        │
        ▼
   Zabbix Agent
        │
        ▼
   Zabbix Server
        │
 ┌──────┼────────────┐
 │      │            │
Item   LLD      Preprocessing
 │      │            │
 └──────┼────────────┘
        ▼
  Trigger / Tag
        │
        ▼
      Action
   ┌────┴─────┐
   │          │
 Alert   Remote Action
              │
              ▼
       State Validation
```

상세 설계는 [Architecture](docs/architecture.md)를 참고하세요.

## 3. Key Design Decisions

### Template / Macro 기반 표준화

공통 감시 기준은 Template로 관리하고, 환경별 차이는 User Macro로 분리했습니다. Host마다 Item과 Trigger를 개별 관리하는 방식을 최소화하여 공통 변경을 상위 Template에서 반영할 수 있도록 구성했습니다.

### Low-Level Discovery

Process, Log, JMX처럼 반복되는 감시 항목은 LLD와 Prototype 기반으로 생성하도록 설계했습니다.

- Process Discovery
- Rotated Log Discovery
- JMX Endpoint Discovery

예제는 [`examples/`](examples/)에서 확인할 수 있습니다.

### Application Monitoring 확대

단순 서버 Resource Monitoring을 넘어 다음 영역까지 감시 범위를 확장했습니다.

- CPU / Memory / Disk / Network
- Process / Service / Port
- Rotated Log (`logrt`)
- JVM / JMX
- UserParameter 기반 Custom Metric

상세 내용은 [Monitoring Design](docs/monitoring-design.md)을 참고하세요.

## 4. Safe Auto-Recovery

자동조치는 단순한 `Trigger → Command` 구조로 두지 않고 실행 전후 안전장치를 포함하도록 설계했습니다.

```text
Trigger
   │
   ▼
Tag / 대상 여부 확인
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
Process / Service 상태 재확인
   │
   ▼
Success / Failure
```

주요 안전장치:

- Explicit allow-list
- OS별 Action 분리
- 최소권한 실행계정 적용 원칙
- Maintenance 중 자동조치 억제 조건
- Command 결과 코드 확인
- 실행 이후 실제 Process / Service 상태 재검증
- Timeout 및 실패 상태 처리

Linux/AIX와 Windows 예제 스크립트는 [`scripts/`](scripts/)에서 확인할 수 있습니다.

## 5. Production Validation

운영 반영 전 다음 항목을 확인할 수 있도록 검증 체크리스트를 구성했습니다.

- Agent 통신
- LLD JSON Parsing
- Item / Trigger Prototype 생성
- Macro 상속 및 Override
- `logrt` 정규식과 Rotation 동작
- Auto-recovery allow-list
- OS별 Action 분기
- Maintenance suppression
- Maintenance 종료 후 감시/Action 복귀
- Alert Storm 여부
- Credential / Key 노출 여부

상세 체크리스트: [Production Validation](docs/production-validation.md)

## 6. Result

- 분산되어 있던 Server / Application 감시 기준을 Template 중심으로 표준화
- Process / Log / JMX 영역까지 Application Monitoring 범위 확대
- LLD 기반 반복 설정 자동화 구조 구성
- 조건부 자동조치와 실행 후 상태 검증을 포함한 운영 안전장치 설계
- 오픈소스 기반으로 감시 대상 확장 시 추가 라이선스 비용 없이 확장 가능한 기반 확보
- 운영·트러블슈팅 경험을 문서와 예제 코드 형태의 기술자산으로 정리

> MTTD / MTTR / 자동복구율 등 정량 KPI는 충분한 운영 데이터가 확보되기 전에는 성과로 주장하지 않습니다.

## 7. Repository Structure

```text
.
├── README.md
├── .gitignore
├── docs/
│   ├── architecture.md
│   ├── monitoring-design.md
│   ├── auto-recovery.md
│   └── production-validation.md
├── scripts/
│   ├── linux/zabbix_remote_app.ksh
│   └── windows/zabbix_remote_service.ps1
└── examples/
    ├── process_monitor_lld.json
    ├── log_monitor_lld.json
    └── jmx_monitor_lld.json
```

## Security Notice

이 저장소는 공개 포트폴리오용으로 일반화한 예제만 포함합니다.

다음 정보는 포함하지 않습니다.

- Production IP / Hostname / Domain
- 계정 / 비밀번호 / Private Key
- 실제 서비스명과 내부 시스템명
- 내부 서버 경로
- 상세 Network 구성
- 실제 운영 일정
- 내부 비용 및 자산 규모
