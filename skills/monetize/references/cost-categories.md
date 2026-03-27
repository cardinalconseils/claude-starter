# Cost Categories Reference

## How to Use This Reference
Read this file during the cost-analysis workflow. Use the detection signals to determine
which categories are relevant for a given product, then research the listed providers.

## Category 1: AI/ML Inference

**Detection Signals:** LLM, GPT, Claude, Gemini, embeddings, AI, ML, model, inference, NLP, RAG, vector search

**Key Providers:**
| Provider | Product | Billing Unit | Typical Range |
|----------|---------|-------------|---------------|
| OpenAI | GPT-4o, GPT-4o-mini | Per token (input/output) | $0.15-$10/1M tokens |
| Anthropic | Claude Sonnet, Opus, Haiku | Per token (input/output) | $0.25-$15/1M tokens |
| Google | Gemini Pro, Flash | Per token (input/output) | $0.075-$5/1M tokens |
| Together AI | Open source models | Per token | $0.10-$2/1M tokens |
| Groq | Open source (fast) | Per token | $0.05-$0.90/1M tokens |
| AWS Bedrock | Multi-provider | Per token | Varies by model |

**What to Capture:** Input vs output token pricing, context window costs, batch vs real-time pricing, fine-tuning costs.

## Category 2: Speech & Voice

**Detection Signals:** TTS, STT, speech, voice, transcription, dictation, voice agent, audio, real-time voice

**Key Providers:**
| Provider | Product | Billing Unit | Typical Range |
|----------|---------|-------------|---------------|
| ElevenLabs | TTS | Per character | $0.15-$0.30/1K chars |
| OpenAI | TTS, Whisper STT | Per character / per minute | TTS: $15/1M chars, STT: $0.006/min |
| Deepgram | STT, TTS | Per minute / per character | STT: $0.0043-$0.0145/min |
| AssemblyAI | STT | Per minute | $0.01-$0.05/min |
| Google Cloud | Speech-to-Text, TTS | Per minute / per character | STT: $0.006-$0.024/min |
| Azure | Speech Services | Per minute / per character | STT: $0.01/min |

**What to Capture:** Real-time vs batch pricing, language support costs, custom voice costs, streaming latency pricing.

## Category 3: Infrastructure & Hosting

**Detection Signals:** hosting, compute, server, database, storage, CDN, bandwidth, deploy, container, serverless

**Key Providers:**
| Provider | Product | Billing Unit | Typical Range |
|----------|---------|-------------|---------------|
| Vercel | Hosting, Edge, Serverless | Per request / per GB | Free tier → $20/mo+ |
| Railway | App hosting | Per vCPU-hour, per GB-hour | ~$5-$50/mo typical |
| AWS | EC2, Lambda, S3, RDS | Per hour / per request / per GB | Varies widely |
| GCP | Cloud Run, GCS, Cloud SQL | Per vCPU-second / per GB | Varies widely |
| Supabase | Database, Auth, Storage | Per project / per GB | Free → $25/mo+ |
| PlanetScale | MySQL database | Per reads/writes/storage | Free → $29/mo+ |
| Neon | Postgres database | Per compute-hour / per GB | Free → $19/mo+ |
| Cloudflare | CDN, Workers, R2 | Per request / per GB | Generous free tier |

**What to Capture:** Base cost vs usage-based, egress fees, cold start costs, scaling behavior.

## Category 4: Third-Party SaaS

**Detection Signals:** auth, Clerk, Auth0, payments, Stripe, monitoring, analytics, Sentry, Datadog, logging

**Key Providers:**
| Provider | Product | Billing Unit | Typical Range |
|----------|---------|-------------|---------------|
| Stripe | Payment processing | Per transaction (%) | 2.9% + $0.30 |
| Clerk | Authentication | Per MAU | Free → $0.02/MAU |
| Auth0 | Authentication | Per MAU | Free → $0.015/MAU |
| Sentry | Error monitoring | Per event | Free → $26/mo |
| Datadog | Monitoring/APM | Per host / per event | $15-$35/host/mo |
| PostHog | Analytics | Per event | Free → usage-based |
| LaunchDarkly | Feature flags | Per seat / per MAU | $10/seat/mo |

**What to Capture:** Free tier limits (critical for early stage), per-unit overage costs, annual vs monthly pricing.

## Category 5: Communication

**Detection Signals:** telephony, Twilio, Telnyx, SMS, email, push, notifications, SIP, PSTN, call

**Key Providers:**
| Provider | Product | Billing Unit | Typical Range |
|----------|---------|-------------|---------------|
| Twilio | Voice, SMS, Video | Per minute / per message | Voice: $0.013-$0.022/min |
| Telnyx | Voice, SMS, SIP | Per minute / per message | Voice: $0.005-$0.01/min |
| SendGrid | Email delivery | Per email | Free → $0.001/email |
| Resend | Email delivery | Per email | Free → $0.001/email |
| OneSignal | Push notifications | Per subscriber | Free → $9/mo |

**What to Capture:** Inbound vs outbound pricing, international rates, phone number costs, CNAM/caller ID fees.

## Category 6: Agent & Orchestration Platforms

**Detection Signals:** Vapi, Bland, Retell, LiveKit, agent platform, workflow engine, voice AI platform, conversational AI

**Key Providers:**
| Provider | Product | Billing Unit | Typical Range |
|----------|---------|-------------|---------------|
| Vapi | Voice AI platform | Per minute | $0.05/min + provider costs |
| Bland AI | Voice AI agents | Per minute | $0.07-$0.12/min (all-in) |
| Retell AI | Voice AI platform | Per minute | $0.05-$0.08/min |
| LiveKit | Real-time media | Per participant-minute | $0.004/min |
| LangChain/LangSmith | LLM orchestration | Per trace | Free → $39/mo |
| CrewAI | Multi-agent | Self-hosted / cloud | Free (OSS) → cloud pricing |

**What to Capture:** All-inclusive vs component pricing, what's included vs pass-through, minimum commitments.

## Category 7: Data & Storage

**Detection Signals:** vector DB, Pinecone, Weaviate, Redis, S3, data pipeline, embeddings storage, search index

**Key Providers:**
| Provider | Product | Billing Unit | Typical Range |
|----------|---------|-------------|---------------|
| Pinecone | Vector database | Per pod / serverless | Free → $70/mo |
| Weaviate | Vector database | Per pod | Free (OSS) → cloud pricing |
| Qdrant | Vector database | Per node | Free (OSS) → cloud pricing |
| Upstash | Redis, Kafka | Per request / per message | Free → usage-based |
| AWS S3 | Object storage | Per GB / per request | $0.023/GB/mo |
| Cloudflare R2 | Object storage | Per GB (no egress) | $0.015/GB/mo |

**What to Capture:** Storage vs query pricing, index size limits, cold vs hot storage, backup costs.

## Category 8: Media & Generation

**Detection Signals:** image generation, video, CDN, streaming, media processing, transcoding, thumbnails

**Key Providers:**
| Provider | Product | Billing Unit | Typical Range |
|----------|---------|-------------|---------------|
| OpenAI | DALL-E, GPT-4V | Per image / per token | $0.02-$0.12/image |
| Stability AI | Image generation | Per image | $0.002-$0.02/image |
| Replicate | Model hosting | Per second of compute | $0.0001-$0.005/sec |
| Mux | Video streaming | Per minute stored/streamed | $0.007/min stored |
| Cloudflare Stream | Video | Per minute stored/delivered | $5/1K min stored |
| imgix | Image CDN | Per master image | $0.003/image/mo |

**What to Capture:** Generation vs storage vs delivery costs, quality tier pricing, batch pricing.

---

*Typical ranges are approximate and change frequently. The cost-researcher agent should verify current pricing from provider websites.*
