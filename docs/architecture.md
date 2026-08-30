# Architecture

## 목표

서버 자원 감시와 Application 관제를 하나의 운영 흐름으로 연결하고, 공통 설정은 Template로 표준화하면서 환경별 차이는 Macro로 분리하는 구조를 목표로 했습니다.

## 데이터 흐름

```text
Monitoring Target
 Linux / AIX / Windows
          │
          ▼
      Zabbix Agent
          │
          ▼
      Zabbix Server
          │
   ┌──────┼──────────┐
   │      │          │
  Item   LLD    Preprocessing
   │      │          │
   └──────┼──────────┘
          ▼
    Trigger / Tag
          │
          ▼
        Action
   ┌──────┴──────┐
   │             │
 Alert      Remote Action
                  │
                  ▼
           State Validation
```

## 설계 원칙

- OS 공통 설정은 상위 Template에서 관리
- 서비스별 차이는 업무 Template와 User Macro로 분리
- 반복 항목은 LLD Prototype으로 생성
- Host별 개별 Item/Trigger 생성을 최소화
- 자동조치는 Trigger Tag와 Maintenance 상태를 함께 확인
- 원격조치 후 실제 Process/Service 상태를 재확인

## 비공개 처리 기준

공개 포트폴리오에는 실제 Hostname, IP, Port, 계정, 내부 경로, 네트워크 정책, 운영 일정, 비용 및 자산 규모를 포함하지 않습니다.
