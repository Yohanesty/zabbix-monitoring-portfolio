# Monitoring Design

## 1. Server Resource

- CPU
- Memory
- Disk
- Network
- Agent 상태 / Uptime

## 2. Process / Service

- Process 존재 여부
- Port Listen 여부
- OS Service 상태
- Trigger Tag 기반 Action 분기

## 3. Log Monitoring

- `logrt` 기반 Rotation Log 감시
- ERROR / Exception / 업무 오류 패턴 탐지
- 전처리 및 제외 패턴 적용
- 경로와 Pattern은 Macro로 변수화

`logrt[]`의 filename은 shell wildcard가 아니라 정규식으로 처리하므로 JSON Escape와 실제 Zabbix 전달값을 분리해 검증합니다.

예:

```text
/opt/apps/sample-app/logs/^error\.log.*$
```

## 4. JMX

- JVM Heap
- Thread
- Runtime
- WAS/JMX 상태
- 반복 Endpoint는 LLD Prototype 적용 가능

## 5. LLD

반복되는 감시 구성을 Discovery JSON과 Prototype으로 생성합니다.

주요 대상:

- Process
- Log
- JMX

## 6. UserParameter

표준 Agent Item으로 수집하기 어려운 항목은 UserParameter 또는 Custom Item으로 확장할 수 있도록 설계했습니다.

예:

- GPU
- DB Custom Metric
- Container / Kubernetes Metric
- 업무별 Custom Metric
