+++
title = "Designing Resilient Webhook Ingestion with FastAPI, Celery, and Redis"
date = '2026-09-12T21:00:00+05:30'
slug = "resilient-webhook-ingestion-fastapi-redis"
draft = false
author = "Siva Madhavan"
description = "How to build an idempotent, zero-data-loss webhook processing pipeline capable of swallowing massive external bursts without degrading internal database performance."
tags = ["Backend", "FastAPI", "Redis", "Celery", "Architecture", "Distributed Systems"]
categories = ["Backend"]
showToc = true
TocOpen = false
+++

Third-party webhooks from payment gateways (Stripe), communication providers (Twilio, RingCentral), or healthcare EHR integrations are notoriously unpredictable. Providers will retry aggressively during network blips, send duplicate payloads, or blast thousands of events within seconds during batch syncs.

If your webhook endpoint directly executes database queries or third-party downstream calls, your backend will quickly encounter connection exhaustion, cascading timeouts, and 504 Gateway errors.

Here is the architectural blueprint I use to design high-throughput, idempotent webhook ingestion pipelines.

---

## The Core Rule: Ingestion Must Be Decoupled from Processing

The incoming HTTP handler must do only three things:
1. **Validate signature / auth token** (e.g., HMAC-SHA256).
2. **Buffer raw payload into a persistent message broker** (Redis Streams or RabbitMQ).
3. **Acknowledge HTTP 202 Accepted immediately** (within < 30ms).

```
[ External Provider ] 
        │ HTTP POST (Payload + HMAC)
        ▼
[ FastAPI Ingestion Gateway ] (< 25ms)
        │
        ├── 1. Verify HMAC Signature
        ├── 2. Push to Redis Stream (`webhooks:incoming`)
        └── 3. Return 202 Accepted
        │
        ▼
[ Background Celery / Worker Pool ]
        │
        ├── Idempotency Check (Redis SETNX key)
        ├── Atomic DB Upsert (PostgreSQL)
        └── Event Dispatch
```

---

## 1. FastAPI Fast Ingestion Endpoint

Below is a production-tested FastAPI endpoint that verifies signatures using constant-time comparison and pushes the event into a Redis Stream:

```python
import hmac
import hashlib
import time
from fastapi import FastAPI, Request, HTTPException, status, Header
import redis.asyncio as aioredis

app = FastAPI()
redis_client = aioredis.from_url("redis://localhost:6379/0", decode_responses=False)
WEBHOOK_SECRET = b"production_shared_secret_key"

@app.post("/api/v1/webhooks/inbound", status_code=status.HTTP_202_ACCEPTED)
async def handle_inbound_webhook(
    request: Request,
    x_signature: str = Header(..., alias="X-Signature-SHA256")
):
    body = await request.body()
    
    # 1. Constant-time signature verification prevents timing attacks
    expected_sig = hmac.new(WEBHOOK_SECRET, body, hashlib.sha256).hexdigest()
    if not hmac.compare_digest(expected_sig, x_signature):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid signature")

    # 2. Append directly to Redis Stream with timestamp
    event_id = await redis_client.xadd(
        name="stream:webhooks",
        fields={
            b"received_at": str(time.time()).encode(),
            b"payload": body
        },
        maxlen=100_000, # Prevents unbounded memory growth
        approximate=True
    )

    return {"status": "enqueued", "event_id": event_id.decode()}
```

Notice that we don't even parse JSON in the HTTP path if we don't strictly need to. The raw bytes are verified and pushed directly into Redis.

---

## 2. Ensuring Idempotency: Handling Duplicate Retries

Third-party webhook providers guarantee **at-least-once delivery**. That means duplicate deliveries are not an exception—they are an inevitable guarantee.

To avoid double-billing or applying the same state change twice:
1. Extract the provider's unique event ID (e.g., `evt_12345` or Twilio's `MessageSid`).
2. Use Redis `SET key value NX EX <seconds>` (atomic set-if-not-exists with expiration) as a distributed deduplication lock.

```python
from celery import shared_task
import json

@shared_task(bind=True, max_retries=5, default_retry_delay=30)
def process_webhook_event(self, raw_payload: str):
    data = json.loads(raw_payload)
    event_id = data.get("id")
    
    dedup_key = f"dedup:webhook:{event_id}"
    
    # Acquire 24-hour deduplication lock atomically
    acquired = redis_sync.set(dedup_key, "1", nx=True, ex=86400)
    if not acquired:
        # Already processed or currently processing
        return {"status": "skipped", "reason": "duplicate_event"}

    try:
        # Execute business logic inside a database transaction
        with transaction.atomic():
            apply_event_transition(data)
    except Exception as exc:
        # On transient database failure, release lock so retry can run
        redis_sync.delete(dedup_key)
        raise self.retry(exc=exc)
```

---

## 3. Graceful Degradation & Dead Letter Queues (DLQ)

When downstream services or databases fail intermittently, retries with **exponential backoff + jitter** prevent stampeding thundering herd problems.

Any payload that fails all retry attempts is routed to a **Dead Letter Queue (DLQ)** along with its stack trace. This ensures:
- No data is silently lost.
- Engineers can replay failed events with a single CLI script after patching bugs.

---

## Summary Checklist

- [x] Respond with `202 Accepted` within 50ms.
- [x] Push payloads directly to a durable stream or queue.
- [x] Protect against duplicate deliveries with atomic idempotency locks.
- [x] Store raw payloads for at least 7 days to facilitate manual audit and event replay.
